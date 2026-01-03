import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../models/habit_model.dart';
import '../models/habit_category.dart';

/// Pantalla para agregar o editar un hábito
class AddEditHabitScreen extends StatefulWidget {
  final HabitModel? habit;

  const AddEditHabitScreen({super.key, this.habit});

  @override
  State<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends State<AddEditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  String _selectedIcon = 'check_circle';
  Color _selectedColor = Colors.blue;
  TimeOfDay? _notificationTime;
  bool _isActive = true;
  HabitCategory? _selectedCategory;

  final List<String> _availableIcons = [
    'check_circle',
    'fitness_center',
    'local_drink',
    'menu_book',
    'directions_run',
    'self_improvement',
    'bedtime',
    'restaurant',
    'work',
    'school',
  ];

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.indigo,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.habit?.description ?? '');

    if (widget.habit != null) {
      _selectedIcon = widget.habit!.iconName;
      _selectedColor = Color(widget.habit!.colorValue);
      _isActive = widget.habit!.isActive;

      // Cargar categoría si existe
      if (widget.habit!.category != null) {
        _selectedCategory = HabitCategory.fromString(widget.habit!.category!);
      }

      if (widget.habit!.notificationTime != null) {
        final timeParts = widget.habit!.notificationTime!.split(':');
        _notificationTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.habit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Hábito' : 'Nuevo Hábito'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Nombre del hábito
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del hábito',
                hintText: 'Ej: Hacer ejercicio',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa un nombre';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Descripción
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                hintText: 'Ej: 30 minutos de ejercicio diario',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Selección de categoría
            Text(
              'Categoría',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<HabitCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
                hintText: 'Selecciona una categoría',
              ),
              items: HabitCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
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
              onChanged: (value) {
                setState(() => _selectedCategory = value);
              },
            ),

            const SizedBox(height: 24),

            // Selección de icono
            Text(
              'Icono',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableIcons.map((iconName) {
                final isSelected = _selectedIcon == iconName;
                return InkWell(
                  onTap: () => setState(() => _selectedIcon = iconName),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _selectedColor.withOpacity(0.2)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? _selectedColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _getIconData(iconName),
                      color: isSelected ? _selectedColor : Colors.grey[600],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Selección de color
            Text(
              'Color',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableColors.map((color) {
                final isSelected = _selectedColor == color;
                return InkWell(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Notificación
            ListTile(
              title: const Text('Recordatorio diario'),
              subtitle: Text(
                _notificationTime != null
                    ? 'Todos los días a las ${_notificationTime!.format(context)}'
                    : 'Sin recordatorio',
              ),
              trailing: IconButton(
                icon: Icon(
                  _notificationTime != null
                      ? Icons.notifications_active
                      : Icons.notifications_none,
                ),
                onPressed: () => _selectNotificationTime(context),
              ),
              onTap: () => _selectNotificationTime(context),
            ),

            const SizedBox(height: 16),

            // Estado activo/inactivo
            SwitchListTile(
              title: const Text('Hábito activo'),
              subtitle: const Text(
                  'Los hábitos inactivos no se muestran en la lista diaria'),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
            ),

            const SizedBox(height: 32),

            // Botón guardar
            FilledButton(
              onPressed: _saveHabit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(isEditing ? 'Actualizar Hábito' : 'Crear Hábito'),
            ),
          ],
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

  Future<void> _selectNotificationTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime ?? const TimeOfDay(hour: 9, minute: 0),
    );

    if (picked != null) {
      setState(() => _notificationTime = picked);
    }
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final habitProvider = context.read<HabitProvider>();

    final habit = HabitModel(
      id: widget.habit?.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      iconName: _selectedIcon,
      colorValue: _selectedColor.value,
      isActive: _isActive,
      category: _selectedCategory?.name,
      notificationTime: _notificationTime != null
          ? '${_notificationTime!.hour.toString().padLeft(2, '0')}:${_notificationTime!.minute.toString().padLeft(2, '0')}'
          : null,
    );

    if (widget.habit != null) {
      await habitProvider.updateHabit(habit);
      if (!mounted) return;
      Navigator.pop(context);
    } else {
      final success = await habitProvider.createHabit(habit);
      if (!mounted) return;

      if (!success) {
        // Mostrar notificación de que el hábito ya existe
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Este hábito ya está agregado',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      } else {
        Navigator.pop(context);
      }
    }
  }
}
