import 'package:flutter/material.dart';
import 'package:ugk_core/ugk_core.dart' hide Card;
import 'package:ugk_core/ugk_core.dart' as core show Card;

import '../../data/clock.dart';
import '../../data/repo_scope.dart';
import '../card_text.dart';
import '../glass/glass_card.dart';
import '../glass/glass_kit.dart';
import '../glass/glass_page.dart';
import '../glass/glass_rating_bar.dart';
import '../glass/glass_top_bar.dart';
import '../theme/tokens.dart';

/// 复习页（接真实数据）
class StudyScreen extends StatefulWidget {
  const StudyScreen({required this.deckId, required this.deckName, super.key});

  final int deckId;
  final String deckName;

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  bool _loading = true;
  bool _busy = false;
  StudyQueue? _queue;
  core.Card? _card;
  String _front = '';
  String _back = '';
  String _tag = '';
  List<String> _labels = const ['', '', '', ''];
  bool _showBack = false;
  int? _nextLearnDueMs;
  final Stopwatch _watch = Stopwatch();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) _load();
  }

  Future<void> _load() async {
    final repo = RepoScope.of(context);
    final now = nowMs();
    final offset = utcOffsetMinutes();
    final preset = await repo.presetForDeck(widget.deckId);
    final queue = await repo.todayQueue(
      deckId: widget.deckId,
      nowMs: now,
      utcOffsetMinutes: offset,
    );
    final card = queue.next(now, preset.learnAheadSecs);
    var front = '', back = '', tag = '';
    var labels = const ['', '', '', ''];
    if (card != null) {
      final rendered = await repo.render(card.id);
      front = cardPlainText(rendered.question);
      back = answerPlainText(rendered.answer);
      tag = tagLine(await repo.noteTags(card.noteId));
      final today = await repo.today(nowMs: now, utcOffsetMinutes: offset);
      final preview = previewLabels(card, preset, today: today);
      labels = [for (final r in Rating.values) preview[r]!];
    }
    if (!mounted) return;
    setState(() {
      _loading = false;
      _queue = queue;
      _card = card;
      _front = front;
      _back = back;
      _tag = tag;
      _labels = labels;
      _showBack = false;
      _nextLearnDueMs = card == null && queue.learning.isNotEmpty
          ? queue.learning.first.due
          : null;
    });
    _watch
      ..reset()
      ..start();
  }

  Future<void> _rate(int index) async {
    final card = _card;
    if (card == null || _busy) return;
    _busy = true;
    _watch.stop();
    try {
      final result = await RepoScope.of(context).answer(
        cardId: card.id,
        rating: Rating.values[index],
        nowMs: nowMs(),
        utcOffsetMinutes: utcOffsetMinutes(),
        timeTakenMs: _watch.elapsedMilliseconds,
      );
      if (result.leechTriggered && mounted) {
        showGlassToast(context, '这张卡忘了太多次，已标记 leech，建议改写', warn: true);
      }
      await _load();
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _queue;
    return GlassPage(
      child: Column(
        children: [
          GlassTopBar(
            title: widget.deckName,
            newCount: q?.newCount ?? 0,
            learnCount: q?.learnCount ?? 0,
            reviewCount: q?.reviewCount ?? 0,
            onBack: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(height: UgkSpace.l),
          Expanded(
            child: _loading
                ? const GlassLoading()
                : _card == null
                ? _Done(nextLearnDueMs: _nextLearnDueMs, onRefresh: _load)
                : GlassCard(
                    front: _front,
                    back: _back,
                    tag: _tag,
                    showBack: _showBack,
                    onTap: () => setState(() => _showBack = true),
                  ),
          ),
          if (_card != null) ...[
            const SizedBox(height: UgkSpace.l),
            GlassRatingBar(
              labels: _labels,
              visible: _showBack,
              onRate: _rate,
              onShowAnswer: () => setState(() => _showBack = true),
            ),
          ],
        ],
      ),
    );
  }
}

class _Done extends StatelessWidget {
  const _Done({required this.nextLearnDueMs, required this.onRefresh});

  final int? nextLearnDueMs;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    final due = nextLearnDueMs;
    final String sub;
    if (due == null) {
      sub = '今天这个卡组没有要学的了';
    } else {
      final mins = ((due - nowMs()) / 60000).ceil().clamp(1, 1440);
      sub = '还有学习中的卡片，约 $mins 分钟后到期';
    }
    return Center(
      child: GlassPanel(
        radius: UgkRadius.card,
        padding: const EdgeInsets.all(UgkSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '完成 🎉',
              style: TextStyle(
                color: color,
                fontSize: UgkText.cardFront,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: UgkSpace.s),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color.withValues(alpha: 0.6),
                fontSize: UgkText.button,
              ),
            ),
            if (due != null) ...[
              const SizedBox(height: UgkSpace.m),
              SizedBox(
                width: 120,
                child: GlassPillButton(label: '刷新', primary: true, onTap: onRefresh),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
