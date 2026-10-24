// packages/core/test/queue_day_test.dart
import 'package:test/test.dart';
import 'package:ugk_core/ugk_core.dart';

void main() {
  // collection 创建于 2026-10-01 10:00 上海时间（= 2026-10-01 02:00 UTC）
  const created = 1790820000000;

  group('dayNumber（上海 +480，04:00 分界）', () {
    test('创建当刻是第 0 天', () {
      expect(
          dayNumber(
              nowMs: created,
              collectionCreatedMs: created,
              utcOffsetMinutes: 480),
          0);
    });
    test('次日 03:59 上海时间还是第 0 天', () {
      // 2026-10-01 19:59 UTC = 2026-10-02 03:59 上海
      expect(
          dayNumber(
              nowMs: 1790884740000,
              collectionCreatedMs: created,
              utcOffsetMinutes: 480),
          0);
    });
    test('次日 04:00 上海时间变成第 1 天', () {
      expect(
          dayNumber(
              nowMs: 1790884800000,
              collectionCreatedMs: created,
              utcOffsetMinutes: 480),
          1);
    });
    test('2026-10-24 18:00 上海时间是第 23 天', () {
      expect(
          dayNumber(
              nowMs: 1792836000000,
              collectionCreatedMs: created,
              utcOffsetMinutes: 480),
          23);
    });
    test('比创建还早一天得 -1', () {
      expect(
          dayNumber(
              nowMs: 1790794800000,
              collectionCreatedMs: created,
              utcOffsetMinutes: 480),
          -1);
    });
    test('rolloverHour = 0 时午夜分界', () {
      // 2026-10-01 16:00 UTC = 2026-10-02 00:00 上海
      expect(
          dayNumber(
              nowMs: 1790870400000,
              collectionCreatedMs: created,
              utcOffsetMinutes: 480,
              rolloverHour: 0),
          1);
      expect(
          dayNumber(
              nowMs: 1790870399999,
              collectionCreatedMs: created,
              utcOffsetMinutes: 480,
              rolloverHour: 0),
          0);
    });
  });

  test('dayNumber 洛杉矶 -420', () {
    // 创建 2026-10-01 15:00 UTC（洛杉矶 08:00）；现在 2026-10-24 10:00 UTC（洛杉矶 03:00，还没到 04:00）
    expect(
        dayNumber(
            nowMs: 1792836000000,
            collectionCreatedMs: 1790866800000,
            utcOffsetMinutes: -420),
        22);
  });

  group('dayCutoffMs', () {
    test('第 0 天在 2026-10-02 04:00 上海时间结束', () {
      expect(
          dayCutoffMs(
              today: 0, collectionCreatedMs: created, utcOffsetMinutes: 480),
          1790884800000);
    });
    test('第 23 天在 2026-10-25 04:00 上海时间结束', () {
      expect(
          dayCutoffMs(
              today: 23, collectionCreatedMs: created, utcOffsetMinutes: 480),
          1792872000000);
    });
  });
}
