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
  }

  Future<void> _save() async {
    final type = _type;
    if (type == null || _saving) return;
    final problem = addNoteProblem(type, [for (final c in _fields) c.text]);
    if (problem != null) {
      showGlassToast(context, problem, warn: true);
      return;
    }
    setState(() => _saving = true);
    try {
      final ids = await RepoScope.of(context).addNote(
        noteTypeId: type.id,
        deckId: _deckId,
        fields: [for (final c in _fields) c.text],
        tags: parseTags(_tags.text),
        nowMs: nowMs(),
      );
      for (final c in _fields) {
        c.clear();
      }
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
      labelOf: (d) => d.name,
    );
    if (picked != null && mounted) setState(() => _deckId = picked.id);
  }

  @override
  Widget build(BuildContext context) {
    final type = _type;
    final color = Theme.of(context).colorScheme.onSurface;
    final deckName = _decks
        .where((d) => d.id == _deckId)
        .map((d) => d.name)
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
                                const SizedBox(height: UgkSpace.s),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 96,
                                      child: GlassPillButton(
                                        key: const ValueKey('cloze'),
                                        label: '挖空',
                                        primary: true,
                                        height: 40,
                                        onTap: () => setState(
                                          () => _fields[0].value = applyCloze(
                                            _fields[0].value,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: UgkSpace.m),
                                    Expanded(
                                      child: Text(
                                        '选中要考的词，点挖空',
                                        style: TextStyle(
                                          color: color.withValues(alpha: 0.5),
                                          fontSize: UgkText.hint,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                            const SizedBox(height: UgkSpace.m),
                            _Label('标签（空格分隔）', color),
                            GlassTextField(
                              key: const ValueKey('tags'),
                              controller: _tags,
                              hint: '例如 街舞 邀约',
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
