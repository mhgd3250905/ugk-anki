import 'package:flutter/material.dart';
import 'package:ugk_core/ugk_core.dart' hide Card;
import 'package:ugk_data/ugk_data.dart';

import '../../data/clock.dart';
import '../../data/repo_scope.dart';
import '../glass/glass_icon_button.dart';
import '../glass/glass_kit.dart';
import '../glass/glass_page.dart';
import '../cloze_picker.dart';
import '../labels.dart';
import '../theme/tokens.dart';

/// 添加笔记页
class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({required this.initialDeckId, super.key});

  final int initialDeckId;

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  List<NoteType> _types = const [];
  List<DeckRow> _decks = const [];
  NoteType? _type;
  late int _deckId = widget.initialDeckId;
  List<TextEditingController> _fields = [];
  final TextEditingController _tags = TextEditingController();
  final List<String> _tagList = [];

  /// 填空：正文里被点选要考的字（下标）
  Set<int> _picked = {};
  String _clozeText = '';
  bool _saving = false;

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
      _selectType(types.first);
    });
  }

  void _selectType(NoteType t) {
    for (final c in _fields) {
      c.dispose();
    }
    _type = t;
    _fields = [for (final _ in t.fields) TextEditingController()];
    _picked = {};
    _clozeText = '';
    if (t.kind == NoteKind.cloze) {
      final c = _fields[0];
      c.addListener(() {
        if (c.text == _clozeText) return;
        setState(() {
          _picked = shiftPicked(_clozeText, c.text, _picked);
          _clozeText = c.text;
        });
      });
    }
  }

  /// 输入空格或逗号时，把前面的文字变成一个标签
  void _onTagTyping(String text) {
    if (RegExp(r'[\s,，、;；]').hasMatch(text)) _commitTags();
  }

  void _commitTags() {
    final add = splitTags(_tags.text);
    setState(() {
      for (final t in add) {
        if (!_tagList.contains(t)) _tagList.add(t);
      }
      _tags.clear();
    });
  }

  Future<void> _save() async {
    final type = _type;
    if (type == null || _saving) return;
    final values = [
      for (var i = 0; i < _fields.length; i++)
        i == 0 && type.kind == NoteKind.cloze
            ? buildClozeText(_fields[0].text, _picked)
            : _fields[i].text,
    ];
    final problem = addNoteProblem(type, values);
    if (problem != null) {
      showGlassToast(context, problem, warn: true);
      return;
    }
    setState(() => _saving = true);
    try {
      final ids = await RepoScope.of(context).addNote(
        noteTypeId: type.id,
        deckId: _deckId,
        fields: values,
        tags: [..._tagList, ...splitTags(_tags.text)],
        nowMs: nowMs(),
      );
      for (final c in _fields) {
        c.clear();
      }
      _picked = {};
      if (mounted) showGlassToast(context, '已添加 ${ids.length} 张卡片');
    } on StateError {
      if (mounted) {
        showGlassToast(context, '这条内容生成不了卡片，检查一下第一个输入框', warn: true);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    for (final c in _fields) {
      c.dispose();
    }
    _tags.dispose();
    super.dispose();
  }

  Future<void> _pickDeck() async {
    final current = _decks.firstWhere((d) => d.id == _deckId);
    final picked = await showGlassPicker<DeckRow>(
      context,
      title: '选择卡组',
      items: _decks,
      selected: current,
      labelOf: (d) => deckLabel(d.name),
    );
    if (picked != null && mounted) setState(() => _deckId = picked.id);
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
            title: '添加',
            leading: GlassIconButton(
              icon: Icons.arrow_back_ios_new,
              onTap: () => Navigator.of(context).maybePop(),
            ),
            trailing: SizedBox(
              width: 84,
              child: GlassPillButton(
                key: const ValueKey('save'),
                label: '添加',
                primary: true,
                onTap: _saving ? null : _save,
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
                            _Label('类型', color),
                            GlassSegmented<NoteType>(
                              items: _types,
                              selected: type,
                              labelOf: typeLabel,
                              onSelect: (t) => setState(() => _selectType(t)),
                            ),
                            const SizedBox(height: UgkSpace.m),
                            _Label('卡组', color),
                            GlassSelectRow(
                              key: const ValueKey('deck-select'),
                              value: deckName ?? '',
                              onTap: _pickDeck,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: UgkSpace.m),
                      GlassPanel(
                        radius: UgkRadius.card - 8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var i = 0; i < type.fields.length; i++) ...[
                              if (i > 0) const SizedBox(height: UgkSpace.m),
                              _Label(fieldLabel(type.fields[i].name), color),
                              GlassTextField(
                                key: ValueKey('field-${type.id}-$i'),
                                controller: _fields[i],
                                maxLines: 6,
                                hint: i == 0 && type.kind == NoteKind.cloze
                                    ? '例如：巴黎是法国的首都'
                                    : null,
                              ),
                              if (i == 0 && type.kind == NoteKind.cloze) ...[
                                const SizedBox(height: UgkSpace.m),
                                _Label('点选要考的字（点一下变蓝，再点取消）', color),
                                ClozePicker(
                                  key: const ValueKey('cloze-picker'),
                                  text: _fields[0].text,
                                  picked: _picked,
                                  onChanged: (p) => setState(() => _picked = p),
                                ),
                                const SizedBox(height: UgkSpace.s),
                                ClozePreview(
                                  text: _fields[0].text,
                                  picked: _picked,
                                ),
                              ],
                            ],
                            const SizedBox(height: UgkSpace.m),
                            _Label('标签（可不填）', color),
                            if (_tagList.isNotEmpty) ...[
                              Wrap(
                                spacing: UgkSpace.s,
                                runSpacing: UgkSpace.s,
                                children: [
                                  for (final t in _tagList)
                                    _TagChip(
                                      t,
                                      onRemove: () =>
                                          setState(() => _tagList.remove(t)),
                                    ),
                                ],
                              ),
                              const SizedBox(height: UgkSpace.s),
                            ],
                            GlassTextField(
                              key: const ValueKey('tags'),
                              controller: _tags,
                              hint: '输入一个标签，按回车添加',
                              onChanged: _onTagTyping,
                              onSubmitted: (_) => _commitTags(),
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

class _TagChip extends StatelessWidget {
  const _TagChip(this.text, {required this.onRemove});

  final String text;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return GestureDetector(
      onTap: onRemove,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
        decoration: BoxDecoration(
          color: UgkColors.newBlue.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(color: onSurface, fontSize: UgkText.hint),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.close_rounded,
              size: 14,
              color: onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
