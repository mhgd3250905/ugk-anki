# M2：笔记、模板、生成卡片（纯 Dart，packages/core）

- 分支：`feat/m2-notes`（从最新 `main` 拉，main 已包含 M1）
- 预计：一个 agent 一次完成
- 依赖：M1 已合并。和 M3 互不依赖，可以两个 agent 同时做。
- 完成后打 tag：`m2-done`（开哥审核通过后才打，你不要打）

## 0. 背景（只读）
规格书第 2.1～2.4 节：笔记类型（字段 + 卡片模板）、笔记、由笔记生成卡片。本任务只写**纯逻辑**，不碰数据库（数据库在 M4）。
我们不追求和 Anki 数据库二进制兼容，所以 checksum 用简单的 FNV-1a，不用 sha1（core 不允许加依赖）。

## 1. 硬性规则
- 沿用 M1 的规则：`packages/core` 不能有任何 dependencies；不允许 `DateTime.now()`、无种子 `Random()`。
- 只新建本文件列出的文件，只修改 `lib/ugk_core.dart`（加 export）。**不要改 M1 的任何文件。**
- 测试文件本文件里**已经写好全文**，原样复制，一个字符都不要改。你的工作是写 `lib/src/notes/` 下的实现让测试全绿。
- 每个公开类和函数写一行中文 doc 注释。
- 写完每个文件跑 `dart format lib test`。

---

## 步骤 1：建文件
- [x] 1.1 建以下文件：
```
packages/core/lib/src/notes/fields.dart
packages/core/lib/src/notes/tags.dart
packages/core/lib/src/notes/guid.dart
packages/core/lib/src/notes/cloze.dart
packages/core/lib/src/notes/note_type.dart
packages/core/lib/src/notes/template.dart
packages/core/lib/src/notes/card_gen.dart
packages/core/test/notes_fields_test.dart
packages/core/test/notes_tags_guid_test.dart
packages/core/test/notes_template_test.dart
packages/core/test/notes_card_gen_test.dart
```
- [x] 1.2 在 `lib/ugk_core.dart` 末尾加 7 行 export（按字母序）：`src/notes/card_gen.dart`、`cloze.dart`、`fields.dart`、`guid.dart`、`note_type.dart`、`tags.dart`、`template.dart`。
- [x] 1.3 把第 9 节的 4 个测试文件原样复制进去。
- [x] 1.4 提交推送（此时测试会编译失败，正常）。

## 步骤 2：fields.dart
```dart
const String kFieldSep = '\x1f';
String joinFields(List<String> fields);      // fields.join(kFieldSep)
List<String> splitFields(String joined);     // joined.split(kFieldSep)；'' 返回 ['']
String stripHtml(String html);
bool fieldIsNonEmpty(String value);          // stripHtml(value).trim().isNotEmpty
int fieldChecksum(String field);
```
`stripHtml` 按顺序做，**不要 trim**：
1. 删掉所有 HTML 注释：正则 `RegExp(r'<!--.*?-->', dotAll: true)` 替换成 `''`
2. 删掉所有标签：正则 `RegExp(r'<[^>]*>')` 替换成 `''`（所以 `<img ...>` 也会被删，图片字段算空）
3. 依次替换实体：`&nbsp;`→空格，`&lt;`→`<`，`&gt;`→`>`，`&quot;`→`"`，`&#39;`→`'`，**最后** `&amp;`→`&`

`fieldChecksum`：FNV-1a 32 位。
```dart
var hash = 0x811c9dc5;
for (final b in utf8.encode(stripHtml(field).trim())) {   // import 'dart:convert';
  hash ^= b;
  hash = (hash * 0x01000193) & 0xffffffff;
}
return hash;
```
- [ ] 2.1 实现，`dart test test/notes_fields_test.dart` 全绿。提交推送。

## 步骤 3：tags.dart 和 guid.dart
```dart
List<String> parseTags(String tags);
String joinTags(List<String> tags);
bool hasTag(String tags, String tag);
String addTag(String tags, String tag);
String guidFromInt(int value);
```
- `parseTags`：按 `RegExp(r'\s+')` 拆分，丢掉空串；忽略大小写去重，保留**第一次出现**的写法，保持原顺序。
- `joinTags`：空列表返回 `''`，否则返回 `' ' + tags.join(' ') + ' '`（前后各一个空格，和 Anki 一样）。
- `hasTag`：`parseTags(tags)` 里有没有和 `tag` 忽略大小写相等的。
- `addTag`：先 `parseTags`，如果没有（忽略大小写）就加到末尾，最后 `joinTags`。
- `guidFromInt`：base91 编码。字符表（91 个字符，照抄这一行 Dart 代码）：
```dart
const String _base91 =
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!#\$%&()*+,-./:;<=>?@[]^_`{|}~';
```
  规则：value < 0 抛 `ArgumentError`；value == 0 返回 `'a'`；否则反复 `value % 91` 取字符、`value ~/= 91`，最后把取到的字符**倒序**拼起来。
- [ ] 3.1 实现，`dart test test/notes_tags_guid_test.dart` 全绿。提交推送。

## 步骤 4：cloze.dart
```dart
Set<int> clozeNumbers(String text);
String renderCloze(String text, int ord, {required bool answer});
```
统一用这个正则（照抄）：`RegExp(r'\{\{c(\d+)::(.*?)(?:::(.*?))?\}\}', dotAll: true)`
- group(1) = 编号 N，group(2) = 原文，group(3) = 提示（可能为 null）。
- `clozeNumbers`：所有匹配的 N，只保留 N >= 1。
- `renderCloze`（ord 是 1 开始的编号），用 `replaceAllMapped` 逐个替换：
  - N != ord → 原文
  - N == ord 且 answer == false → `<span class="cloze">[提示]</span>`，没有提示时用 `...`
  - N == ord 且 answer == true → `<span class="cloze">原文</span>`

## 步骤 5：note_type.dart
照抄以下定义（字段、构造函数、默认值都不要改）：
```dart
enum NoteKind { standard, cloze } // 存库 0, 1

class NoteField { final String name; final int ord; const NoteField(this.name, this.ord); }

class CardTemplate {
  final String name; final int ord; final String qfmt; final String afmt;
  const CardTemplate({required this.name, required this.ord, required this.qfmt, required this.afmt});
}

class NoteType {
  final int id; final String name; final NoteKind kind;
  final List<NoteField> fields; final List<CardTemplate> templates;
  final String css; final int sortFieldIdx;
  const NoteType({required this.id, required this.name, required this.kind,
    required this.fields, required this.templates, required this.css, this.sortFieldIdx = 0});
  List<String> get fieldNames => [for (final f in fields) f.name];
}

const String kDefaultCss =
    '.card { font-family: sans-serif; font-size: 20px; text-align: center; }\n'
    '.cloze { font-weight: bold; color: #0a84ff; }';

NoteType basicNoteType(int id);          // 见下表
NoteType basicReversedNoteType(int id);
NoteType clozeNoteType(int id);
```
| 函数 | name | kind | fields | templates（name / ord / qfmt / afmt） |
|---|---|---|---|---|
| basicNoteType | `Basic` | standard | Front(0), Back(1) | `Card 1` / 0 / `{{Front}}` / `{{FrontSide}}<hr id=answer>{{Back}}` |
| basicReversedNoteType | `Basic (and reversed card)` | standard | Front(0), Back(1) | 同上 Card 1；再加 `Card 2` / 1 / `{{Back}}` / `{{FrontSide}}<hr id=answer>{{Front}}` |
| clozeNoteType | `Cloze` | cloze | Text(0), Back Extra(1) | `Cloze` / 0 / `{{cloze:Text}}` / `{{cloze:Text}}<br>{{Back Extra}}` |

三个的 css 都是 `kDefaultCss`，sortFieldIdx 都是 0。
- [ ] 5.1 步骤 4、5 写完，提交推送。

## 步骤 6：template.dart（模板渲染，本任务最难的一步）
```dart
class RenderResult {
  final String text;
  final bool usedNonEmptyField;   // 是否真正输出过至少一个非空字段（FrontSide 不算）
  const RenderResult(this.text, this.usedNonEmptyField);
}

RenderResult renderTemplate(String template, Map<String, String> fields,
    {String? frontSide, int? clozeOrd, bool answer = false});
```
**做法（照这个写）：**
1. 切词：用 `RegExp(r'\{\{(.*?)\}\}', dotAll: true)` 找出所有 `{{...}}`。标签之间的普通文字是「文本词」，标签里面的内容**先 trim**，是「标签词」。
2. 用一个下标 `i` 从头走词表，写一个递归函数 `String walk(String? closing)`，外加一个变量 `bool used = false`：
   - 文本词 → 原样输出。
   - 以 `/` 开头的标签 → 去掉 `/` 再 trim 得到名字。如果 `closing == null` 或名字 != closing，抛 `FormatException('模板格式错误')`；否则返回当前已输出的内容（区段结束）。
   - 以 `#` 或 `^` 开头 → 名字 = 去掉首字符再 trim。`nonEmpty = fieldIsNonEmpty(fields[名字] ?? '')`。`#` 时 show = nonEmpty，`^` 时 show = !nonEmpty。**先记下 `saved = used`**，递归 `inner = walk(名字)`。show 为 true 就输出 inner；为 false 就不输出，并且 `used = saved`（隐藏区段里的字段不算 used）。
   - `FrontSide` → 输出 `frontSide ?? ''`，不改 used。
   - 以 `cloze:` 开头 → 名字 = 后面部分 trim，value = `fields[名字] ?? ''`：
     - clozeOrd == null：输出 value；`fieldIsNonEmpty(value)` 时 used = true
     - 否则：输出 `renderCloze(value, clozeOrd, answer: answer)`；`clozeNumbers(value).contains(clozeOrd)` 时 used = true
   - 以 `text:` 开头 → 名字 = 后面部分 trim，输出 `stripHtml(value)`；value 非空时 used = true
   - 其他 → 当字段名，输出 `fields[名字] ?? ''`（不存在的字段输出空）；value 非空时 used = true
   - 词表走完时如果 `closing != null`（区段没闭合），抛 `FormatException('模板格式错误')`。
3. `renderTemplate` 返回 `RenderResult(walk(null), used)`。
- [ ] 6.1 实现，`dart test test/notes_template_test.dart` 全绿。提交推送。

## 步骤 7：card_gen.dart
```dart
List<int> generateCardOrds(NoteType type, List<String> fields);
class RenderedCard { final String question; final String answer; const RenderedCard(this.question, this.answer); }
RenderedCard renderCard(NoteType type, List<String> fields, int ord);
String sortFieldValue(NoteType type, List<String> fields);
```
- 共用：`fields.length != type.fields.length` 时抛 `ArgumentError`。字段 map = `{字段名: fields[字段 ord]}`。
- `generateCardOrds`（返回升序）：
  - cloze 类型：所有字段的 `clozeNumbers` 求并集，每个 N 变成 `N - 1`，排序返回。没有 cloze 返回 `[]`。
  - standard 类型：对每个模板 `renderTemplate(t.qfmt, map)`，`usedNonEmptyField == true` 的收集 `t.ord`。
- `renderCard`：
  - cloze：用 `templates[0]`；q = `renderTemplate(qfmt, map, clozeOrd: ord + 1)`；a = `renderTemplate(afmt, map, clozeOrd: ord + 1, answer: true, frontSide: q.text)`。
  - standard：找 `t.ord == ord` 的模板，找不到抛 `ArgumentError`；q = `renderTemplate(qfmt, map)`；a = `renderTemplate(afmt, map, frontSide: q.text, answer: true)`。
  - 返回 `RenderedCard(q.text, a.text)`。
- `sortFieldValue` = `stripHtml(fields[type.sortFieldIdx]).trim()`。
- [ ] 7.1 实现，`dart test test/notes_card_gen_test.dart` 全绿。提交推送。

## 步骤 8：总检查
- [ ] 8.1 `cd packages/core && dart format lib test && dart analyze && dart test`：analyze 0 issue，全部测试通过（包括 M1 的）。贴最后一行。
- [ ] 8.2 提交推送，开 Draft PR `M2 笔记与模板` 到 main，正文贴验收清单。

## 9. 测试文件全文（原样复制，不许改）

```dart
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
```

```dart
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
```

```dart
// packages/core/test/notes_template_test.dart
import 'package:test/test.dart';
import 'package:ugk_core/ugk_core.dart';

void main() {
  const f = {'Front': 'apple', 'Back': '苹果', 'Empty': '', 'Html': '<b>hi</b>'};

  group('renderTemplate 基本替换', () {
    test('字段替换', () {
      final r = renderTemplate('Q: {{Front}}', f);
      expect(r.text, 'Q: apple');
      expect(r.usedNonEmptyField, true);
    });
    test('标签内空格会 trim', () {
      expect(renderTemplate('{{ Front }}', f).text, 'apple');
    });
    test('不存在的字段输出空', () {
      final r = renderTemplate('[{{Nope}}]', f);
      expect(r.text, '[]');
      expect(r.usedNonEmptyField, false);
    });
    test('空字段不算 used', () {
      final r = renderTemplate('Q: {{Empty}}', f);
      expect(r.text, 'Q: ');
      expect(r.usedNonEmptyField, false);
    });
    test('没有任何标签', () {
      final r = renderTemplate('static text', f);
      expect(r.text, 'static text');
      expect(r.usedNonEmptyField, false);
    });
    test('text: 过滤器', () {
      expect(renderTemplate('{{text:Html}}', f).text, 'hi');
      expect(renderTemplate('{{Html}}', f).text, '<b>hi</b>');
    });
    test('FrontSide', () {
      final r = renderTemplate('{{FrontSide}}<hr id=answer>{{Back}}', f,
          frontSide: 'apple');
      expect(r.text, 'apple<hr id=answer>苹果');
      expect(renderTemplate('{{FrontSide}}', f).text, '');
      expect(
          renderTemplate('{{FrontSide}}', f, frontSide: 'x').usedNonEmptyField,
          false);
    });
  });

  group('区段', () {
    test('#字段非空才显示', () {
      expect(renderTemplate('{{#Back}}B={{Back}}{{/Back}}', f).text, 'B=苹果');
      expect(renderTemplate('{{#Empty}}E={{Empty}}{{/Empty}}', f).text, '');
    });
    test('^字段为空才显示', () {
      expect(renderTemplate('{{^Empty}}none{{/Empty}}', f).text, 'none');
      expect(renderTemplate('{{^Back}}none{{/Back}}', f).text, '');
    });
    test('嵌套', () {
      const t = '{{#Front}}F{{#Back}}B{{/Back}}{{^Empty}}e{{/Empty}}{{/Front}}';
      expect(renderTemplate(t, f).text, 'FBe');
    });
    test('隐藏区段里的字段不算 used', () {
      final r = renderTemplate('{{#Empty}}{{Front}}{{/Empty}}', f);
      expect(r.text, '');
      expect(r.usedNonEmptyField, false);
    });
    test('不存在的字段当空字段', () {
      expect(renderTemplate('{{#Nope}}x{{/Nope}}{{^Nope}}y{{/Nope}}', f).text,
          'y');
    });
    test('格式错误', () {
      expect(() => renderTemplate('{{#Front}}x', f), throwsFormatException);
      expect(() => renderTemplate('x{{/Front}}', f), throwsFormatException);
      expect(() => renderTemplate('{{#Front}}x{{/Back}}', f),
          throwsFormatException);
    });
  });

  group('cloze', () {
    test('clozeNumbers', () {
      expect(clozeNumbers('no cloze'), <int>{});
      expect(clozeNumbers('{{c1::a}} {{c2::b}} {{c1::c}}'), {1, 2});
      expect(clozeNumbers('{{c3::x::hint}}'), {3});
      expect(clozeNumbers('{{c0::x}}'), <int>{});
      expect(clozeNumbers('{{c12::x}}'), {12});
    });
    test('renderCloze 正面', () {
      const t = 'The {{c1::cat}} sat on the {{c2::mat::thing}}.';
      expect(renderCloze(t, 1, answer: false),
          'The <span class="cloze">[...]</span> sat on the mat.');
      expect(renderCloze(t, 2, answer: false),
          'The cat sat on the <span class="cloze">[thing]</span>.');
    });
    test('renderCloze 背面', () {
      const t = 'The {{c1::cat}} sat on the {{c2::mat::thing}}.';
      expect(renderCloze(t, 1, answer: true),
          'The <span class="cloze">cat</span> sat on the mat.');
      expect(renderCloze(t, 2, answer: true),
          'The cat sat on the <span class="cloze">mat</span>.');
    });
    test('同编号出现两次都挖空', () {
      expect(renderCloze('{{c1::a}}-{{c1::b}}', 1, answer: false),
          '<span class="cloze">[...]</span>-<span class="cloze">[...]</span>');
    });
    test('cloze: 过滤器', () {
      const m = {'Text': 'x {{c1::y}} {{c2::z}}'};
      final q = renderTemplate('{{cloze:Text}}', m, clozeOrd: 2);
      expect(q.text, 'x y <span class="cloze">[...]</span>');
      expect(q.usedNonEmptyField, true);
      final missing = renderTemplate('{{cloze:Text}}', m, clozeOrd: 3);
      expect(missing.text, 'x y z');
      expect(missing.usedNonEmptyField, false);
      expect(renderTemplate('{{cloze:Text}}', m).text, 'x {{c1::y}} {{c2::z}}');
    });
  });
}
```

```dart
// packages/core/test/notes_card_gen_test.dart
import 'package:test/test.dart';
import 'package:ugk_core/ugk_core.dart';

void main() {
  final basic = basicNoteType(1);
  final reversed = basicReversedNoteType(2);
  final cloze = clozeNoteType(3);

  group('内置笔记类型', () {
    test('Basic', () {
      expect(basic.name, 'Basic');
      expect(basic.kind, NoteKind.standard);
      expect(basic.fieldNames, ['Front', 'Back']);
      expect(basic.templates.length, 1);
      expect(basic.templates[0].qfmt, '{{Front}}');
      expect(basic.templates[0].afmt, '{{FrontSide}}<hr id=answer>{{Back}}');
    });
    test('Basic (and reversed card)', () {
      expect(reversed.name, 'Basic (and reversed card)');
      expect(reversed.templates.map((t) => t.name), ['Card 1', 'Card 2']);
      expect(reversed.templates[1].qfmt, '{{Back}}');
      expect(
          reversed.templates[1].afmt, '{{FrontSide}}<hr id=answer>{{Front}}');
    });
    test('Cloze', () {
      expect(cloze.kind, NoteKind.cloze);
      expect(cloze.fieldNames, ['Text', 'Back Extra']);
      expect(cloze.templates.single.qfmt, '{{cloze:Text}}');
      expect(cloze.templates.single.afmt, '{{cloze:Text}}<br>{{Back Extra}}');
    });
  });

  group('generateCardOrds', () {
    test('Basic', () {
      expect(generateCardOrds(basic, ['apple', '苹果']), [0]);
      expect(generateCardOrds(basic, ['', '苹果']), <int>[]);
      expect(generateCardOrds(basic, ['<br>', '苹果']), <int>[]);
    });
    test('Basic reversed', () {
      expect(generateCardOrds(reversed, ['apple', '苹果']), [0, 1]);
      expect(generateCardOrds(reversed, ['apple', '']), [0]);
      expect(generateCardOrds(reversed, ['', '苹果']), [1]);
      expect(generateCardOrds(reversed, ['', '']), <int>[]);
    });
    test('Cloze', () {
      expect(generateCardOrds(cloze, ['{{c1::a}} {{c3::b}}', '']), [0, 2]);
      expect(generateCardOrds(cloze, ['{{c2::a}}', '{{c1::extra}}']), [0, 1]);
      expect(generateCardOrds(cloze, ['no cloze', '']), <int>[]);
    });
    test('字段数量不对', () {
      expect(() => generateCardOrds(basic, ['only one']), throwsArgumentError);
    });
    test('条件模板', () {
      const t = NoteType(
        id: 9,
        name: 'Optional reverse',
        kind: NoteKind.standard,
        fields: [
          NoteField('Front', 0),
          NoteField('Back', 1),
          NoteField('Add Reverse', 2)
        ],
        templates: [
          CardTemplate(
              name: 'Card 1', ord: 0, qfmt: '{{Front}}', afmt: '{{Back}}'),
          CardTemplate(
              name: 'Card 2',
              ord: 1,
              qfmt: '{{#Add Reverse}}{{Back}}{{/Add Reverse}}',
              afmt: '{{Front}}'),
        ],
        css: '',
      );
      expect(generateCardOrds(t, ['a', 'b', '']), [0]);
      expect(generateCardOrds(t, ['a', 'b', 'y']), [0, 1]);
    });
  });

  group('renderCard', () {
    test('Basic 正反面', () {
      final c = renderCard(basic, ['apple', '苹果'], 0);
      expect(c.question, 'apple');
      expect(c.answer, 'apple<hr id=answer>苹果');
    });
    test('Basic reversed 第二张', () {
      final c = renderCard(reversed, ['apple', '苹果'], 1);
      expect(c.question, '苹果');
      expect(c.answer, '苹果<hr id=answer>apple');
    });
    test('Cloze', () {
      final c = renderCard(
          cloze, ['The {{c1::cat}} sat {{c2::here::where}}', 'extra'], 1);
      expect(c.question, 'The cat sat <span class="cloze">[where]</span>');
      expect(c.answer, 'The cat sat <span class="cloze">here</span><br>extra');
    });
    test('不存在的 ord', () {
      expect(() => renderCard(basic, ['a', 'b'], 5), throwsArgumentError);
    });
  });

  group('sortFieldValue', () {
    test('取 sortFieldIdx 字段去 HTML 并 trim', () {
      expect(sortFieldValue(basic, [' <b>Apple</b> ', 'x']), 'Apple');
    });
  });
}
```

---

## 验收清单（汇报时原样贴，逐项勾选）
- [ ] `pubspec.yaml` 没变，仍然没有任何 dependencies
- [ ] 没有修改 M1 的任何文件（`git diff main --stat` 里只有 `lib/src/notes/`、4 个 `test/notes_*`、`lib/ugk_core.dart`、本任务文件）
- [ ] 4 个测试文件和本文件第 9 节一字不差
- [ ] `dart analyze` 0 issue，`dart test` 全部通过（贴最后一行）
- [ ] Draft PR 已开，未合并

## 问题记录
（照做跑不通时写在这里：哪一步、做了什么、报错原文）
