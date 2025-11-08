import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/task_view_model.dart';
import '../../../view_models/auth_view_model.dart';
import '../../../models/task_model.dart';
import '../magic_input/magic_input_screen.dart'; // Écran de Saisie Magique
import '../settings_screen.dart'; // Écran des Réglages

// --- COULEURS GLOBALES ET ATTIRANTES ---
const Color kPrimaryColor = Color(0xFF2c3e50); // Bleu Royal Profond (AppBars)
const Color kAccentColor =
    Color(0xFF1abc9c); // Vert Menthe (Boutons, Accentuation)
// --------------------------------------------------

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Écoutez (watch) l'état de l'AuthViewModel (y compris isFocusModeEnabled)
    final authViewModel = context.watch<AuthViewModel>();
    final isFocusMode = authViewModel.isFocusModeEnabled;

    // 2. Lisez (read) le TaskViewModel pour les méthodes
    final taskViewModel = context.read<TaskViewModel>();

    // 3. Obtenez la liste des tâches à afficher (filtrée ou complète)
    final tasksToDisplay = taskViewModel.getTasks(authViewModel);

    // 4. Vérifier l'état de chargement
    if (taskViewModel.isLoading || authViewModel.isLoading) {
      return const Scaffold(
          body: Center(
              child: CircularProgressIndicator(
                  color: kAccentColor))); // Utilisation de kAccentColor
    }

    return Scaffold(
      appBar: AppBar(
        // Le titre reflète le mode actif
        title:
            Text(isFocusMode ? 'DoGo - Focus IA' : 'DoGo - Toutes les Tâches'),
        centerTitle: false,
        backgroundColor: kPrimaryColor, // Bleu Profond
        foregroundColor: Colors.white,
        actions: [
          // 🛑 1. SWITCH POUR LE MODE FOCUS IA (Réintégré)
          Row(
            children: [
              Text(
                isFocusMode ? 'FOCUS ON' : 'TOUT VOIR',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
              Switch(
                value: isFocusMode,
                onChanged: (bool value) {
                  // Appel de la méthode du AuthViewModel pour basculer l'état (inclut la persistance)
                  authViewModel.toggleFocusMode(value);
                },

                // --- MISE À JOUR : Utilisation des propriétés MD3 ---
                thumbColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return kAccentColor; // Couleur du bouton lorsque ON
                  }
                  return Colors.white; // Couleur du bouton lorsque OFF
                }),

                trackColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    // Remplacement de withOpacity (déprécié) par withAlpha
                    return kAccentColor.withAlpha((0.5 * 255).round());
                  }
                  return Colors.white30; // Couleur de la piste lorsque OFF
                }),
                // ---------------------------------------------------
              ),
            ],
          ),

          // 🛑 2. BOUTON DE RÉGLAGES (Réintégré)
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),

      // 5. Affichage des données (filtrées ou complètes)
      body: tasksToDisplay.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  isFocusMode
                      ? 'Toutes les tâches importantes prévues pour aujourd\'hui sont terminées ! 🎉\n\nDésactivez le mode Focus pour voir toutes vos tâches.'
                      : 'Félicitations, vous n\'avez plus de tâches en cours ! 🎉\n\nAjoutez une nouvelle tâche pour continuer.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: tasksToDisplay.length,
              itemBuilder: (context, index) {
                final task = tasksToDisplay[index];
                return TaskCard(task: task);
              },
            ),

      // Bouton pour la Saisie Magique
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigation vers la Saisie Magique
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MagicInputScreen(),
            ),
          );
        },
        backgroundColor: kAccentColor, // Vert Menthe
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- Composant Tâche Réutilisable (TaskCard) ---
class TaskCard extends StatelessWidget {
  final TaskModel task;
  const TaskCard({super.key, required this.task});

  // Conserver les couleurs de priorité pour un meilleur contraste visuel
  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red.shade400;
      case 2:
        return Colors.amber.shade700;
      case 3:
        return Colors.blue.shade300;
      default:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<TaskViewModel>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: _getPriorityColor(task.priority),
          width: 3,
        ),
      ),
      child: ListTile(
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Est. ${task.estimatedTime} min | Priorité ${task.priority}${task.dueDate != null ? ' | Échéance: ${task.dueDate!.day}/${task.dueDate!.month}' : ''}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.check_circle_outline, size: 28),
          color: kAccentColor, // Vert Menthe pour l'icône
          onPressed: () {
            vm.completeTask(task.taskId);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Tâche "${task.title}" terminée ! Bon travail !')),
            );
          },
        ),
      ),
    );
  }
}
