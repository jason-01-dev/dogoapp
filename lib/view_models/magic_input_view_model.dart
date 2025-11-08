// lib/view_models/magic_input_view_model.dart

import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import 'task_view_model.dart'; // Pour sauvegarder la tâche
import 'auth_view_model.dart'; // Pour récupérer l'ID utilisateur

class MagicInputViewModel extends ChangeNotifier {
  // L'état de l'analyse et de la création de la tâche
  bool _isAnalyzing = false;
  String? _analysisError;

  bool get isAnalyzing => _isAnalyzing;
  String? get analysisError => _analysisError;

  // --- 🧠 Simulation du Moteur NLP (Cœur de l'Intelligence) ---

  // Analyse le texte et crée un TaskModel avec les champs enrichis
  TaskModel _analyzeTextForTask(String input) {
    // 1. Définir les valeurs par défaut (si rien n'est trouvé)
    String title = input;
    int estimatedTime = 30; // 30 minutes par défaut
    int priority = 2; // Priorité normale par défaut
    DateTime? dueDate;

    // 2. Logique de SIMULATION NLP (extraction de l'information)

    // --- A. Recherche du TEMPS ESTIMÉ (minutes) ---
    final timeMatch =
        RegExp(r'(\d+)\s*(min|minute|heure|h)').firstMatch(input.toLowerCase());
    if (timeMatch != null) {
      final value = int.parse(timeMatch.group(1)!);
      final unit = timeMatch.group(2)!;
      if (unit.startsWith('h')) {
        estimatedTime = value * 60;
      } else {
        estimatedTime = value;
      }

      // Limiter le temps à un maximum raisonnable
      if (estimatedTime > 480) estimatedTime = 480;
      if (estimatedTime < 5) estimatedTime = 5;

      // Optionnel: Retirer le temps du titre pour le nettoyer
      title = title.replaceAll(timeMatch.group(0)!, '').trim();
    }

    // --- B. Recherche de la PRIORITÉ (mots-clés simples) ---
    if (input.toLowerCase().contains('urgent') ||
        input.toLowerCase().contains('bloquant')) {
      priority = 1; // Priorité MAX
    } else if (input.toLowerCase().contains('facultatif') ||
        input.toLowerCase().contains('rapide')) {
      priority = 3; // Priorité FAIBLE
    } else {
      priority = 2; // Priorité NORMALE
    }

    // --- C. Recherche de l'ÉCHÉANCE (date) ---
    // Logique très simplifiée: "aujourd'hui" ou "demain"
    if (input.toLowerCase().contains('aujourd\'hui') ||
        input.toLowerCase().contains('ajd')) {
      dueDate = DateTime.now()
          .add(const Duration(hours: 4)); // Date butoir dans quelques heures
      title = title.replaceAll('aujourd\'hui', '').replaceAll('ajd', '').trim();
    } else if (input.toLowerCase().contains('demain')) {
      final tomorrow = DateTime.now().add(const Duration(days: 1));

      // CORRECTION DU copyWith (ligne 61)
      dueDate = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        17, // Heure: 17h00
        0, // Minute: 00
      );

      title = title.replaceAll('demain', '').trim();
    }

    // S'assurer que le titre est nettoyé (première ligne non vide)
    title = title.split('\n').first.trim();
    if (title.isEmpty) title = "Nouvelle tâche générée";

    // 3. Construction du TaskModel
    // L'ID doit être unique, on utilise un timestamp simple pour la démo
    return TaskModel(
      taskId: DateTime.now().microsecondsSinceEpoch.toString(),
      userId: '', // Sera mis à jour par la méthode principale
      title: title,
      description: input, // Le texte brut est stocké comme description
      createdAt: DateTime.now(),
      status: 'todo',
      priority: priority,
      dueDate: dueDate,
      estimatedTime: estimatedTime,
      sourceNlp: input,
      // Les autres champs contextuels (startTime, location, attendees) sont null pour la simulation
    );
  }

  // --- 🚀 Méthode Publique : Analyser et Ajouter ---
  Future<void> analyzeAndAddTask({
    required String textInput,
    required TaskViewModel taskViewModel,
    required AuthViewModel authViewModel,
  }) async {
    if (textInput.isEmpty) return;

    _isAnalyzing = true;
    _analysisError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 700));

      TaskModel analyzedTask = _analyzeTextForTask(textInput);

      if (authViewModel.currentUser == null) {
        throw Exception(
            "Utilisateur non connecté. Impossible d'ajouter la tâche.");
      }

      TaskModel finalTask = analyzedTask.copyWith(
        userId: authViewModel.currentUser!.uid,
      );

      await taskViewModel.addTask(finalTask);

      debugPrint('✅ Tâche ajoutée par NLP simulé: ${finalTask.title}');
    } catch (e) {
      _analysisError =
          'Erreur lors de l\'analyse et de l\'ajout de la tâche : $e';
      debugPrint(_analysisError);
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }
}
