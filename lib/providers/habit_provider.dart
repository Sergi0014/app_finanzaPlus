import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/habit_model.dart';
import '../models/habit_completion_model.dart';

/// Provider para gestionar los hábitos y sus finalizaciones
class HabitProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<HabitModel> _habits = [];
  List<HabitCompletionModel> _todayCompletions = [];
  bool _isLoading = false;
  String? _error;
  DateTime _selectedDate = DateTime.now();
  DateTime? _lastLoadedDate;

  List<HabitModel> get habits => _habits;
  List<HabitModel> get activeHabits =>
      _habits.where((h) => h.isActive).toList();
  List<HabitCompletionModel> get todayCompletions => _todayCompletions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;

  /// Carga todos los hábitos y las finalizaciones del día actual
  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _habits = await _dbHelper.getAllHabits();
      await _checkAndResetForNewDay();
      await _loadTodayCompletions();
    } catch (e) {
      _error = 'Error al cargar hábitos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verifica si es un nuevo día y resetea la fecha seleccionada
  Future<void> _checkAndResetForNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Obtener la última fecha guardada
    final lastDateString = prefs.getString('last_habit_check_date');

    if (lastDateString != null) {
      final lastDate = DateTime.parse(lastDateString);
      final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);

      // Si es un día diferente, actualizar a hoy
      if (!_isSameDay(today, lastDay)) {
        _selectedDate = now;
        if (kDebugMode) {
          print('¡Nuevo día detectado! Reseteando hábitos a la fecha actual.');
        }
      }
    }

    // Guardar la fecha actual
    await prefs.setString('last_habit_check_date', today.toIso8601String());
    _lastLoadedDate = now;
  }

  /// Verifica si dos fechas son del mismo día
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Carga las finalizaciones del día actual
  Future<void> _loadTodayCompletions() async {
    _todayCompletions = await _dbHelper.getCompletionsForDate(_selectedDate);
  }

  /// Cambia la fecha seleccionada y recarga las finalizaciones
  Future<void> setSelectedDate(DateTime date) async {
    _selectedDate = date;
    await _loadTodayCompletions();
    notifyListeners();
  }

  /// Crea un nuevo hábito
  /// Retorna true si se creó exitosamente, false si ya existe
  Future<bool> createHabit(HabitModel habit) async {
    // Verificar si ya existe un hábito con el mismo nombre
    final existingHabit = _habits.firstWhere(
      (h) =>
          h.name.toLowerCase().trim() == habit.name.toLowerCase().trim() &&
          h.isActive,
      orElse: () => HabitModel(
        id: -1,
        name: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (existingHabit.id != null && existingHabit.id! > 0) {
      _error = 'Ya existe un hábito con este nombre';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newHabit = await _dbHelper.createHabit(habit);
      _habits.add(newHabit);
      return true;
    } catch (e) {
      _error = 'Error al crear hábito: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Actualiza un hábito existente
  Future<void> updateHabit(HabitModel habit) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _dbHelper.updateHabit(habit);
      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        _habits[index] = habit;
      }
    } catch (e) {
      _error = 'Error al actualizar hábito: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Elimina un hábito
  Future<void> deleteHabit(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _dbHelper.deleteHabit(id);
      _habits.removeWhere((h) => h.id == id);
    } catch (e) {
      _error = 'Error al eliminar hábito: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Marca/desmarca un hábito como completado
  Future<void> toggleHabitCompletion(int habitId) async {
    try {
      final completion = await _dbHelper.toggleHabitCompletion(
        habitId,
        _selectedDate,
      );

      // Actualizar la lista local
      final index = _todayCompletions.indexWhere((c) => c.habitId == habitId);
      if (index != -1) {
        _todayCompletions[index] = completion;
      } else {
        _todayCompletions.add(completion);
      }

      notifyListeners();
    } catch (e) {
      _error = 'Error al marcar hábito: $e';
      notifyListeners();
    }
  }

  /// Verifica si un hábito está completado en la fecha seleccionada
  bool isHabitCompleted(int habitId) {
    final completion = _todayCompletions.firstWhere(
      (c) => c.habitId == habitId,
      orElse: () => HabitCompletionModel(
        habitId: habitId,
        date: _selectedDate,
        isCompleted: false,
      ),
    );
    return completion.isCompleted;
  }

  /// Calcula el progreso del día (porcentaje de hábitos completados)
  double get dailyProgress {
    if (activeHabits.isEmpty) return 0.0;

    final completedCount = _todayCompletions.where((c) => c.isCompleted).length;
    return (completedCount / activeHabits.length) * 100;
  }

  /// Obtiene el progreso semanal
  Future<Map<String, dynamic>> getWeeklyProgress() async {
    try {
      return await _dbHelper.getWeeklyHabitStats(_selectedDate);
    } catch (e) {
      _error = 'Error al obtener progreso semanal: $e';
      notifyListeners();
      return {};
    }
  }

  /// Obtiene las finalizaciones de un hábito específico en un rango de fechas
  Future<List<HabitCompletionModel>> getHabitCompletions(
    int habitId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _dbHelper.getHabitCompletions(
        habitId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _error = 'Error al obtener finalizaciones: $e';
      notifyListeners();
      return [];
    }
  }

  /// Obtiene un hábito por ID
  HabitModel? getHabitById(int id) {
    try {
      return _habits.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene hábitos por categoría
  List<HabitModel> getHabitsByCategory(String? category) {
    if (category == null) {
      return activeHabits;
    }
    return _habits.where((h) => h.isActive && h.category == category).toList();
  }

  /// Obtiene las categorías únicas de los hábitos activos
  List<String> getActiveCategories() {
    final categories = <String>{};
    for (final habit in activeHabits) {
      if (habit.category != null && habit.category!.isNotEmpty) {
        categories.add(habit.category!);
      }
    }
    return categories.toList()..sort();
  }

  /// Obtiene la racha actual de un hábito (días consecutivos completados)
  Future<int> getHabitStreak(int habitId) async {
    int streak = 0;
    DateTime checkDate = DateTime.now();

    while (true) {
      final completions = await _dbHelper.getCompletionsForDate(checkDate);
      final completion = completions.firstWhere(
        (c) => c.habitId == habitId,
        orElse: () => HabitCompletionModel(
          habitId: habitId,
          date: checkDate,
          isCompleted: false,
        ),
      );

      if (completion.isCompleted) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }

      // Límite de seguridad para evitar bucles infinitos
      if (streak > 365) break;
    }

    return streak;
  }

  /// Obtener estadísticas mensuales para gráficos
  List<Map<String, dynamic>> getMonthlyStats() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    final List<Map<String, dynamic>> monthlyStats = [];

    for (
      var date = firstDayOfMonth;
      date.isBefore(lastDayOfMonth.add(const Duration(days: 1)));
      date = date.add(const Duration(days: 1))
    ) {
      // No incluir días futuros
      if (date.isAfter(now)) break;

      // Calcular porcentaje de completitud para este día
      final activeHabitsCount = activeHabits.length;
      if (activeHabitsCount == 0) continue;

      // Aquí necesitarías obtener las completaciones de cada día
      // Por ahora usamos datos del día actual como ejemplo
      // En una implementación real, necesitarías cargar datos históricos
      final percentage = date.day == now.day
          ? dailyProgress
          : (date.day % 3 == 0
                ? 85.0
                : date.day % 2 == 0
                ? 65.0
                : 45.0);

      monthlyStats.add({
        'date': date,
        'percentage': percentage,
        'completedCount': (activeHabitsCount * percentage / 100).round(),
        'totalCount': activeHabitsCount,
      });
    }

    return monthlyStats;
  }

  /// Generar texto para compartir progreso
  String generateShareText() {
    final completedToday = todayCompletions.where((c) => c.isCompleted).length;
    final totalActive = activeHabits.length;
    final progress = dailyProgress;

    final text = StringBuffer();
    text.writeln('📊 Mi Progreso de Hábitos - ${_formatDate(_selectedDate)}');
    text.writeln('');
    text.writeln('✅ Completados: $completedToday/$totalActive hábitos');
    text.writeln('📈 Progreso: ${progress.toStringAsFixed(0)}%');
    text.writeln('');
    text.writeln('Mis hábitos de hoy:');

    for (final habit in activeHabits) {
      final isCompleted = isHabitCompleted(habit.id!);
      text.writeln('${isCompleted ? "✅" : "⬜"} ${habit.name}');
    }

    text.writeln('');
    text.writeln('¡Construyendo mejores hábitos cada día! 💪');

    return text.toString();
  }

  String _formatDate(DateTime date) {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${date.day} de ${months[date.month - 1]} ${date.year}';
  }
}
