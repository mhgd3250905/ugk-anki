// packages/core/test/notes_tags_guid_test.dart
import 'package:test/test.dart';
import 'package:ugk_core/ugk_core.dart';

void main() {
  group('tags', () {
    test('parseTags', () {
      expect(parseTags(''), <String>[]);
      expect(parseTags('   '), <String>[]);
      expect(parseTags(' a b '), ['a', 'b']);
      expect(parseTags('a\tb\n c'), ['a', 'b', 'c']);
      expect(parseTags('Verb verb VERB noun'), ['Verb', 'noun']);
    });
    test('joinTags', () {
      expect(joinTags([]), '');
      expect(joinTags(['a']), ' a ');
      expect(joinTags(['a', 'b']), ' a b ');
    });
    test('hasTag / addTag', () {
      expect(hasTag(' a leech ', 'Leech'), true);
      expect(hasTag(' a ', 'leech'), false);
      expect(addTag('', 'leech'), ' leech ');
      expect(addTag(' a b ', 'leech'), ' a b leech ');
      expect(addTag(' a LEECH ', 'leech'), ' a LEECH ');
      expect(addTag('a  a b', 'c'), ' a b c ');
    });
  });

  group('guidFromInt', () {
    test('base91 编码', () {
      expect(guidFromInt(0), 'a');
      expect(guidFromInt(1), 'b');
      expect(guidFromInt(90), '~');
      expect(guidFromInt(91), 'ba');
      expect(guidFromInt(92), 'bb');
      expect(guidFromInt(8280), '~~');
      expect(guidFromInt(8281), 'baa');
      expect(guidFromInt(1234567890), 'saAKk');
      expect(guidFromInt(9223372036854775807), 'vYHz/gPN,h');
    });
    test('负数抛错', () {
      expect(() => guidFromInt(-1), throwsArgumentError);
    });
  });
}
