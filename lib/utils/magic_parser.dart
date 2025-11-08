import '../models/task_model.dart';

class MagicParser {
  static TaskModel? parseTask(String input, String userId) {
    // Debug: log input for tests
    // ignore: avoid_print
    print('MagicParser.parseTask called with input: "$input"');
    if (input.trim().isEmpty) return null;

    String workingInput = input;

    // Champs de contexte
    DateTime? startTime;
    String? location;
    List<String> attendees = [];

    // 1. Extraire les PERSONNES/ATTENDEES (Mentions @)
    final attendeesRegex = RegExp(r'@([\p{L}\d\s]+)', unicode: true);
    final attendeesMatches = attendeesRegex.allMatches(workingInput);
    for (var match in attendeesMatches) {
      final name = match.group(1)?.trim();
      if (name != null && name.isNotEmpty) {
        attendees.add(name);
      }
    }
    workingInput = workingInput.replaceAll(attendeesRegex, '').trim();

    // 2. Extraire le TEMPS PRÉCIS (Heure de Début)
    final timeRegex =
        RegExp(r'(?:à|vers)\s+(\d{1,2})h(\d{0,2})?', caseSensitive: false);
    final timeMatch = timeRegex.firstMatch(workingInput);

    // Date de base pour l'heure de début : Aujourd'hui
    DateTime baseDate = DateTime.now();

    if (timeMatch != null) {
      final hourStr = timeMatch.group(1);
      final minuteStr = timeMatch.group(2);
      final hour = int.tryParse(hourStr ?? '');
      final minute = int.tryParse(minuteStr ?? '0');

      if (hour != null && hour >= 0 && hour <= 23) {
        // Créer un DateTime basé sur la date de base à l'heure spécifiée
        startTime = baseDate.copyWith(
          hour: hour,
          minute: minute ?? 0,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        );
      }
    }
    if (timeMatch != null) {
      workingInput = workingInput.replaceFirst(timeMatch.group(0)!, '').trim();
    }

    // 3. Extraire le LIEU (Location)
    final locationRegex = RegExp(
        r'(?:au|à\sla|chez|dans\sle|en\s|sur\s)([\p{L}\s]+)',
        unicode: true,
        caseSensitive: false);
    final locationMatch = locationRegex.firstMatch(workingInput);

    if (locationMatch != null) {
      location = locationMatch.group(1)?.trim();
    }
    if (locationMatch != null) {
      workingInput =
          workingInput.replaceFirst(locationMatch.group(0)!, '').trim();
    }

    // --- Les champs existants (Priorité, Temps Estimé, Échéance) ---

    // 4. Extraire le TEMPS ESTIMÉ (en minutes)
    // ✅ Logique améliorée pour gérer les heures (h, heure(s)) et les minutes
    final timeMatchLegacy =
        RegExp(r'(\d+)\s*(min|m|h|heure(s)?)', caseSensitive: false)
            .firstMatch(workingInput);
    int estimatedTime = 30; // 30 minutes par défaut

    if (timeMatchLegacy != null) {
      final value = int.tryParse(timeMatchLegacy.group(1)!);
      final unit = timeMatchLegacy.group(2)!.toLowerCase();

      if (value != null) {
        if (unit.startsWith('h')) {
          // Si c'est 'h' ou 'heure(s)'
          estimatedTime = value * 60;
        } else {
          // Si c'est 'min', 'm', ou 'minute(s)'
          estimatedTime = value;
        }
        // Retirer le temps du workingInput
        workingInput =
            workingInput.replaceAll(timeMatchLegacy.group(0)!, '').trim();
      }
    }
    // Limites de sécurité
    if (estimatedTime < 5) estimatedTime = 5;
    if (estimatedTime > 480) estimatedTime = 480;

    // 5. Extraire la PRIORITÉ
    final priorityRegex = RegExp(r'prio(rité)?\s*(\d+)', caseSensitive: false);
    final priorityMatch = priorityRegex.firstMatch(workingInput);
    int priority = 2;
    if (priorityMatch != null) {
      priority = int.tryParse(priorityMatch.group(2) ?? '2') ?? 2;
      if (priority < 1) priority = 1;
      if (priority > 3) priority = 3;
    }
    workingInput = workingInput.replaceAll(priorityRegex, '').trim();

    // 6. Extraire l'ÉCHÉANCE (demain / aujourd'hui)
    DateTime? dueDate;
    if (workingInput.toLowerCase().contains('demain')) {
      dueDate = DateTime.now().add(const Duration(days: 1));
      workingInput = workingInput.toLowerCase().replaceAll('demain', '').trim();
    } else if (workingInput.toLowerCase().contains('aujourd\'hui')) {
      dueDate = DateTime.now();
      workingInput =
          workingInput.toLowerCase().replaceAll('aujourd\'hui', '').trim();
    }

    // Si une dueDate est trouvée, met à jour startTime pour être sur cette date
    if (dueDate != null && startTime != null) {
      startTime = DateTime(dueDate.year, dueDate.month, dueDate.day,
          startTime.hour, startTime.minute);
    }

    // Si une date d'échéance est trouvée, mais pas d'heure, la fixer à minuit
    if (dueDate != null && startTime == null) {
      dueDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    }

    // 7. Extraire le TITRE
    String title = workingInput.trim();

    if (title.isEmpty) {
      title = "Nouvelle Tâche Rapide";
    }

    // 8. Création du Modèle Final
    // ignore: avoid_print
    print('MagicParser returning task with title: "${workingInput.trim()}"');
    return TaskModel(
      taskId: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: title,
      description: input, // Garde l'entrée brute comme description/source
      createdAt: DateTime.now(),
      estimatedTime: estimatedTime,
      priority: priority,
      dueDate: dueDate,
      startTime: startTime,
      location: location,
      attendees: attendees.isEmpty ? null : attendees,
      sourceNlp: input,
    );
  }
}
