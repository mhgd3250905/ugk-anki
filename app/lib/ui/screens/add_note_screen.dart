import 'package:flutter/material.dart';
import 'package:ugk_core/ugk_core.dart' hide Card;
import 'package:ugk_data/ugk_data.dart';

import '../../data/clock.dart';
import '../../data/repo_scope.dart';
import '../glass/glass_icon_button.dart';
import '../glass/glass_page.dart';
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
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
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
      messenger.showSnackBar(SnackBar(content: Text('已添加 ${ids.length} 张卡片')));
    } on StateError {
      messenger.showSnackBar(
        const SnackBar(content: Text('这条笔记不会生成卡片，请先填写正面（填空题要写 {{c1::...}}）')),
      );
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

  @override
  Widget build(BuildContext context) {
    final type = _type;
    final color = Theme.of(context).colorScheme.onSurface;
    return GlassPage(
      child: Column(
        children: [
          GlassTitleRow(
            title: '添加',
            leading: GlassIconButton(
              icon: Icons.arrow_back_ios_new,
              onTap: () => Navigator.of(context).maybePop(),
            ),
            trailing: GlassIconButton(
              icon: _saving ? Icons.hourglass_empty : Icons.check,
              onTap: _save,
            ),
          ),
          const SizedBox(height: UgkSpace.l),
          Expanded(
            child: type == null
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: [
                      GlassPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Label('类型', color),
                            Wrap(
                              spacing: UgkSpace.s,
                              runSpacing: UgkSpace.s,
                              children: [
                                for (final t in _types)
                                  ChoiceChip(
                                    label: Text(t.name),
                                    selected: t.id == type.id,
                                    onSelected: (_) =>
                                        setState(() => _selectType(t)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: UgkSpace.m),
                            _Label('卡组', color),
                            DropdownButton<int>(
                              value: _deckId,
                              isExpanded: true,
                              underline: const SizedBox.shrink(),
                              items: [
                                for (final d in _decks)
                                  DropdownMenuItem(
                                    value: d.id,
                                    child: Text(d.name),
                                  ),
                              ],
                              onChanged: (v) {
                                if (v != null) setState(() => _deckId = v);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: UgkSpace.m),
                      for (var i = 0; i < type.fields.length; i++) ...[
                        GlassPanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Label(type.fields[i].name, color),
                              TextField(
                                key: ValueKey('field-${type.id}-$i'),
                                controller: _fields[i],
                                minLines: 1,
                                maxLines: 6,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: UgkSpace.m),
                      ],
                      GlassPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Label('标签（空格分隔）', color),
                            TextField(
                              key: const ValueKey('tags'),
                              controller: _tags,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                              ),
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
