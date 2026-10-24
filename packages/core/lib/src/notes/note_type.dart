/// 笔记类型种类，存库 0/1
enum NoteKind { standard, cloze }

/// 笔记类型中的一个字段
class NoteField {
  final String name;
  final int ord;
  const NoteField(this.name, this.ord);
}

/// 笔记类型中的一张卡片模板
class CardTemplate {
  final String name;
  final int ord;
  final String qfmt;
  final String afmt;
  const CardTemplate({
    required this.name,
    required this.ord,
    required this.qfmt,
    required this.afmt,
  });
}

/// 笔记类型（字段 + 卡片模板）
class NoteType {
  final int id;
  final String name;
  final NoteKind kind;
  final List<NoteField> fields;
  final List<CardTemplate> templates;
  final String css;
  final int sortFieldIdx;
  const NoteType({
    required this.id,
    required this.name,
    required this.kind,
    required this.fields,
    required this.templates,
    required this.css,
    this.sortFieldIdx = 0,
  });

  /// 字段名列表
  List<String> get fieldNames => [for (final f in fields) f.name];
}

/// 默认卡面样式
const String kDefaultCss =
    '.card { font-family: sans-serif; font-size: 20px; text-align: center; }\n'
    '.cloze { font-weight: bold; color: #0a84ff; }';

/// 内置 Basic 笔记类型
NoteType basicNoteType(int id) => NoteType(
      id: id,
      name: 'Basic',
      kind: NoteKind.standard,
      fields: const [NoteField('Front', 0), NoteField('Back', 1)],
      templates: const [
        CardTemplate(
          name: 'Card 1',
          ord: 0,
          qfmt: '{{Front}}',
          afmt: '{{FrontSide}}<hr id=answer>{{Back}}',
        ),
      ],
      css: kDefaultCss,
    );

/// 内置 Basic (and reversed card) 笔记类型
NoteType basicReversedNoteType(int id) => NoteType(
      id: id,
      name: 'Basic (and reversed card)',
      kind: NoteKind.standard,
      fields: const [NoteField('Front', 0), NoteField('Back', 1)],
      templates: const [
        CardTemplate(
          name: 'Card 1',
          ord: 0,
          qfmt: '{{Front}}',
          afmt: '{{FrontSide}}<hr id=answer>{{Back}}',
        ),
        CardTemplate(
          name: 'Card 2',
          ord: 1,
          qfmt: '{{Back}}',
          afmt: '{{FrontSide}}<hr id=answer>{{Front}}',
        ),
      ],
      css: kDefaultCss,
    );

/// 内置 Cloze 笔记类型
NoteType clozeNoteType(int id) => NoteType(
      id: id,
      name: 'Cloze',
      kind: NoteKind.cloze,
      fields: const [NoteField('Text', 0), NoteField('Back Extra', 1)],
      templates: const [
        CardTemplate(
          name: 'Cloze',
          ord: 0,
          qfmt: '{{cloze:Text}}',
          afmt: '{{cloze:Text}}<br>{{Back Extra}}',
        ),
      ],
      css: kDefaultCss,
    );
