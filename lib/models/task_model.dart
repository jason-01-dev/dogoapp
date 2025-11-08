// lib/models/task_model.dart

class TaskModel {
  // Identifiants et Métadonnées
  final String taskId;
  final String userId;
  final String title;
  final String description;
  final DateTime createdAt;

  // Statut et Priorité
  final String status; // 'todo', 'in_progress', 'completed'
  final int priority; // 1 (Haut), 2 (Normal), 3 (Faible)

  // Champs essentiels pour l'IA et la Planification (Concept DoGo)
  final DateTime? dueDate;
  final int estimatedTime; // Temps estimé en minutes
  final int actualTimeSpent; // Temps réel passé en minutes
  final String? sourceNlp; // Texte original de la Saisie Magique

  // --- CHAMPS DE CONTEXTE AVANCÉS (CORRIGÉS) ---
  final DateTime? startTime; // Heure de début précise (nullable)
  final String? location; // Lieu (nullable)
  final List<String>? attendees; // Personnes impliquées (nullable)

  TaskModel({
    required this.taskId,
    required this.userId,
    required this.title,
    this.description = '',
    required this.createdAt,
    this.status = 'todo',
    this.priority = 2,
    this.dueDate,
    this.estimatedTime = 0,
    this.actualTimeSpent = 0,
    this.sourceNlp,

    // CONSTRUCTEUR
    this.startTime,
    this.location,
    this.attendees,
  });

  // --- CORRECTION : Méthode copyWith ajoutée pour l'immuabilité ---
  TaskModel copyWith({
    String? taskId,
    String? userId,
    String? title,
    String? description,
    DateTime? createdAt,
    String? status,
    int? priority,
    DateTime? dueDate,
    int? estimatedTime,
    int? actualTimeSpent,
    String? sourceNlp,
    DateTime? startTime,
    String? location,
    List<String>? attendees,
  }) {
    return TaskModel(
      taskId: taskId ?? this.taskId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      actualTimeSpent: actualTimeSpent ?? this.actualTimeSpent,
      sourceNlp: sourceNlp ?? this.sourceNlp,
      startTime: startTime ?? this.startTime,
      location: location ?? this.location,
      attendees: attendees ?? this.attendees,
    );
  }

  // --- Méthode pour lire des données (fromJson) ---
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      taskId: json['taskId'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String,
      priority: json['priority'] as int,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      estimatedTime: json['estimatedTime'] as int,
      actualTimeSpent: json['actualTimeSpent'] as int,
      sourceNlp: json['sourceNlp'] as String?,

      // NOUVEAUX CHAMPS (PARSING JSON)
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      location: json['location'] as String?,
      // Gérer la liste des participants
      attendees: (json['attendees'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  // --- Méthode pour écrire des données (toJson) ---
  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'userId': userId,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'estimatedTime': estimatedTime,
      'actualTimeSpent': actualTimeSpent,
      'sourceNlp': sourceNlp,

      // NOUVEAUX CHAMPS (SÉRIALISATION JSON)
      'startTime': startTime?.toIso8601String(),
      'location': location,
      'attendees': attendees,
    };
  }
}
