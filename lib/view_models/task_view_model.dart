import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../data/repositories/task_repository.dart';
import 'auth_view_model.dart'; // Import pour accéder aux réglages de l'IA

class TaskViewModel extends ChangeNotifier {
  final TaskRepository _repository = TaskRepository();

  List<TaskModel> _tasks = [];
  bool _isLoading = false;

  // Getter pour l'état de chargement
  bool get isLoading => _isLoading;

  // --- Comparateur pour la fonction de tri (Cœur de l'Intelligence DoGo) ---
  int _taskComparator(TaskModel a, TaskModel b) {
    // 1. Priorité la plus élevée (chiffre le plus bas) vient en premier
    int priorityComparison = a.priority.compareTo(b.priority);
    if (priorityComparison != 0) return priorityComparison;

    // 2. Échéance la plus proche vient en premier
    if (a.dueDate == null) return 1; // Les tâches sans date vont à la fin
    if (b.dueDate == null) return -1; // Les tâches sans date vont à la fin

    return a.dueDate!.compareTo(b.dueDate!); // Tri par date croissante
  }

  // Chargement des tâches depuis le Repository
  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Assurez-vous d'utiliser une méthode qui retourne List<TaskModel>
      _tasks = await _repository.getAllTasks();

      // Tri initial avec le comparateur APPLIQUÉ
      _tasks.sort(_taskComparator);
    } catch (e) {
      debugPrint('Erreur lors du chargement des tâches : $e');
      _tasks = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Marquer une tâche comme terminée (MISE À JOUR : utilise copyWith et maintient le tri)
  void completeTask(String taskId) {
    final index = _tasks.indexWhere((t) => t.taskId == taskId);
    if (index != -1) {
      // Mise à jour de la tâche en utilisant copyWith pour l'immutabilité
      _tasks[index] = _tasks[index].copyWith(status: 'completed');

      // Si la tâche est conservée dans la liste, la déplacer à la fin ou la retirer
      // Nous allons la retirer ici pour qu'elle disparaisse de l'écran principal
      _tasks.removeAt(index);

      notifyListeners();
    }
  }

  // --- NOUVEAU : Méthode unifiée pour obtenir les tâches avec ou sans filtre ---
  List<TaskModel> getTasks(AuthViewModel authViewModel) {
    // 1. Liste de base : toutes les tâches non terminées, déjà triées par fetchTasks/addTask
    List<TaskModel> todoTasks =
        _tasks.where((t) => t.status != 'completed').toList();

    // S'assurer que le tri est bien appliqué ici aussi (utile si des tâches sont ajoutées)
    todoTasks.sort(_taskComparator);

    // Si le Mode Focus est DÉSACTIVÉ (tout voir), on renvoie la liste complète triée
    if (!authViewModel.isFocusModeEnabled) {
      return todoTasks;
    }

    // --- LOGIQUE DU MODE FOCUS DE L'IA (FILTRE ET LIMITATION) ---

    // 1. Récupérer le temps de concentration de l'utilisateur (valeur persistante)
    final userFocusTime = authViewModel.currentUser?.dailyFocusTime ?? 480;

    // 2. Appliquer la LIMITATION PAR TEMPS (Cœur de l'IA DoGo)
    List<TaskModel> limitedTasks = [];
    int timeAccumulated = 0;

    for (var task in todoTasks) {
      if (timeAccumulated + task.estimatedTime <= userFocusTime) {
        limitedTasks.add(task);
        timeAccumulated += task.estimatedTime;
      } else {
        // Arrêt : Le temps de concentration est atteint
        break;
      }
    }

    debugPrint(
        'Mode Focus Actif: ${limitedTasks.length} tâches affichées pour $timeAccumulated min sur $userFocusTime min.');

    return limitedTasks;
  }

  // MÉTHODE POUR AJOUTER UNE NOUVELLE TÂCHE (Persistance et Tri après ajout)
  Future<void> addTask(TaskModel newTask) async {
    try {
      // 1. Sauvegarder la tâche (simulé ou réel)
      // (Assurez-vous que votre TaskRepository a une méthode saveTask)
      // await _repository.saveTask(newTask); // Décommenter si la persistance est réelle

      // 2. Mettre à jour la liste locale du ViewModel
      _tasks.add(newTask);

      // 3. Triez la liste complète à nouveau pour maintenir l'ordre
      _tasks.sort(_taskComparator);
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout de la tâche (Persistance) : $e');
    } finally {
      // 4. Notifier l'interface utilisateur pour rafraîchir la liste
      notifyListeners();
    }
  }
}
