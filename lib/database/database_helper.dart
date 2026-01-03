import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/habit_model.dart';
import '../models/habit_completion_model.dart';

/// Helper para gestionar la base de datos SQLite
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Obtiene la instancia de la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_ingresos.db');
    return _database!;
  }

  /// Inicializa la base de datos
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // Incrementado para agregar categoría a hábitos
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  /// Crea las tablas de la base de datos
  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    // Tabla de categorías
    await db.execute('''
      CREATE TABLE categories (
        id $idType,
        name $textType,
        type $textType,
        icon $textType,
        color $textType,
        created_at $textType,
        updated_at $textType
      )
    ''');

    // Tabla de transacciones
    await db.execute('''
      CREATE TABLE transactions (
        id $idType,
        type $textType,
        amount $realType,
        category_id $intType,
        description $textType,
        date $textType,
        created_at $textType,
        updated_at $textType,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // Tabla de hábitos
    await db.execute('''
      CREATE TABLE habits (
        id $idType,
        name $textType,
        description TEXT,
        icon_name TEXT NOT NULL,
        color_value INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        notification_time TEXT,
        category TEXT,
        created_at $textType,
        updated_at $textType
      )
    ''');

    // Tabla de finalizaciones de hábitos
    await db.execute('''
      CREATE TABLE habit_completions (
        id $idType,
        habit_id $intType,
        date $textType,
        is_completed INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        created_at $textType,
        updated_at $textType,
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE,
        UNIQUE(habit_id, date)
      )
    ''');

    // Insertar categorías predeterminadas
    await _insertDefaultCategories(db);
  }

  /// Maneja las actualizaciones de la base de datos
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Agregar tablas de hábitos
      await db.execute('''
        CREATE TABLE IF NOT EXISTS habits (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          icon_name TEXT NOT NULL,
          color_value INTEGER NOT NULL,
          is_active INTEGER NOT NULL DEFAULT 1,
          notification_time TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS habit_completions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          habit_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          is_completed INTEGER NOT NULL DEFAULT 0,
          notes TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE,
          UNIQUE(habit_id, date)
        )
      ''');
    }

    if (oldVersion < 3) {
      // Agregar columna de categoría a hábitos
      await db.execute('ALTER TABLE habits ADD COLUMN category TEXT');
    }
  }

  /// Inserta categorías predeterminadas
  Future<void> _insertDefaultCategories(Database db) async {
    final now = DateTime.now().toIso8601String();

    // Categorías de ingresos
    final incomeCategories = [
      {'name': 'Salario', 'icon': '💼', 'color': 'FF4CAF50'},
      {'name': 'Freelance', 'icon': '💻', 'color': 'FF2196F3'},
      {'name': 'Inversiones', 'icon': '📈', 'color': 'FFFF9800'},
      {'name': 'Ventas', 'icon': '🛍️', 'color': 'FF9C27B0'},
      {'name': 'Otros Ingresos', 'icon': '💰', 'color': 'FF00BCD4'},
    ];

    // Categorías de egresos
    final expenseCategories = [
      {'name': 'Alimentación', 'icon': '🍔', 'color': 'FFF44336'},
      {'name': 'Transporte', 'icon': '🚗', 'color': 'FFFF5722'},
      {'name': 'Vivienda', 'icon': '🏠', 'color': 'FF795548'},
      {'name': 'Servicios', 'icon': '💡', 'color': 'FF607D8B'},
      {'name': 'Entretenimiento', 'icon': '🎬', 'color': 'FFE91E63'},
      {'name': 'Salud', 'icon': '⚕️', 'color': 'FF009688'},
      {'name': 'Educación', 'icon': '📚', 'color': 'FF3F51B5'},
      {'name': 'Compras', 'icon': '🛒', 'color': 'FFCDDC39'},
      {'name': 'Otros Gastos', 'icon': '💸', 'color': 'FF9E9E9E'},
    ];

    // Insertar categorías de ingresos
    for (final cat in incomeCategories) {
      await db.insert('categories', {
        'name': cat['name'],
        'type': 'income',
        'icon': cat['icon'],
        'color': cat['color'],
        'created_at': now,
        'updated_at': now,
      });
    }

    // Insertar categorías de egresos
    for (final cat in expenseCategories) {
      await db.insert('categories', {
        'name': cat['name'],
        'type': 'expense',
        'icon': cat['icon'],
        'color': cat['color'],
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  // ==================== OPERACIONES CRUD CATEGORÍAS ====================

  /// Crea una nueva categoría
  Future<CategoryModel> createCategory(CategoryModel category) async {
    final db = await database;
    final id = await db.insert('categories', category.toMap());
    return category.copyWith(id: id);
  }

  /// Obtiene una categoría por ID
  Future<CategoryModel?> getCategoryById(int id) async {
    final db = await database;
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return CategoryModel.fromMap(maps.first);
  }

  /// Obtiene todas las categorías
  Future<List<CategoryModel>> getAllCategories() async {
    final db = await database;
    final maps = await db.query('categories', orderBy: 'name ASC');
    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  /// Obtiene categorías por tipo (income/expense)
  Future<List<CategoryModel>> getCategoriesByType(String type) async {
    final db = await database;
    final maps = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'name ASC',
    );
    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  /// Actualiza una categoría
  Future<int> updateCategory(CategoryModel category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// Elimina una categoría
  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== OPERACIONES CRUD TRANSACCIONES ====================

  /// Crea una nueva transacción
  Future<TransactionModel> createTransaction(
      TransactionModel transaction) async {
    final db = await database;
    final id = await db.insert('transactions', transaction.toMap());
    return transaction.copyWith(id: id);
  }

  /// Obtiene una transacción por ID
  Future<TransactionModel?> getTransactionById(int id) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return TransactionModel.fromMap(maps.first);
  }

  /// Obtiene todas las transacciones
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await database;
    final maps = await db.query('transactions', orderBy: 'date DESC');
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  /// Obtiene transacciones por tipo (income/expense)
  Future<List<TransactionModel>> getTransactionsByType(String type) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  /// Obtiene transacciones por rango de fechas
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  /// Obtiene transacciones por categoría
  Future<List<TransactionModel>> getTransactionsByCategory(
      int categoryId) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  /// Actualiza una transacción
  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  /// Elimina una transacción
  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Calcula el balance total
  Future<Map<String, double>> getBalance() async {
    final db = await database;

    final incomeResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ?',
      ['income'],
    );

    final expenseResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ?',
      ['expense'],
    );

    final income = (incomeResult.first['total'] as num?)?.toDouble() ?? 0.0;
    final expense = (expenseResult.first['total'] as num?)?.toDouble() ?? 0.0;

    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
    };
  }

  /// Cierra la base de datos
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // ==================== OPERACIONES CRUD HÁBITOS ====================

  /// Crea un nuevo hábito
  Future<HabitModel> createHabit(HabitModel habit) async {
    final db = await database;
    final id = await db.insert('habits', habit.toMap());
    return habit.copyWith(id: id);
  }

  /// Obtiene un hábito por ID
  Future<HabitModel?> getHabitById(int id) async {
    final db = await database;
    final maps = await db.query(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return HabitModel.fromMap(maps.first);
  }

  /// Obtiene todos los hábitos
  Future<List<HabitModel>> getAllHabits() async {
    final db = await database;
    final maps = await db.query('habits', orderBy: 'created_at DESC');
    return maps.map((map) => HabitModel.fromMap(map)).toList();
  }

  /// Obtiene solo hábitos activos
  Future<List<HabitModel>> getActiveHabits() async {
    final db = await database;
    final maps = await db.query(
      'habits',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => HabitModel.fromMap(map)).toList();
  }

  /// Actualiza un hábito
  Future<int> updateHabit(HabitModel habit) async {
    final db = await database;
    return await db.update(
      'habits',
      habit.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  /// Elimina un hábito
  Future<int> deleteHabit(int id) async {
    final db = await database;
    return await db.delete(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== OPERACIONES CRUD HABIT COMPLETIONS ====================

  /// Marca/desmarca un hábito como completado para una fecha
  Future<HabitCompletionModel> toggleHabitCompletion(
    int habitId,
    DateTime date,
  ) async {
    final db = await database;
    final dateOnly = DateTime(date.year, date.month, date.day);

    // Buscar si ya existe un registro para esta fecha
    final existing = await db.query(
      'habit_completions',
      where: 'habit_id = ? AND date = ?',
      whereArgs: [habitId, dateOnly.toIso8601String()],
    );

    if (existing.isEmpty) {
      // Crear nuevo registro completado
      final completion = HabitCompletionModel(
        habitId: habitId,
        date: dateOnly,
        isCompleted: true,
      );
      final id = await db.insert('habit_completions', completion.toMap());
      return completion.copyWith(id: id);
    } else {
      // Toggle el estado existente
      final current = HabitCompletionModel.fromMap(existing.first);
      final updated = current.copyWith(
        isCompleted: !current.isCompleted,
        updatedAt: DateTime.now(),
      );
      await db.update(
        'habit_completions',
        updated.toMap(),
        where: 'id = ?',
        whereArgs: [updated.id],
      );
      return updated;
    }
  }

  /// Obtiene las finalizaciones de un hábito en un rango de fechas
  Future<List<HabitCompletionModel>> getHabitCompletions(
    int habitId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;

    String whereClause = 'habit_id = ?';
    List<dynamic> whereArgs = [habitId];

    if (startDate != null && endDate != null) {
      whereClause += ' AND date BETWEEN ? AND ?';
      whereArgs.addAll([
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ]);
    }

    final maps = await db.query(
      'habit_completions',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );

    return maps.map((map) => HabitCompletionModel.fromMap(map)).toList();
  }

  /// Obtiene las finalizaciones de todos los hábitos para una fecha específica
  Future<List<HabitCompletionModel>> getCompletionsForDate(
      DateTime date) async {
    final db = await database;
    final dateOnly = DateTime(date.year, date.month, date.day);

    final maps = await db.query(
      'habit_completions',
      where: 'date = ?',
      whereArgs: [dateOnly.toIso8601String()],
    );

    return maps.map((map) => HabitCompletionModel.fromMap(map)).toList();
  }

  /// Calcula el progreso diario (porcentaje de hábitos completados)
  Future<double> getDailyProgress(DateTime date) async {
    final activeHabits = await getActiveHabits();
    if (activeHabits.isEmpty) return 0.0;

    final completions = await getCompletionsForDate(date);
    final completedCount = completions.where((c) => c.isCompleted).length;

    return (completedCount / activeHabits.length) * 100;
  }

  /// Obtiene estadísticas semanales de hábitos
  Future<Map<String, dynamic>> getWeeklyHabitStats(DateTime date) async {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final activeHabits = await getActiveHabits();
    final dailyProgress = <DateTime, double>{};

    for (var i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final progress = await getDailyProgress(day);
      dailyProgress[day] = progress;
    }

    final averageProgress = dailyProgress.values.isEmpty
        ? 0.0
        : dailyProgress.values.reduce((a, b) => a + b) /
            dailyProgress.values.length;

    return {
      'totalHabits': activeHabits.length,
      'dailyProgress': dailyProgress,
      'averageProgress': averageProgress,
      'startDate': startOfWeek,
      'endDate': endOfWeek,
    };
  }
}
