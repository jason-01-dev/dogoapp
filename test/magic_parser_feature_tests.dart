import 'package:flutter_test/flutter_test.dart';
import 'package:dogo_ai_assistant/utils/magic_parser.dart';

void main() {
  test('parses attendees with @mention', () {
    final t = MagicParser.parseTask('Rencontrer @Jean pour suivi', 'u1');
    expect(t, isNotNull);
    expect(t!.attendees, isNotNull);
    expect(t.attendees, contains('Jean'));
  });

  test('parses precise start time with "vers 14h30"', () {
    final t = MagicParser.parseTask('Réunion vers 14h30', 'u1');
    expect(t, isNotNull);
    expect(t!.startTime, isNotNull);
    expect(t.startTime!.hour, equals(14));
    expect(t.startTime!.minute, equals(30));
  });

  test('parses estimated time like "45min"', () {
    final t = MagicParser.parseTask('Préparation 45min', 'u1');
    expect(t, isNotNull);
    expect(t!.estimatedTime, equals(45));
  });

  test('parses priority token prioN', () {
    final t = MagicParser.parseTask('Tâche prio3', 'u1');
    expect(t, isNotNull);
    expect(t!.priority, equals(3));
  });

  test('parses location after "au"', () {
    final t = MagicParser.parseTask('Visite au bureau', 'u1');
    expect(t, isNotNull);
    expect(t!.location, isNotNull);
    expect(t.location!.toLowerCase(), contains('bureau'));
  });

  test('parses due date "demain"', () {
    final t = MagicParser.parseTask('Relire demain', 'u1');
    expect(t, isNotNull);
    expect(t!.dueDate, isNotNull);
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    expect(t.dueDate!.day, equals(tomorrow.day));
  });
}
