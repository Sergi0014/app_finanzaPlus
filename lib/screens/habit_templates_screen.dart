import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit_template.dart';
import '../models/habit_category.dart';
import '../models/habit_model.dart';
import '../models/daily_routine_template.dart';
import '../providers/habit_provider.dart';

/// Pantalla para seleccionar y usar plantillas de hábitos predefinidas
class HabitTemplatesScreen extends StatefulWidget {
  const HabitTemplatesScreen({super.key});

  @override
  State<HabitTemplatesScreen> createState() => _HabitTemplatesScreenState();
}

class _HabitTemplatesScreenState extends State<HabitTemplatesScreen>
    with SingleTickerProviderStateMixin {
  HabitCategory? _selectedCategory;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plantillas de Hábitos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.category), text: 'Por Categoría'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Rutinas Diarias'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildCategoryTemplatesTab(), _buildDailyRoutinesTab()],
      ),
    );
  }

  // Tab de plantillas por categoría (original)
  Widget _buildCategoryTemplatesTab() {
    final templates = _selectedCategory != null
        ? HabitTemplate.getTemplatesByCategory(_selectedCategory!)
        : HabitTemplate.getTemplates();

    return Column(
      children: [
        // Filtro por categoría
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // Chip para mostrar todas
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: const Text('Todas'),
                  selected: _selectedCategory == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = null;
                    });
                  },
                ),
              ),
              // Chips para cada categoría
              ...HabitCategory.values.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: Icon(
                      category.icon,
                      size: 18,
                      color: _selectedCategory == category
                          ? Colors.white
                          : Color(category.colorValue),
                    ),
                    label: Text(category.displayName),
                    selected: _selectedCategory == category,
                    selectedColor: Color(category.colorValue),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : null;
                      });
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        ),

        const Divider(height: 1),

        // Lista de plantillas
        Expanded(
          child: templates.isEmpty
              ? Center(
                  child: Text(
                    'No hay plantillas disponibles',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    final template = templates[index];
                    return _buildTemplateCard(template);
                  },
                ),
        ),
      ],
    );
  }

  // Nuevo tab de rutinas diarias por día
  Widget _buildDailyRoutinesTab() {
    final allTemplates = DailyRoutineTemplate.getDailyTemplates();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allTemplates.length,
      itemBuilder: (context, index) {
        final routine = allTemplates[index];
        return _buildRoutineCard(routine);
      },
    );
  }

  // Tarjeta para rutina diaria completa
  Widget _buildRoutineCard(DailyRoutineTemplate routine) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () => _useRoutineAutomatically(routine),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Número del día
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Día\n${routine.dayNumber}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Descripción
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          routine.description,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${routine.habits.length} hábitos organizados',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),

                  // Icono de acción
                  Icon(
                    Icons.add_circle,
                    color: Theme.of(context).primaryColor,
                    size: 32,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Preview de algunos hábitos
              ...routine.habits.take(3).map((habit) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        _getIconData(habit.iconName),
                        size: 18,
                        color: habit.color,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${habit.time} - ${habit.name}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              }).toList(),

              if (routine.habits.length > 3) ...[
                const SizedBox(height: 4),
                Text(
                  '... y ${routine.habits.length - 3} más',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Mensaje de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Toca para agregar todos los hábitos',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
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

  Widget _buildTemplateCard(HabitTemplate template) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _useTemplate(template),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: template.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconData(template.iconName),
                  color: template.color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      template.description,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          template.category.icon,
                          size: 14,
                          color: Color(template.category.colorValue),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          template.category.displayName,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Color(template.category.colorValue),
                              ),
                        ),
                        if (template.suggestedTime != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            template.suggestedTime!,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Botón de usar
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
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
      case 'medication':
        return Icons.medication;
      case 'language':
        return Icons.language;
      case 'edit_calendar':
        return Icons.edit_calendar;
      case 'email':
        return Icons.email;
      case 'timer':
        return Icons.timer;
      case 'edit_note':
        return Icons.edit_note;
      case 'air':
        return Icons.air;
      case 'bed':
        return Icons.bed;
      case 'spa':
        return Icons.spa;
      case 'phone':
        return Icons.phone;
      case 'groups':
        return Icons.groups;
      // Nuevos iconos para rutinas diarias
      case 'shower':
        return Icons.shower;
      case 'egg':
        return Icons.egg_alt;
      case 'lunch_dining':
        return Icons.lunch_dining;
      case 'directions_walk':
        return Icons.directions_walk;
      case 'apple':
        return Icons.apple;
      case 'laptop':
        return Icons.laptop;
      case 'palette':
        return Icons.palette;
      case 'family_restroom':
        return Icons.family_restroom;
      case 'checklist':
        return Icons.checklist;
      case 'free_breakfast':
        return Icons.free_breakfast;
      case 'event_note':
        return Icons.event_note;
      case 'do_not_disturb_on':
        return Icons.do_not_disturb_on;
      case 'psychology':
        return Icons.psychology;
      case 'blender':
        return Icons.blender;
      case 'flag':
        return Icons.flag;
      case 'restaurant_menu':
        return Icons.restaurant_menu;
      case 'favorite':
        return Icons.favorite;
      case 'accessibility_new':
        return Icons.accessibility_new;
      case 'breakfast_dining':
        return Icons.breakfast_dining;
      case 'checklist_rtl':
        return Icons.checklist_rtl;
      case 'podcasts':
        return Icons.podcasts;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'brush':
        return Icons.brush;
      case 'volunteer_activism':
        return Icons.volunteer_activism;
      case 'sports_gymnastics':
        return Icons.sports_gymnastics;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'assignment_turned_in':
        return Icons.assignment_turned_in;
      case 'celebration':
        return Icons.celebration;
      case 'event_available':
        return Icons.event_available;
      case 'logout':
        return Icons.logout;
      case 'alarm_off':
        return Icons.alarm_off;
      case 'outdoor_grill':
        return Icons.outdoor_grill;
      case 'home_work':
        return Icons.home_work;
      case 'movie':
        return Icons.movie;
      case 'kitchen':
        return Icons.kitchen;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'calendar_month':
        return Icons.calendar_month;
      case 'checkroom':
        return Icons.checkroom;
      case 'auto_stories':
        return Icons.auto_stories;
      case 'dinner_dining':
        return Icons.dinner_dining;
      case 'today':
        return Icons.today;
      default:
        return Icons.check_circle;
    }
  }

  Future<void> _useTemplate(HabitTemplate template) async {
    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Agregando hábito...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Crear un hábito con los datos de la plantilla
    final habit = HabitModel(
      name: template.name,
      description: template.description,
      iconName: template.iconName,
      colorValue: template.color.value,
      category: template.category.name,
      notificationTime: template.suggestedTime,
      isActive: true,
    );

    // Agregar el hábito directamente
    final success = await context.read<HabitProvider>().createHabit(habit);

    if (mounted) {
      Navigator.pop(context); // Cerrar diálogo de carga
      Navigator.pop(context); // Volver a la pantalla anterior

      if (!success) {
        // Mostrar mensaje de hábito duplicado
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'El hábito "${template.name}" ya está agregado',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // Mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Hábito "${template.name}" agregado correctamente',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Agregar rutina automáticamente sin confirmación
  Future<void> _useRoutineAutomatically(DailyRoutineTemplate routine) async {
    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Agregando hábitos...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Agregar todos los hábitos de la rutina
    int addedCount = 0;
    int duplicateCount = 0;

    for (final habitTemplate in routine.habits) {
      final habit = HabitModel(
        name: habitTemplate.name,
        description: habitTemplate.description,
        iconName: habitTemplate.iconName,
        colorValue: habitTemplate.color.value,
        category: habitTemplate.category.name,
        notificationTime: habitTemplate.time,
        isActive: true,
      );

      // Usar el provider para crear el hábito
      final success = await context.read<HabitProvider>().createHabit(habit);
      if (success) {
        addedCount++;
      } else {
        duplicateCount++;
      }
    }

    if (mounted) {
      Navigator.pop(context); // Cerrar diálogo de carga
      Navigator.pop(context); // Volver a la pantalla anterior

      final messageText = addedCount > 0
          ? (duplicateCount > 0
                ? 'Día ${routine.dayNumber}: $addedCount hábitos agregados, $duplicateCount ya existían'
                : 'Día ${routine.dayNumber}: $addedCount hábitos agregados')
          : 'Todos los hábitos del Día ${routine.dayNumber} ya están agregados';

      final snackBarColor = addedCount > 0
          ? Colors.green
          : Colors.orange.shade700;
      final snackBarIcon = addedCount > 0
          ? Icons.check_circle
          : Icons.info_outline;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(snackBarIcon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  messageText,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: snackBarColor,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
