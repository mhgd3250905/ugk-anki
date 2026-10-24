import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:ugk_data/ugk_data.dart';

import '../../data/clock.dart';
import '../../data/repo_scope.dart';
import '../glass/glass_icon_button.dart';
import '../glass/glass_page.dart';
import '../theme/tokens.dart';
import 'add_note_screen.dart';
import 'study_screen.dart';

/// 一行卡组的显示数据
class DeckSummary {
  const DeckSummary(
    this.deck,
    this.newCount,
    this.learnCount,
    this.reviewCount,
  );

  final DeckRow deck;
  final int newCount;
  final int learnCount;
  final int reviewCount;
}

/// 首页：卡组列表
class DeckListScreen extends StatefulWidget {
  const DeckListScreen({super.key});

  @override
  State<DeckListScreen> createState() => _DeckListScreenState();
}

class _DeckListScreenState extends State<DeckListScreen> {
  List<DeckSummary>? _decks;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reload();
  }

  Future<void> _reload() async {
    final repo = RepoScope.of(context);
    final now = nowMs();
    final offset = utcOffsetMinutes();
    final result = <DeckSummary>[];
    for (final d in await repo.decks()) {
      final q = await repo.todayQueue(
        deckId: d.id,
        nowMs: now,
        utcOffsetMinutes: offset,
      );
      result.add(DeckSummary(d, q.newCount, q.learnCount, q.reviewCount));
    }
    if (mounted) setState(() => _decks = result);
  }

  Future<void> _open(DeckSummary s) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StudyScreen(deckId: s.deck.id, deckName: s.deck.name),
      ),
    );
    _reload();
  }

  Future<void> _add() async {
    final first = _decks?.firstOrNull?.deck.id ?? kDefaultDeckId;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddNoteScreen(initialDeckId: first),
      ),
    );
    _reload();
  }

  Future<void> _createDeck() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新建卡组'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '例如 English::Dance'),
          onSubmitted: (v) => Navigator.of(ctx).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('创建'),
          ),
        ],
      ),
    );
    controller.dispose();
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty || !mounted) return;
    try {
      await RepoScope.of(context).createDeck(trimmed, nowMs: nowMs());
    } on StateError {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('卡组「$trimmed」已存在')));
      }
    }
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final decks = _decks;
    return GlassPage(
      child: Column(
        children: [
          GlassTitleRow(
            title: '卡组',
            trailing: Row(
              children: [
                GlassIconButton(
                  icon: Icons.create_new_folder_outlined,
                  onTap: _createDeck,
                ),
                const SizedBox(width: UgkSpace.s),
                GlassIconButton(icon: Icons.add, onTap: _add),
              ],
            ),
          ),
          const SizedBox(height: UgkSpace.l),
          Expanded(
            child: decks == null
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _reload,
                    child: ListView.separated(
                      itemCount: decks.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: UgkSpace.ratingGap),
                      itemBuilder: (_, i) => _DeckTile(
                        summary: decks[i],
                        onTap: () => _open(decks[i]),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DeckTile extends StatelessWidget {
  const _DeckTile({required this.summary, required this.onTap});

  final DeckSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    final parts = summary.deck.name.split('::');
    final depth = parts.length - 1;
    return Padding(
      padding: EdgeInsets.only(left: depth * UgkSpace.m),
      child: GestureDetector(
        onTap: onTap,
        child: LiquidStretch(
          interactionScale: 0.98,
          child: GlassPanel(
            padding: const EdgeInsets.symmetric(
              horizontal: UgkSpace.m,
              vertical: UgkSpace.m + 2,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    parts.last,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _Num(summary.newCount, UgkColors.newBlue),
                _Num(summary.learnCount, UgkColors.learnRed),
                _Num(summary.reviewCount, UgkColors.reviewGreen),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Num extends StatelessWidget {
  const _Num(this.value, this.color);

  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.25);
    return SizedBox(
      width: 40,
      child: Text(
        '$value',
        textAlign: TextAlign.right,
        style: TextStyle(
          color: value == 0 ? muted : color,
          fontSize: UgkText.count + 1,
          fontWeight: FontWeight.w600,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
