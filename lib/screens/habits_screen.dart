import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/habit_provider.dart';
import '../models/habit_model.dart';
import '../models/habit_category.dart';
import '../widgets/habit_card.dart';
import '../widgets/habit_progress_bar.dart';
import '../widgets/weekly_habit_chart.dart';
import '../widgets/monthly_habit_chart.dart';
import 'add_edit_habit_screen.dart';
import 'habit_templates_screen.dart';

/// Pantalla principal para la gestión de hábitos
class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  String? _selectedCategoryFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Hábitos'),
        actions: [
          // Filtro por categoría
          Consumer<HabitProvider>(
            builder: (context, habitProvider, _) {
              final activeCategories = habitProvider.getActiveCategories();

              if (activeCategories.isEmpty) {
                return const SizedBox.shrink();
              }

              return PopupMenuButton<String>(
                icon: Icon(
                  _selectedCategoryFilter != null
                      ? Icons.filter_alt
                      : Icons.filter_alt_outlined,
                ),
                tooltip: 'Filtrar por categoría',
                onSelected: (value) {
                  setState(() {
                    _selectedCategoryFilter = value == 'all' ? null : value;
                  });
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'all',
                    child: Row(
                      children: [
                        Icon(Icons.all_inclusive),
                        SizedBox(width: 12),
                        Text('Todas las categorías'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  ...activeCategories.map((categoryName) {
                    final category = HabitCategory.fromString(categoryName);
                    return PopupMenuItem(
                      value: categoryName,
                      child: Row(
                        children: [
                          Icon(
                            category.icon,
                            color: Color(category.colorValue),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(category.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            onPressed: () => _navigateToTemplates(context),
            tooltip: 'Plantillas de hábitos',
          ),
          IconButton(
            icon: const Icon(Icons.insights),
            onPressed: () => _showWeeklyStats(context),
            tooltip: 'Ver estadísticas semanales',
          ),
        ],
      ),
      body: Consumer<HabitProvider>(
        builder: (context, habitProvider, child) {
          if (habitProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (habitProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    habitProvider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => habitProvider.loadData(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final activeHabits = habitProvider.activeHabits;

          // Filtrar hábitos por categoría si hay un filtro seleccionado
          final filteredHabits = _selectedCategoryFilter != null
              ? habitProvider.getHabitsByCategory(_selectedCategoryFilter!)
              : activeHabits;

          return Column(
            children: [
              // Barra de progreso diario
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progreso de hoy',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${habitProvider.dailyProgress.toStringAsFixed(0)}%',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    HabitProgressBar(progress: habitProvider.dailyProgress),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${habitProvider.todayCompletions.where((c) => c.isCompleted).length} de ${activeHabits.length} hábitos completados',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        // Botón compartir
                        IconButton(
                          icon: const Icon(Icons.share, size: 20),
                          onPressed: () =>
                              _shareProgress(context, habitProvider),
                          tooltip: 'Compartir progreso',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Lista de hábitos
              Expanded(
                child: filteredHabits.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredHabits.length,
                        itemBuilder: (context, index) {
                          final habit = filteredHabits[index];
                          return HabitCard(
                            habit: habit,
                            isCompleted:
                                habitProvider.isHabitCompleted(habit.id!),
                            onToggle: () =>
                                habitProvider.toggleHabitCompletion(habit.id!),
                            onEdit: () => _navigateToEditHabit(context, habit),
                            onDelete: () => _deleteHabit(context, habit),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddHabit(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fact_check_outlined,
              size: 120,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              '¡Comienza a crear hábitos!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca el botón + para crear un hábito personalizado',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _navigateToTemplates(context),
              icon: const Icon(Icons.inventory_2_outlined),
              label: const Text('Usar plantillas prediseñadas'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '7 rutinas diarias predefinidas',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[400],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddHabit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditHabitScreen(),
      ),
    );
  }

  void _navigateToEditHabit(BuildContext context, HabitModel habit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditHabitScreen(habit: habit),
      ),
    );
  }

  void _navigateToTemplates(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HabitTemplatesScreen(),
      ),
    );
  }

  void _shareProgress(BuildContext context, HabitProvider habitProvider) {
    final shareText = habitProvider.generateShareText();
    Share.share(shareText, subject: 'Mi Progreso de Hábitos');
  }

  void _deleteHabit(BuildContext context, HabitModel habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar hábito'),
        content: Text('¿Estás seguro de que deseas eliminar "${habit.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<HabitProvider>().deleteHabit(habit.id!);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showWeeklyStats(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return DefaultTabController(
            length: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Estadísticas',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),

                  // Tabs para cambiar entre semanal y mensual
                  TabBar(
                    tabs: const [
                      Tab(text: 'Semanal'),
                      Tab(text: 'Mensual'),
                    ],
                    labelColor: Theme.of(context).colorScheme.primary,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: TabBarView(
                      children: [
                        // Vista semanal
                        SingleChildScrollView(
                          controller: scrollController,
                          child: const WeeklyHabitChart(),
                        ),
                        // Vista mensual
                        SingleChildScrollView(
                          controller: scrollController,
                          child: const MonthlyHabitChart(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
