import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/task_model.dart';
import '../../../../view_models/task_view_model.dart';
import '../../../../view_models/auth_view_model.dart';
// NOTE: L'importation du parseur dépend de sa position réelle.
// J'assume ici que vous utilisez le code que j'ai vu pour l'intégrer.
// S'il est dans un autre fichier, ajustez le chemin ci-dessous !
import '../../../utils/magic_parser.dart';
import '../../../../view_models/settings_view_model.dart';

// --- COULEURS GLOBALES ---
const Color kPrimaryColor = Color(0xFF2c3e50);
const Color kAccentColor = Color(0xFF1abc9c);
// -------------------------

class MagicInputScreen extends StatefulWidget {
  const MagicInputScreen({super.key});

  @override
  State<MagicInputScreen> createState() => _MagicInputScreenState();
}

class _MagicInputScreenState extends State<MagicInputScreen> {
  // 1. Contrôleurs principaux
  final TextEditingController _controller = TextEditingController();

  // 🚨 CORRECTION : Les contrôleurs pour les champs manuels complexes
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _attendeesController = TextEditingController();

  // 2. Variables d'état
  TaskModel? _parsedTaskPreview;
  int _manualPriority = 2;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updatePreview);

    // 💡 Correction: On écoute les changements des champs manuels
    // pour que la prévisualisation se mette à jour lorsqu'on édite manuellement
    _locationController.addListener(_updatePreview);
    _timeController.addListener(_updatePreview);
    _attendeesController.addListener(_updatePreview);

    _updatePreview();
  }

  @override
  void dispose() {
    _controller.removeListener(_updatePreview);
    // 🚨 CORRECTION : Nettoyage des NOUVEAUX contrôleurs
    _locationController.removeListener(_updatePreview);
    _timeController.removeListener(_updatePreview);
    _attendeesController.removeListener(_updatePreview);

    _controller.dispose();
    _locationController.dispose();
    _timeController.dispose();
    _attendeesController.dispose();

    super.dispose();
  }

  void _updatePreview() {
    final userId =
        context.read<AuthViewModel>().currentUser?.uid ?? 'mock_user_123';

    // 💡 Utilisation du parseur externe
    final TaskModel? newPreview =
        MagicParser.parseTask(_controller.text, userId);

    setState(() {
      _parsedTaskPreview = newPreview;

      // 🚨 CORRECTION : Mise à jour des contrôleurs *uniquement* si le texte principal est modifié
      // ET que le champ manuel n'a pas été touché.
      if (newPreview != null) {
        // Mettre à jour la priorité parsée (pour le Dropdown)
        _manualPriority = newPreview.priority;

        // Synchroniser Lieu (si l'utilisateur n'a pas commencé à taper manuellement)
        if (_locationController.text.isEmpty) {
          _locationController.text = newPreview.location ?? '';
        }

        // Synchroniser Heure
        final newTime = newPreview.startTime != null
            ? '${newPreview.startTime!.hour}h${newPreview.startTime!.minute.toString().padLeft(2, '0')}'
            : '';
        if (_timeController.text.isEmpty) {
          _timeController.text = newTime;
        }

        // Synchroniser Participants
        final newAttendees = newPreview.attendees?.join(', ') ?? '';
        if (_attendeesController.text.isEmpty) {
          _attendeesController.text = newAttendees;
        }
      } else {
        // Réinitialiser la priorité et les contrôleurs lorsque l'entrée principale est vide
        _manualPriority = 2;
        _locationController.clear();
        _timeController.clear();
        _attendeesController.clear();
      }
    });
  }

  // --- WIDGET D'AFFICHAGE (PREVIEW) ---
  Widget _buildPreview(TaskModel? task) {
    if (task == null || _controller.text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final displayPriority = _manualPriority;
    final priorityText = switch (displayPriority) {
      1 => 'Haute (1) 🔥',
      2 => 'Normale (2) 📝',
      3 => 'Faible (3) ⏳',
      _ => 'Non définie',
    };

    String formattedContext = '';

    // 💡 CORRECTION : Utilisation des contrôleurs manuels pour l'affichage
    final locationDisplay = _locationController.text.trim();
    final timeDisplay = _timeController.text.trim();
    final attendeesDisplay = _attendeesController.text.trim();

    if (timeDisplay.isNotEmpty) {
      formattedContext += '⏰ $timeDisplay';
    }
    if (locationDisplay.isNotEmpty) {
      if (formattedContext.isNotEmpty) formattedContext += ' | ';
      formattedContext += '📍 $locationDisplay';
    }
    if (attendeesDisplay.isNotEmpty) {
      if (formattedContext.isNotEmpty) formattedContext += ' | ';
      formattedContext += '🧑‍🤝‍🧑 $attendeesDisplay';
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        // Remplacement de withOpacity déprécié par withAlpha
        color: kAccentColor.withAlpha((0.08 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kAccentColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Extraction Magique :',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: kAccentColor)),
          const SizedBox(height: 8),
          Text('Titre: ${task.title}'),
          Text('Temps estimé: **${task.estimatedTime} min**'),
          Text('Priorité: **$priorityText**'),
          if (formattedContext.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text('Contexte: $formattedContext',
                  style: const TextStyle(fontStyle: FontStyle.italic)),
            ),
          if (task.dueDate != null)
            Text(
                'Échéance: **${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}**'),
        ],
      ),
    );
  }

  // --- WIDGET : Le formulaire manuel pour la précision ---
  Widget _buildManualFields(TaskModel? task) {
    // Si la tâche parsée est nulle, on n'affiche pas le formulaire d'ajustement
    if (task == null || _controller.text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            'Ou ajuster manuellement les détails (Précision) :',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        // Sélecteur de PRIORITÉ (Dropdown)
        DropdownButtonFormField<int>(
          decoration: const InputDecoration(
            labelText: 'Priorité',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.star, color: kAccentColor),
          ),
          initialValue: _manualPriority,
          items: const [
            DropdownMenuItem(value: 1, child: Text('1 - Haute 🔥')),
            DropdownMenuItem(value: 2, child: Text('2 - Normale 📝')),
            DropdownMenuItem(value: 3, child: Text('3 - Faible ⏳')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _manualPriority = value;
                // Pas besoin d'appeler _updatePreview() ici, car la prévisualisation
                // utilise directement _manualPriority (voir _buildPreview)
              });
            }
          },
        ),
        const SizedBox(height: 15),

        // 🚨 CORRECTION : Utilisation du contrôleur (adieu initialValue)
        // Champ LIEU
        TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(
            labelText: 'Lieu (Où faire la tâche)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on, color: kAccentColor),
          ),
        ),
        const SizedBox(height: 15),

        // 🚨 CORRECTION : Utilisation du contrôleur
        // Champ HEURE DE DÉBUT
        TextFormField(
          controller: _timeController,
          decoration: const InputDecoration(
            labelText: 'Heure de début (Optionnel)',
            hintText: 'Ex: 14h30',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.access_time, color: kAccentColor),
          ),
        ),
        const SizedBox(height: 15),

        // 🚨 CORRECTION : Utilisation du contrôleur
        // Champ PARTICIPANTS
        TextFormField(
          controller: _attendeesController,
          decoration: const InputDecoration(
            labelText: 'Participants (@Marie, @Jean...)',
            hintText: 'Liste des personnes séparées par des virgules',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.people, color: kAccentColor),
          ),
        ),
      ],
    );
  }

  // --- LOGIQUE D'AJOUT DE TÂCHE ---
  Future<void> _addTask() async {
    final input = _controller.text;
    if (input.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez entrer une description de tâche valide.')),
      );
      return;
    }

    // On utilise _parsedTaskPreview pour la base, mais on le re-parse ici
    // pour s'assurer que le titre est bien le titre final de l'entrée principale.
    final userId =
        context.read<AuthViewModel>().currentUser?.uid ?? 'mock_user_123';
    final parsedTask = MagicParser.parseTask(input, userId);

    if (parsedTask != null) {
      // 🚨 CORRECTION : Logique de conversion de l'heure manuelle
      DateTime? finalStartTime =
          parsedTask.startTime; // Par défaut, celui du parsing
      final timeInput = _timeController.text.trim();
      final timeRegex = RegExp(r'(\d{1,2})h(\d{0,2})?');
      final timeMatch = timeRegex.firstMatch(timeInput);

      if (timeMatch != null) {
        final hour = int.tryParse(timeMatch.group(1) ?? '');
        final minute = int.tryParse(timeMatch.group(2) ?? '0');

        if (hour != null && hour >= 0 && hour <= 23) {
          // Utiliser la dueDate parsée ou aujourd'hui pour fixer la date
          DateTime baseDate = parsedTask.dueDate ?? DateTime.now();
          finalStartTime = DateTime(
            baseDate.year,
            baseDate.month,
            baseDate.day,
            hour,
            minute ?? 0,
          );
        }
      } else if (timeInput.isEmpty) {
        finalStartTime = null; // Si l'utilisateur efface, l'heure est nulle
      }

      // 💡 CREATION DE LA TACHE FINALE
      final newTask = parsedTask.copyWith(
        priority: _manualPriority, // Ajustement manuel du Dropdown
        location: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : null, // Ajustement manuel du champ Lieu
        attendees: _attendeesController.text
            .trim()
            .split(',')
            .map((e) => e.trim().replaceAll(RegExp(r'@'), '')) // Nettoyage du @
            .where((e) => e.isNotEmpty)
            .toList(), // Ajustement manuel des Participants
        startTime: finalStartTime, // Heure manuelle convertie
      );

      context.read<TaskViewModel>().addTask(newTask);

      // Schedule reminders if the task has a due date
      // Capture context-dependent objects synchronously before awaiting
      final settingsVm = context.read<SettingsViewModel>();
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      if (newTask.dueDate != null) {
        try {
          await settingsVm.scheduleRemindersForTask(
            taskId: newTask.taskId,
            title: newTask.title,
            dueDate: newTask.dueDate!,
          );
        } catch (e) {
          debugPrint('Failed to schedule reminders: $e');
        }
      }

      // Use the captured references
      messenger.showSnackBar(
        SnackBar(
          content: Text('Tâche "${newTask.title}" ajoutée avec succès !'),
        ),
      );
      navigator.pop();
    }
  }

  // --- MÉTHODE BUILD PRINCIPALE (Inchangée) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saisie Magique ✨'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Que voulez-vous faire ?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Ex: "Réunion à 14h @Jean au bureau (60 min) priorité 1"',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _controller,
              maxLines: 5,
              minLines: 1,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Entrez votre tâche magique ici...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kAccentColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildPreview(_parsedTaskPreview),
            const SizedBox(height: 30),
            _buildManualFields(_parsedTaskPreview),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _addTask,
              icon: const Icon(Icons.star, size: 24),
              label: const Text('Ajouter la Tâche (Magie!)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
