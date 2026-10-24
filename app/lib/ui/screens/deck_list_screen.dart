import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:ugk_data/ugk_data.dart';

import '../../data/app_files.dart';
import '../../data/clock.dart';
import '../../data/repo_scope.dart';
import '../glass/glass_icon_button.dart';
import '../glass/glass_kit.dart';
import '../glass/glass_page.dart';
import '../labels.dart';
import '../theme/tokens.dart';
import 'add_note_screen.dart';
import 'import_screen.dart';
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
    await repo.ensureParentDecks(nowMs: now);
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
    final name = await showGlassPrompt(
      context,
      title: '新建卡组',
      hint: '例如 英语::口语（:: 表示下一级）',
      confirmLabel: '创建',
    );
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty || !mounted) return;
    try {
      await RepoScope.of(context).createDeck(trimmed, nowMs: nowMs());
    } on StateError {
      if (mounted) {
        showGlassToast(context, '卡组「${deckLabel(trimmed)}」已存在', warn: true);
      }
    }
    _reload();
  }

  Future<void> _more() async {
    final i = await showGlassActions(
      context,
      title: '数据',
      actions: const [
        GlassAction(Icons.file_download_outlined, '导入 CSV / TXT'),
        GlassAction(Icons.file_upload_outlined, '导出全部笔记为 TXT'),
        GlassAction(Icons.save_outlined, '备份整个库'),
        GlassAction(Icons.restore, '从备份恢复', danger: true),
      ],
    );
    if (!mounted || i == null) return;
    try {
      switch (i) {
        case 0:
          await _importCsv();
        case 1:
          await _exportCsv();
        case 2:
          await _backup();
        case 3:
          await _restore();
      }
    } on FormatException catch (e) {
      if (mounted) showGlassToast(context, e.message, warn: true);
    } catch (_) {
      if (mounted) showGlassToast(context, '没能完成，请再试一次', warn: true);
    }
    _reload();
  }

  Future<void> _importCsv() async {
    final file = await AppFiles.instance.pick();
    if (file == null || !mounted) return;
    final text = utf8.decode(file.bytes, allowMalformed: true);
    if (_looksBinary(text)) {
      showGlassToast(context, '这不是文本文件，请选 CSV 或 TXT', warn: true);
      return;
    }
    final table = parseCsv(text);
    if (table.rows.isEmpty) {
      showGlassToast(context, '文件里没有可导入的内容', warn: true);
      return;
    }
    final first = _decks?.firstOrNull?.deck.id ?? kDefaultDeckId;
    final result = await Navigator.of(context).push<ImportResult>(
      MaterialPageRoute(
        builder: (_) => ImportScreen(
          table: table,
          fileName: file.name,
          initialDeckId: first,
        ),
      ),
    );
    if (result == null || !mounted) return;
    final skipped = [
      if (result.duplicates > 0) '跳过重复 ${result.duplicates}',
      if (result.empty > 0) '空白 ${result.empty}',
    ];
    showGlassToast(
      context,
      '导入 ${result.notes} 条笔记（${result.cards} 张卡片）'
      '${skipped.isEmpty ? '' : '，${skipped.join('、')}'}',
      warn: result.notes == 0,
    );
  }

  Future<void> _exportCsv() async {
    final text = await RepoScope.of(context).exportCsv();
    final count = parseCsv(text).rows.length;
    if (count == 0) {
      if (mounted) showGlassToast(context, '还没有笔记可以导出', warn: true);
      return;
    }
    final saved = await AppFiles.instance.save(
      'ugk-anki-${fileStamp()}.txt',
      utf8.encode(text),
      'text/plain',
    );
    if (saved && mounted) showGlassToast(context, '已导出 $count 条笔记');
  }

  Future<void> _backup() async {
    final json = await RepoScope.of(context).backupJson(nowMs: nowMs());
    final saved = await AppFiles.instance.save(
      'ugk-anki-backup-${fileStamp()}.json',
      utf8.encode(json),
      'application/json',
    );
    if (saved && mounted) showGlassToast(context, '备份已保存');
  }

  Future<void> _restore() async {
    final file = await AppFiles.instance.pick();
    if (file == null || !mounted) return;
    final ok = await showGlassConfirm(
      context,
      title: '从备份恢复？',
      message: '当前所有卡组、卡片和复习记录都会被「${file.name}」覆盖，无法撤销。建议先备份一次。',
      confirmLabel: '覆盖恢复',
      danger: true,
    );
    if (!ok || !mounted) return;
    await RepoScope.of(context)
        .restoreJson(utf8.decode(file.bytes, allowMalformed: true));
    if (mounted) showGlassToast(context, '已从备份恢复');
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
                const SizedBox(width: UgkSpace.s),
                GlassIconButton(icon: Icons.more_horiz, onTap: _more),
              ],
            ),
          ),
          const SizedBox(height: UgkSpace.m),
          const _CountHeader(),
          const SizedBox(height: UgkSpace.xs),
          Expanded(
            child: decks == null
                ? const GlassLoading()
                : ListView.separated(
                    itemCount: decks.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: UgkSpace.ratingGap),
                    itemBuilder: (_, i) => _DeckTile(
                      summary: decks[i],
                      onTap: () => _open(decks[i]),
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
                    deckLabel(parts.last),
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

/// 三列数字的说明：新卡 / 在学 / 待复习
class _CountHeader extends StatelessWidget {
  const _CountHeader();

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface
        .withValues(alpha: 0.5);
    Widget cell(String text, Color dot) => SizedBox(
      width: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              color: muted,
              fontSize: UgkText.tag,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UgkSpace.m),
      child: Row(
        children: [
          const Spacer(),
          cell('新卡', UgkColors.newBlue),
          cell('在学', UgkColors.learnRed),
          cell('待复习', UgkColors.reviewGreen),
        ],
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
    final muted = Theme.of(context).colorScheme.onSurface
        .withValues(alpha: 0.25);
    return SizedBox(
      width: 48,
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

/// 前 4K 字符里有 NUL 或大量乱码时认为不是文本
bool _looksBinary(String text) {
  final head = text.length > 4096 ? text.substring(0, 4096) : text;
  if (head.contains('\u0000')) return true;
  final bad = '\uFFFD'.allMatches(head).length;
  return head.isNotEmpty && bad * 20 > head.length;
}
