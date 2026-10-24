/// CSV / TSV 读写（兼容 Anki 文本导出的 `#key:value` 文件头）

/// 解析结果
class CsvTable {
  const CsvTable({
    required this.rows,
    required this.delimiter,
    this.html,
    this.tagsColumn,
    this.notetypeColumn,
    this.deckColumn,
  });

  /// 数据行（已去掉文件头和全空行）
  final List<List<String>> rows;

  /// 实际使用的分隔符
  final String delimiter;

  /// 文件头 `#html:true/false`；没写时为 null
  final bool? html;

  /// 文件头里的列号，已转成 0 起
  final int? tagsColumn;
  final int? notetypeColumn;
  final int? deckColumn;

  /// 最宽一行的列数
  int get columnCount => rows.fold(0, (m, r) => r.length > m ? r.length : m);
}

const _separatorNames = {
  'tab': '\t',
  'comma': ',',
  'semicolon': ';',
  'pipe': '|',
  'colon': ':',
  'space': ' ',
};

/// 解析 CSV 文本。分隔符优先用文件头 `#separator:`，否则自动判断（tab > 分号 / 逗号谁多用谁）。
CsvTable parseCsv(String text) {
  if (text.startsWith('\uFEFF')) text = text.substring(1);
  final lines = text.split('\n');
  var bodyStart = 0;
  String? delimiter;
  bool? html;
  int? tagsCol, typeCol, deckCol;
  var offset = 0;
  for (final raw in lines) {
    final line = raw.endsWith('\r') ? raw.substring(0, raw.length - 1) : raw;
    if (!line.startsWith('#')) break;
    final colon = line.indexOf(':');
    if (colon > 1) {
      final key = line.substring(1, colon).trim().toLowerCase();
      final value = line.substring(colon + 1).trim();
      switch (key) {
        case 'separator':
          delimiter =
              _separatorNames[value.toLowerCase()] ??
              (value.isNotEmpty ? value[0] : null);
        case 'html':
          html = value.toLowerCase() == 'true';
        case 'tags column':
          tagsCol = _col(value);
        case 'notetype column':
          typeCol = _col(value);
        case 'deck column':
          deckCol = _col(value);
      }
    }
    offset += raw.length + 1;
    bodyStart++;
  }
  final body = bodyStart == 0
      ? text
      : text.substring(offset.clamp(0, text.length));
  delimiter ??= _guessDelimiter(body);
  final rows = _parseBody(
    body,
    delimiter,
  ).where((r) => r.any((c) => c.trim().isNotEmpty)).toList();
  return CsvTable(
    rows: rows,
    delimiter: delimiter,
    html: html,
    tagsColumn: tagsCol,
    notetypeColumn: typeCol,
    deckColumn: deckCol,
  );
}

int? _col(String v) {
  final n = int.tryParse(v);
  return n == null || n < 1 ? null : n - 1;
}

String _guessDelimiter(String body) {
  final first = body
      .split('\n')
      .firstWhere((l) => l.trim().isNotEmpty, orElse: () => '');
  if (first.contains('\t')) return '\t';
  final semi = ';'.allMatches(first).length;
  final comma = ','.allMatches(first).length;
  return semi > comma ? ';' : ',';
}

List<List<String>> _parseBody(String s, String d) {
  final rows = <List<String>>[];
  var row = <String>[];
  final cell = StringBuffer();
  var inQuotes = false;
  var atCellStart = true;
  for (var i = 0; i < s.length; i++) {
    final ch = s[i];
    if (inQuotes) {
      if (ch == '"') {
        if (i + 1 < s.length && s[i + 1] == '"') {
          cell.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        cell.write(ch);
      }
      continue;
    }
    if (ch == '"' && atCellStart) {
      inQuotes = true;
      atCellStart = false;
    } else if (ch == d) {
      row.add(cell.toString());
      cell.clear();
      atCellStart = true;
    } else if (ch == '\n' || ch == '\r') {
      if (ch == '\r' && i + 1 < s.length && s[i + 1] == '\n') i++;
      row.add(cell.toString());
      cell.clear();
      rows.add(row);
      row = <String>[];
      atCellStart = true;
    } else {
      cell.write(ch);
      atCellStart = false;
    }
  }
  if (cell.isNotEmpty || row.isNotEmpty) {
    row.add(cell.toString());
    rows.add(row);
  }
  return rows;
}

/// 写 CSV：需要时加引号；行之间用 \n
String writeCsv(
  List<List<String>> rows, {
  String delimiter = '\t',
  List<String> header = const [],
}) {
  final out = StringBuffer();
  for (final h in header) {
    out.writeln(h);
  }
  for (final r in rows) {
    out.writeln(r.map((c) => _quote(c, delimiter)).join(delimiter));
  }
  return out.toString();
}

String _quote(String c, String d) {
  if (c.contains(d) ||
      c.contains('"') ||
      c.contains('\n') ||
      c.contains('\r')) {
    return '"${c.replaceAll('"', '""')}"';
  }
  return c;
}

/// 不允许 HTML 时，把纯文本转成安全的 HTML（与 Anki 一致：转义并把换行变 <br>）
String plainToHtml(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('\r\n', '\n')
    .replaceAll('\n', '<br>');
