import 'package:flutter_test/flutter_test.dart';
import 'package:dogo_ai_assistant/utils/magic_parser.dart';

void main() {
  test('MagicParser basic returns non-null for simple text', () {
    final simple = MagicParser.parseTask('Hello world', 'u1');
    expect(simple, isNotNull);
    expect(simple!.title.toLowerCase(), contains('hello'));
  });
}
