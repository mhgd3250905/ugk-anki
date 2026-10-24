import 'package:flutter/material.dart';
import 'package:ugk_core/ugk_core.dart' hide Card;
import 'package:ugk_data/ugk_data.dart';

import '../../data/clock.dart';
import '../../data/repo_scope.dart';
import '../glass/glass_icon_button.dart';
import '../glass/glass_kit.dart';
import '../glass/glass_page.dart';
import '../labels.dart';
import '../theme/tokens.dart';

/// CSV 导入设置页。导入成功后 pop 出 [ImportResult]。
class ImportScreen extends StatefulWidget {
  const ImportScreen({
    required this.table,
    required this.fileName,
    required this.initialDeckId,
    super.key,
  });

  final CsvTable table;
  final String fileName;
  final int initialDeckId;

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  List<NoteType> _types = const [];
  List<DeckRow> _decks = const [];
  NoteType? _type;
  late int _deckId = widget.initialDeckId;
  List<int?> _fieldCols = const [];
  late int? _tagsCol = widget.table.tagsColumn;
  late bool _html = widget.table.html ?? false;
  DuplicateMode _dups = DuplicateMode.skip;
  bool _header = false;
  bool _busy = false;

  CsvTable get _t => widget.table;

  /// 文件自带笔记类型列时，字段按文件列顺序，不需要手动映射
  bool get _fileDriven => _t.notetypeColumn != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_types.isEmpty) _load();
  }

  Future<void> _load() async {
    final repo = RepoScope.of(context);
    final types = await repo.noteTypes();
    final decks = await repo.decks();
    if (!mounted) return;
    setState(() {
      _types = types;
      _decks = decks;
      if (!decks.any((d) => d.id == _deckId)) _deckId = decks.first.id;
      _header = _looksLikeHeader(types);
      if (_header && _tagsCol == null) {
        final i = _t.rows.first.indexWhere(
          (c) => const {'tags', '标签'}.contains(c.trim().toLowerCase()),
        );
        if (i >= 0) _tagsCol = i;
      }
      _selectType(types.first);
    });
  }

  /// 第一行里有字段名或常见表头词时，默认当表头
  bool _looksLikeHeader(List<NoteType> types) {
    if (_t.rows.isEmpty) return false;
    const words = {'front', 'back', 'text', 'tags', 'extra', '正面', '背面', '标签'};
    final names = {
      ...words,
      for (final t in types)
        for (final f in t.fields) f.name.toLowerCase(),
    };
    return _t.rows.first.any((c) => names.contains(c.trim().toLowerCase()));
  }

  /// 默认映射：跳过标签 / 类型 / 卡组列，其余按顺序对应字段
  void _selectType(NoteType t) {
    _type = t;
    final free = [
      for (var i = 0; i < _t.columnCount; i++)
        if (i != _tagsCol && i != _t.notetypeColumn && i != _t.deckColumn) i,
    ];
    _fieldCols = [
      for (var i = 0; i < t.fields.length; i++)
        i < free.length ? free[i] : null,
    ];
  }

  String _sample(int col) {
    for (final r in _t.rows.skip(_header ? 1 : 0)) {
      if (col < r.length && r[col].trim().isNotEmpty) {
        final s = r[col].replaceAll('\n', ' ').trim();
        return s.length > 24 ? '${s.substring(0, 24)}…' : s;
      }
    }
    return '（空）';
  }

  String _colLabel(int? col) =>
      col == null ? '不导入' : '第 ${col + 1} 列 · ${_sample(col)}';

  Future<int?> _pickColumn(String title, int? current) async {
    const none = -1;
    final picked = await showGlassPicker<int>(
      context,
      title: title,
      items: [none, for (var i = 0; i < _t.columnCount; i++) i],
      selected: current ?? none,
      labelOf: (c) => _colLabel(c == none ? null : c),
    );
    if (picked == null) return current;
    return picked == none ? null : picked;
  }

  Future<void> _pickDeck() async {
    final picked = await showGlassPicker<DeckRow>(
      context,
      title: '导入到卡组',
      items: _decks,
      selected: _decks.firstWhere((d) => d.id == _deckId),
      labelOf: (d) => deckLabel(d.name),
    );
    if (picked != null && mounted) setState(() => _deckId = picked.id);
  }

  Future<void> _import() async {
    final type = _type;
    if (type == null || _busy) return;
    setState(() => _busy = true);
    try {
      final result = await RepoScope.of(context).importCsv(
        _t,
        ImportOptions(
          noteTypeId: type.id,
          deckId: _deckId,
          fieldColumns: _fieldCols,
          tagsColumn: _tagsCol,
          allowHtml: _html,
          duplicates: _dups,
          skipFirstRow: _header,
        ),
        nowMs: nowMs(),
      );
      if (mounted) Navigator.of(context).pop(result);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = _type;
    final color = Theme.of(context).colorScheme.onSurface;
    final deckName = _decks
        .where((d) => d.id == _deckId)
        .map((d) => deckLabel(d.name))
        .firstOrNull;
    return GlassPage(
      child: Column(
        children: [
          GlassTitleRow(
            title: '导入',
            leading: GlassIconButton(
              icon: Icons.arrow_back_ios_new,
              onTap: () => Navigator.of(context).maybePop(),
            ),
            trailing: SizedBox(
              width: 84,
              child: GlassPillButton(
                key: const ValueKey('do-import'),
                label: '导入',
                primary: true,
                onTap: _busy || _t.rows.isEmpty ? null : _import,
              ),
            ),
          ),
          const SizedBox(height: UgkSpace.l),
          Expanded(
            child: type == null
                ? const GlassLoading()
                : ListView(
                    children: [
                      GlassPanel(
                        radius: UgkRadius.card - 8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              widget.fileName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: color,
                                fontSize: UgkText.field,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: UgkSpace.xs),
                            Text(
                              '${_t.rows.length} 行 · ${_t.columnCount} 列 · 分隔符 ${_delimName(_t.delimiter)}',
                              style: TextStyle(
                                color: color.withValues(alpha: 0.55),
                                fontSize: UgkText.hint,
                              ),
                            ),
                            if (_fileDriven) ...[
                              const SizedBox(height: UgkSpace.s),
                              Text(
                                '文件自带笔记类型和卡组，将按文件内容导入',
                                style: TextStyle(
                                  color: UgkColors.newBlue,
                                  fontSize: UgkText.hint,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: UgkSpace.m),
                      GlassPanel(
                        radius: UgkRadius.card - 8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _Label(
                              _fileDriven ? '默认类型（文件里认不出时用）' : '类型',
                              color,
                            ),
                            GlassSegmented<NoteType>(
                              items: _types,
                              selected: type,
                              labelOf: typeLabel,
                              onSelect: (t) => setState(() => _selectType(t)),
                            ),
                            const SizedBox(height: UgkSpace.m),
                            _Label(
                              _t.deckColumn != null ? '默认卡组（文件里没写时用）' : '卡组',
                              color,
                            ),
                            GlassSelectRow(
                              key: const ValueKey('import-deck'),
                              value: deckName ?? '',
                              onTap: _pickDeck,
                            ),
                          ],
                        ),
                      ),
                      if (!_fileDriven) ...[
                        const SizedBox(height: UgkSpace.m),
                        GlassPanel(
                          radius: UgkRadius.card - 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var i = 0; i < type.fields.length; i++) ...[
                                if (i > 0) const SizedBox(height: UgkSpace.m),
                                _Label(fieldLabel(type.fields[i].name), color),
                                GlassSelectRow(
                                  key: ValueKey('map-$i'),
                                  value: _colLabel(_fieldCols[i]),
                                  onTap: () async {
                                    final c = await _pickColumn(
                                      fieldLabel(type.fields[i].name),
                                      _fieldCols[i],
                                    );
                                    if (mounted) {
                                      setState(() => _fieldCols[i] = c);
                                    }
                                  },
                                ),
                              ],
                              const SizedBox(height: UgkSpace.m),
                              _Label('标签', color),
                              GlassSelectRow(
                                key: const ValueKey('map-tags'),
                                value: _colLabel(_tagsCol),
                                onTap: () async {
                                  final c = await _pickColumn('标签', _tagsCol);
                                  if (mounted) setState(() => _tagsCol = c);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: UgkSpace.m),
                      GlassPanel(
                        radius: UgkRadius.card - 8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _Label('第一行', color),
                            GlassSegmented<bool>(
                              key: const ValueKey('header'),
                              items: const [false, true],
                              selected: _header,
                              labelOf: (h) => h ? '是表头，跳过' : '是数据',
                              onSelect: (h) => setState(() => _header = h),
                            ),
                            const SizedBox(height: UgkSpace.m),
                            _Label('内容格式', color),
                            GlassSegmented<bool>(
                              items: const [false, true],
                              selected: _html,
                              labelOf: (h) => h ? 'HTML' : '纯文本',
                              onSelect: (h) => setState(() => _html = h),
                            ),
                            const SizedBox(height: UgkSpace.m),
                            _Label('重复内容（第一个输入框相同）', color),
                            GlassSegmented<DuplicateMode>(
                              items: DuplicateMode.values,
                              selected: _dups,
                              labelOf: (d) => switch (d) {
                                DuplicateMode.skip => '跳过',
                                DuplicateMode.add => '照样导入',
                              },
                              onSelect: (d) => setState(() => _dups = d),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

String _delimName(String d) => switch (d) {
  '\t' => 'Tab',
  ',' => '逗号',
  ';' => '分号',
  '|' => '竖线',
  ' ' => '空格',
  _ => d,
};

class _Label extends StatelessWidget {
  const _Label(this.text, this.color);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: UgkSpace.xs),
    child: Text(
      text,
      style: TextStyle(
        color: color.withValues(alpha: 0.55),
        fontSize: UgkText.tag,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
