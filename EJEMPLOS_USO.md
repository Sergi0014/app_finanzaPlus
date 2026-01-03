# 💡 Ejemplos de Uso - Módulo de Hábitos

## 🎯 Casos de Uso Comunes

### 1️⃣ Crear un Hábito desde Código

```dart
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../models/habit_model.dart';

// En cualquier widget con acceso al context
void createExerciseHabit(BuildContext context) {
  final habitProvider = Provider.of<HabitProvider>(context, listen: false);

  final newHabit = HabitModel(
    name: 'Hacer ejercicio',
    description: '30 minutos de cardio',
    iconName: 'fitness_center',
    colorValue: Colors.green.value,
    notificationTime: '07:00', // 7:00 AM
  );

  habitProvider.createHabit(newHabit);
}
```

### 2️⃣ Obtener Todos los Hábitos Activos

```dart
// Usando Consumer en un Widget
Consumer<HabitProvider>(
  builder: (context, habitProvider, child) {
    final activeHabits = habitProvider.activeHabits;

    return ListView.builder(
      itemCount: activeHabits.length,
      itemBuilder: (context, index) {
        final habit = activeHabits[index];
        return Text(habit.name);
      },
    );
  },
)

// O usando Provider.of
final habitProvider = Provider.of<HabitProvider>(context);
final activeHabits = habitProvider.activeHabits;
```

### 3️⃣ Marcar un Hábito como Completado

```dart
void toggleHabit(BuildContext context, int habitId) {
  final habitProvider = Provider.of<HabitProvider>(context, listen: false);
  habitProvider.toggleHabitCompletion(habitId);

  // Opcional: Mostrar mensaje de motivación
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('¡Hábito completado!')),
  );
}

// En un botón:
ElevatedButton(
  onPressed: () => toggleHabit(context, habit.id!),
  child: Text('Marcar como completado'),
)
```

### 4️⃣ Mostrar el Progreso del Día

```dart
// En un Widget
Consumer<HabitProvider>(
  builder: (context, habitProvider, child) {
    final progress = habitProvider.dailyProgress;

    return Column(
      children: [
        Text('Progreso: ${progress.toStringAsFixed(0)}%'),
        LinearProgressIndicator(value: progress / 100),
      ],
    );
  },
)
```

### 5️⃣ Obtener Estadísticas Semanales

```dart
Future<void> showWeeklyStats(BuildContext context) async {
  final habitProvider = Provider.of<HabitProvider>(context, listen: false);
  final stats = await habitProvider.getWeeklyProgress();

  final totalHabits = stats['totalHabits'];
  final averageProgress = stats['averageProgress'];
  final dailyProgress = stats['dailyProgress'] as Map<DateTime, double>;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Estadísticas Semanales'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Total de hábitos: $totalHabits'),
          Text('Promedio: ${averageProgress.toStringAsFixed(1)}%'),
          ...dailyProgress.entries.map((entry) {
            return Text(
              '${DateFormat('EEEE').format(entry.key)}: ${entry.value.toStringAsFixed(0)}%'
            );
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cerrar'),
        ),
      ],
    ),
  );
}
```

### 6️⃣ Verificar si un Hábito Está Completado

```dart
bool checkIfCompleted(BuildContext context, int habitId) {
  final habitProvider = Provider.of<HabitProvider>(context);
  return habitProvider.isHabitCompleted(habitId);
}

// Usar en la UI:
Icon(
  checkIfCompleted(context, habit.id!)
    ? Icons.check_circle
    : Icons.circle_outlined,
)
```

### 7️⃣ Obtener la Racha de un Hábito

```dart
// Mostrar cuántos días consecutivos se ha completado
FutureBuilder<int>(
  future: Provider.of<HabitProvider>(context).getHabitStreak(habit.id!),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final streak = snapshot.data!;
      return Row(
        children: [
          Icon(Icons.local_fire_department, color: Colors.orange),
          Text('$streak días'),
        ],
      );
    }
    return CircularProgressIndicator();
  },
)
```

### 8️⃣ Programar Notificación para un Hábito

```dart
import '../services/notification_service.dart';

Future<void> setHabitReminder(HabitModel habit) async {
  if (habit.notificationTime != null) {
    final timeParts = habit.notificationTime!.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    await NotificationService.instance.scheduleHabitNotification(
      habitId: habit.id!,
      habitName: habit.name,
      hour: hour,
      minute: minute,
    );
  }
}
```

### 9️⃣ Filtrar Hábitos por Criterio

```dart
// En HabitProvider, puedes agregar métodos personalizados:

// Filtrar por color
List<HabitModel> getHabitsByColor(int colorValue) {
  return _habits.where((h) => h.colorValue == colorValue).toList();
}

// Filtrar por icono
List<HabitModel> getHabitsByIcon(String iconName) {
  return _habits.where((h) => h.iconName == iconName).toList();
}

// Hábitos con notificaciones configuradas
List<HabitModel> getHabitsWithReminders() {
  return _habits.where((h) => h.notificationTime != null).toList();
}

// Uso:
final greenHabits = habitProvider.getHabitsByColor(Colors.green.value);
```

### 🔟 Editar un Hábito Existente

```dart
void updateHabitName(BuildContext context, HabitModel habit, String newName) {
  final habitProvider = Provider.of<HabitProvider>(context, listen: false);

  final updatedHabit = habit.copyWith(name: newName);
  habitProvider.updateHabit(updatedHabit);
}

// Ejemplo completo de edición:
void editHabit(BuildContext context, HabitModel habit) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AddEditHabitScreen(habit: habit),
    ),
  );
}
```

---

## 🎨 Ejemplos de Personalización de UI

### Custom HabitCard con Animación

```dart
import 'package:flutter/material.dart';

class AnimatedHabitCard extends StatefulWidget {
  final HabitModel habit;
  final bool isCompleted;
  final VoidCallback onToggle;

  const AnimatedHabitCard({
    required this.habit,
    required this.isCompleted,
    required this.onToggle,
  });

  @override
  State<AnimatedHabitCard> createState() => _AnimatedHabitCardState();
}

class _AnimatedHabitCardState extends State<AnimatedHabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
      widget.onToggle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        child: InkWell(
          onTap: _handleTap,
          child: ListTile(
            leading: Icon(
              widget.isCompleted ? Icons.check_circle : Icons.circle_outlined,
              color: Color(widget.habit.colorValue),
            ),
            title: Text(widget.habit.name),
          ),
        ),
      ),
    );
  }
}
```

### Barra de Progreso Circular

```dart
import 'dart:math' as math;

class CircularHabitProgress extends StatelessWidget {
  final double progress; // 0-100

  const CircularHabitProgress({required this.progress});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(100, 100),
      painter: _CircularProgressPainter(progress / 100),
      child: Center(
        child: Text(
          '${progress.toStringAsFixed(0)}%',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;

  _CircularProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Fondo
    final backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progreso
    final progressPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

---

## 🔧 Ejemplos de Extensión

### Agregar Campo "Prioridad" a Hábitos

**1. Actualizar el modelo:**

```dart
// En habit_model.dart
class HabitModel {
  final int? id;
  final String name;
  final int priority; // NUEVO: 1=Alta, 2=Media, 3=Baja
  // ... resto de campos

  HabitModel({
    this.id,
    required this.name,
    this.priority = 2, // Default: Media
    // ... resto de parámetros
  });

  factory HabitModel.fromMap(Map<String, dynamic> map) {
    return HabitModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      priority: map['priority'] as int? ?? 2,
      // ... resto de mapeo
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'priority': priority,
      // ... resto de campos
    };
  }
}
```

**2. Actualizar la base de datos:**

```dart
// En database_helper.dart, en _onUpgrade:
if (oldVersion < 3) {
  await db.execute('ALTER TABLE habits ADD COLUMN priority INTEGER DEFAULT 2');
}

// No olvides incrementar la versión:
version: 3,
```

**3. Agregar selector en UI:**

```dart
// En add_edit_habit_screen.dart
DropdownButton<int>(
  value: _priority,
  items: [
    DropdownMenuItem(value: 1, child: Text('Alta')),
    DropdownMenuItem(value: 2, child: Text('Media')),
    DropdownMenuItem(value: 3, child: Text('Baja')),
  ],
  onChanged: (value) => setState(() => _priority = value!),
)
```

---

## 📊 Ejemplos de Análisis de Datos

### Calcular Tasa de Éxito de un Hábito

```dart
// En HabitProvider
Future<double> getHabitSuccessRate(int habitId, {int days = 30}) async {
  final endDate = DateTime.now();
  final startDate = endDate.subtract(Duration(days: days));

  final completions = await _dbHelper.getHabitCompletions(
    habitId,
    startDate: startDate,
    endDate: endDate,
  );

  final completedDays = completions.where((c) => c.isCompleted).length;
  return (completedDays / days) * 100;
}

// Usar en la UI:
FutureBuilder<double>(
  future: habitProvider.getHabitSuccessRate(habit.id!),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return Text('Tasa de éxito: ${snapshot.data!.toStringAsFixed(1)}%');
    }
    return CircularProgressIndicator();
  },
)
```

### Mejores y Peores Días de la Semana

```dart
Future<Map<String, dynamic>> analyzeBestWorstDays() async {
  final stats = await getWeeklyProgress();
  final dailyProgress = stats['dailyProgress'] as Map<DateTime, double>;

  double maxProgress = 0;
  double minProgress = 100;
  DateTime? bestDay;
  DateTime? worstDay;

  dailyProgress.forEach((date, progress) {
    if (progress > maxProgress) {
      maxProgress = progress;
      bestDay = date;
    }
    if (progress < minProgress) {
      minProgress = progress;
      worstDay = date;
    }
  });

  return {
    'bestDay': DateFormat('EEEE').format(bestDay!),
    'bestProgress': maxProgress,
    'worstDay': DateFormat('EEEE').format(worstDay!),
    'worstProgress': minProgress,
  };
}
```

---

## 🎮 Gamificación - Sistema de Puntos

```dart
// Agregar en HabitProvider
int calculatePoints() {
  int points = 0;

  // Puntos por completar hábitos hoy
  points += todayCompletions.where((c) => c.isCompleted).length * 10;

  // Bonus por 100% de completitud
  if (dailyProgress == 100.0) {
    points += 50;
  }

  // Bonus por rachas
  // ... calcular rachas y agregar puntos adicionales

  return points;
}

// Mostrar en UI
Text('Puntos: ${habitProvider.calculatePoints()}')
```

---

## 🌐 Compartir Progreso en Redes Sociales

```dart
import 'package:share_plus/share_plus.dart';

Future<void> shareProgress(BuildContext context) async {
  final habitProvider = Provider.of<HabitProvider>(context, listen: false);
  final stats = await habitProvider.getWeeklyProgress();

  final message = '''
🎯 Mi progreso semanal de hábitos:
📊 Promedio: ${stats['averageProgress'].toStringAsFixed(1)}%
✅ Total de hábitos: ${stats['totalHabits']}

¡Sigue construyendo buenos hábitos con App Ingresos!
  ''';

  await Share.share(message);
}
```

---

**💡 Consejo Final**: Estos ejemplos son puntos de partida. Combínalos y personalízalos según tus necesidades específicas. La arquitectura está diseñada para ser flexible y extensible.
