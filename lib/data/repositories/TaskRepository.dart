// ignore_for_file: file_names

import 'package:dogo_ai_assistant/models/task_model.dart';

// Classe qui simule la connexion à la source de données (Firestore)
class TaskRepository {
  // Fausses données RÊALISTES pour simuler la base de données
  final List<TaskModel> _mockTasks = [
    // Tâche 1: PRIORITÉ MAXIMALE (Urgence du jour)
    TaskModel(
      taskId: 't1',
      userId: 'user1',
      title: 'Appel client : valider le budget du projet Alpha',
      description: 'Nécessite une préparation de 30 min. Appel à 15h00.',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      status: 'todo',
      priority: 1, // HAUTE
      dueDate: DateTime.now().add(const Duration(hours: 3)), // Échéance dans 3h
      estimatedTime: 90, // 90 minutes (1h30)
      sourceNlp: 'Appeler client budget Alpha aujourd\'hui 15h',

      // CHAMPS DE CONTEXTE ENRICHI :
      startTime: DateTime.now().copyWith(
          hour: 15, minute: 0, second: 0, millisecond: 0, microsecond: 0),
      location: 'Bureau à domicile',
      attendees: const ['Client Alpha'],
    ),

    // Tâche 2: PRIORITÉ NORMALE (Travail de fond important)
    TaskModel(
      taskId: 't2',
      userId: 'user1',
      title: 'Finaliser l\'article de blog "Tendances 2026"',
      description: 'Relecture, ajout des images et mise en ligne.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      status: 'todo',
      priority: 2, // NORMALE
      dueDate: DateTime.now().add(const Duration(days: 3)),
      estimatedTime: 180, // 180 minutes (3h)
    ),

    // Tâche 3: PRIORITÉ FAIBLE (Mais urgence de l'échéance)
    TaskModel(
      taskId: 't3',
      userId: 'user1',
      title: 'Remplir la feuille de temps (timesheet)',
      description: 'À faire avant 17h pour le paiement.',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      status: 'todo',
      priority: 3, // FAIBLE
      dueDate:
          DateTime.now().add(const Duration(minutes: 60)), // Échéance dans 1h
      estimatedTime: 15, // 15 minutes
    ),

    // Tâche 4: Tâche terminée
    TaskModel(
      taskId: 't4',
      userId: 'user1',
      title: 'Envoyer les factures du mois précédent',
      description: 'Factures 001 à 005.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      status: 'completed', // Tâche terminée
      priority: 3,
      dueDate: DateTime.now().subtract(const Duration(days: 2)),
      estimatedTime: 60,
      actualTimeSpent: 75,
    ),
  ];

  // Renvoie toutes les tâches, simulant une récupération depuis la base de données
  Future<List<TaskModel>> getAllTasks() async {
    // Simuler un petit délai réseau
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockTasks;
  }

  // NOUVELLE MÉTHODE : Simule la sauvegarde d'une nouvelle tâche dans la base de données
  // ➡️ C'EST CETTE DÉCLARATION QUI EST CORRECTE ET NÉCESSAIRE.
  Future<void> saveTask(TaskModel task) async {
    // Simuler un délai réseau/base de données
    await Future.delayed(const Duration(milliseconds: 300));

    // Ajout de la tâche à la liste en mémoire (simulant la persistance)
    _mockTasks.add(task);

    return;
  }
}
