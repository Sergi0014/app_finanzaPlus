import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit_model.dart';
import '../providers/habit_provider.dart';
import 'celebration_overlay.dart';

/// Widget que muestra una tarjeta de hábito individual
class HabitCard extends StatelessWidget {
  final HabitModel habit;
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  Future<void> _handleToggle(BuildContext context) async {
    if (isCompleted) {
      // Si está completado, mostrar confirmación antes de desmarcar
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¿Desmarcar hábito?'),
          content: Text(
            '¿Estás seguro de que quieres desmarcar "${habit.name}"?\n\nEsto afectará tu racha y progreso.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
              ),
              child: const Text('Desmarcar'),
            ),
          ],
        ),
      );
      if (confirm == true) {
        onToggle();
      }
    } else {
      // Si no está completado, marcar directamente y mostrar celebración
      onToggle();
      // Mostrar animación de celebración
      CelebrationOverlay.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitColor = Color(habit.colorValue);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isCompleted ? 1 : 2,
      child: InkWell(
        onTap: () => _handleToggle(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Checkbox circular
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? habitColor : habitColor.withOpacity(0.1),
                  border: Border.all(
                    color: habitColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  _getIconData(habit.iconName),
                  color: isCompleted ? Colors.white : habitColor,
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              // Información del hábito
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted ? Colors.grey : null,
                          ),
                    ),
                    if (habit.description != null &&
                        habit.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        habit.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (habit.notificationTime != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.notifications,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            habit.notificationTime!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                          ),
                        ],
                      ),
                    ],
                    // Racha (streak)
                    const SizedBox(height: 4),
                    FutureBuilder<int>(
                      future: Provider.of<HabitProvider>(context, listen: false)
                          .getHabitStreak(habit.id!),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data! > 0) {
                          return Row(
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                size: 16,
                                color: snapshot.data! >= 7
                                    ? Colors.orange[700]
                                    : Colors.orange[400],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${snapshot.data!} día${snapshot.data! > 1 ? 's' : ''} seguidos',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.orange[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),

              // Menú de opciones
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Eliminar', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'check_circle':
        return Icons.check_circle;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'local_drink':
        return Icons.local_drink;
      case 'menu_book':
        return Icons.menu_book;
      case 'directions_run':
        return Icons.directions_run;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'bedtime':
        return Icons.bedtime;
      case 'restaurant':
        return Icons.restaurant;
      case 'work':
        return Icons.work;
      case 'school':
        return Icons.school;
      default:
        return Icons.check_circle;
    }
  }
}
