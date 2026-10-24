// packages/core/test/notes_fields_test.dart
import 'package:test/test.dart';
import 'package:ugk_core/ugk_core.dart';

void main() {
  group('joinFields / splitFields', () {
    test('拼接和拆分', () {
      expect(joinFields(['a', 'b', 'c']), 'a\x1fb\x1fc');
      expect(splitFields('a\x1fb\x1fc'), ['a', 'b', 'c']);
      expect(splitFields(joinFields(['', 'x', ''])), ['', 'x', '']);
      expect(splitFields(''), ['']);
    });
  });

  group('stripHtml', () {
    test('去标签和实体', () {
      expect(stripHtml('<b>bold</b> text'), 'bold text');
      expect(stripHtml('a<br>b<br/>c'), 'abc');
      expect(stripHtml('<div class="x">hi</div>'), 'hi');
      expect(stripHtml('a<!-- note -->b'), 'ab');
      expect(stripHtml('1 &lt; 2 &amp;&amp; 3 &gt; 2'), '1 < 2 && 3 > 2');
      expect(stripHtml('&quot;q&quot; &#39;s&#39;'), '"q" \'s\'');
      expect(stripHtml('a&nbsp;b'), 'a b');
      expect(stripHtml('&amp;lt;'), '&lt;');
      expect(stripHtml('  keep spaces  '), '  keep spaces  ');
    });
  });

  group('fieldIsNonEmpty', () {
    test('判断非空', () {
      expect(fieldIsNonEmpty(''), false);
      expect(fieldIsNonEmpty('   '), false);
      expect(fieldIsNonEmpty('<br>'), false);
      expect(fieldIsNonEmpty('&nbsp;'), false);
      expect(fieldIsNonEmpty('<b> </b>'), false);
      expect(fieldIsNonEmpty('x'), true);
      expect(fieldIsNonEmpty('<img src="a.png">'), false);
    });
  });

  group('fieldChecksum', () {
    test('FNV-1a 32 位', () {
      expect(fieldChecksum(''), 2166136261);
      expect(fieldChecksum('hello'), 1335831723);
      expect(fieldChecksum('Hello'), 4116459851);
      expect(fieldChecksum(' <b>hello</b> '), 1335831723);
      expect(fieldChecksum('abandon'), 3402497766);
      expect(fieldChecksum('你好'), 2257816995);
      expect(fieldChecksum('a&amp;b'), 1084213332);
    });
  });
}
