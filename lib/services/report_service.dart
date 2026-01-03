import '../database/database_helper.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';

/// Modelo de reporte semanal
class WeeklyReport {
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<TransactionModel> transactions;
  final List<CategoryModel> categories;
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final List<CategoryTotal> topCategories;
  final Map<int, double> categoryTotals;
  // NUEVO: Estadísticas adicionales
  final double averageDailyIncome;
  final double averageDailyExpense;
  final double savingsRate;
  final int transactionCount;
  final String mostExpensiveDay;
  final double largestTransaction;
  final double smallestTransaction;

  WeeklyReport({
    required this.weekStart,
    required this.weekEnd,
    required this.transactions,
    required this.categories,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.topCategories,
    required this.categoryTotals,
    required this.averageDailyIncome,
    required this.averageDailyExpense,
    required this.savingsRate,
    required this.transactionCount,
    required this.mostExpensiveDay,
    required this.largestTransaction,
    required this.smallestTransaction,
  });
}

/// Total por categoría
class CategoryTotal {
  final CategoryModel category;
  final double total;
  final int transactionCount; // NUEVO: contador de transacciones
  final double percentage; // NUEVO: porcentaje del total

  CategoryTotal({
    required this.category,
    required this.total,
    required this.transactionCount,
    required this.percentage,
  });
}

/// Datos para gráfico de pie
class ChartData {
  final String label;
  final double value;
  final String color;
  final double percentage; // NUEVO: porcentaje para mostrar

  ChartData({
    required this.label,
    required this.value,
    required this.color,
    required this.percentage,
  });
}

/// Datos para gráfico de barras
class DailyBarData {
  final DateTime date;
  final double income;
  final double expense;
  final double net; // NUEVO: diferencia neta del día
  final int transactionCount; // NUEVO: cantidad de transacciones

  DailyBarData({
    required this.date,
    required this.income,
    required this.expense,
    required this.net,
    required this.transactionCount,
  });
}

/// Datos para gráfico de línea
class DailyLineData {
  final DateTime date;
  final double balance;
  final double income; // NUEVO: ingreso del día
  final double expense; // NUEVO: gasto del día

  DailyLineData({
    required this.date,
    required this.balance,
    required this.income,
    required this.expense,
  });
}

// NUEVO: Comparación con período anterior
class PeriodComparison {
  final double incomeChange;
  final double expenseChange;
  final double balanceChange;
  final String trend; // 'up', 'down', 'stable'

  PeriodComparison({
    required this.incomeChange,
    required this.expenseChange,
    required this.balanceChange,
    required this.trend,
  });
}

// NUEVO: Análisis de patrones
class SpendingPattern {
  final String dayWithMostExpenses;
  final String dayWithMostIncome;
  final CategoryModel topExpenseCategory;
  final CategoryModel topIncomeCategory;
  final List<String> suggestions; // Sugerencias personalizadas

  SpendingPattern({
    required this.dayWithMostExpenses,
    required this.dayWithMostIncome,
    required this.topExpenseCategory,
    required this.topIncomeCategory,
    required this.suggestions,
  });
}

/// Servicio para generar reportes semanales
class ReportService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Obtiene el inicio de la semana actual (lunes)
  DateTime getWeekStart(DateTime date, [int startOfWeek = DateTime.monday]) {
    final int daysToSubtract = (date.weekday - startOfWeek + 7) % 7;
    final weekStart = date.subtract(Duration(days: daysToSubtract));
    return DateTime(weekStart.year, weekStart.month, weekStart.day);
  }

  /// Obtiene el fin de la semana (domingo)
  DateTime getWeekEnd(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    return DateTime(weekEnd.year, weekEnd.month, weekEnd.day, 23, 59, 59);
  }

  /// Genera reporte semanal completo con estadísticas mejoradas
  Future<WeeklyReport> generateWeeklyReport({
    DateTime? startDate,
    int startOfWeek = DateTime.monday,
  }) async {
    final now = startDate ?? DateTime.now();
    final weekStart = getWeekStart(now, startOfWeek);
    final weekEnd = getWeekEnd(weekStart);

    // Obtener transacciones de la semana
    final transactions = await _dbHelper.getTransactionsByDateRange(
      weekStart,
      weekEnd,
    );

    // Obtener todas las categorías
    final categories = await _dbHelper.getAllCategories();

    // Calcular totales y estadísticas
    double totalIncome = 0;
    double totalExpense = 0;
    final Map<int, double> categoryTotals = {};
    final Map<int, int> categoryTransactionCount = {};
    final Map<DateTime, double> dailyExpenses = {};

    double largestTransaction = 0;
    double smallestTransaction = double.infinity;

    for (final transaction in transactions) {
      if (transaction.isIncome) {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;

        // Rastrear gastos diarios
        final dayKey = DateTime(
          transaction.date.year,
          transaction.date.month,
          transaction.date.day,
        );
        dailyExpenses[dayKey] =
            (dailyExpenses[dayKey] ?? 0) + transaction.amount;
      }

      // Acumular por categoría
      categoryTotals[transaction.categoryId] =
          (categoryTotals[transaction.categoryId] ?? 0) + transaction.amount;

      categoryTransactionCount[transaction.categoryId] =
          (categoryTransactionCount[transaction.categoryId] ?? 0) + 1;

      // Rastrear transacciones más grandes/pequeñas
      if (transaction.amount > largestTransaction) {
        largestTransaction = transaction.amount;
      }
      if (transaction.amount < smallestTransaction && transaction.amount > 0) {
        smallestTransaction = transaction.amount;
      }
    }

    // Calcular promedios diarios
    final daysInPeriod = weekEnd.difference(weekStart).inDays + 1;
    final averageDailyIncome = totalIncome / daysInPeriod;
    final averageDailyExpense = totalExpense / daysInPeriod;

    // Calcular tasa de ahorro
    final savingsRate = totalIncome > 0
        ? ((totalIncome - totalExpense) / totalIncome) * 100
        : 0.0;

    // Encontrar día con más gastos
    String mostExpensiveDay = 'N/A';
    double maxDailyExpense = 0;
    dailyExpenses.forEach((date, expense) {
      if (expense > maxDailyExpense) {
        maxDailyExpense = expense;
        mostExpensiveDay = _formatDay(date);
      }
    });

    // Obtener Top categorías mejoradas
    final topCategories = _getTopCategories(
      categoryTotals,
      categoryTransactionCount,
      categories,
      totalExpense,
      5,
    );

    return WeeklyReport(
      weekStart: weekStart,
      weekEnd: weekEnd,
      transactions: transactions,
      categories: categories,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: totalIncome - totalExpense,
      topCategories: topCategories,
      categoryTotals: categoryTotals,
      averageDailyIncome: averageDailyIncome,
      averageDailyExpense: averageDailyExpense,
      savingsRate: savingsRate,
      transactionCount: transactions.length,
      mostExpensiveDay: mostExpensiveDay,
      largestTransaction: largestTransaction,
      smallestTransaction:
          smallestTransaction == double.infinity ? 0 : smallestTransaction,
    );
  }

  // NUEVO: Comparar con período anterior
  Future<PeriodComparison> compareWithPreviousPeriod(
      WeeklyReport currentReport) async {
    final previousStart =
        currentReport.weekStart.subtract(const Duration(days: 7));
    final previousEnd = currentReport.weekEnd.subtract(const Duration(days: 7));

    final previousTransactions = await _dbHelper.getTransactionsByDateRange(
      previousStart,
      previousEnd,
    );

    double previousIncome = 0;
    double previousExpense = 0;

    for (final transaction in previousTransactions) {
      if (transaction.isIncome) {
        previousIncome += transaction.amount;
      } else {
        previousExpense += transaction.amount;
      }
    }

    final previousBalance = previousIncome - previousExpense;

    // Calcular cambios porcentuales
    final incomeChange = previousIncome > 0
        ? ((currentReport.totalIncome - previousIncome) / previousIncome) * 100
        : 0.0;

    final expenseChange = previousExpense > 0
        ? ((currentReport.totalExpense - previousExpense) / previousExpense) *
            100
        : 0.0;

    final balanceChange = previousBalance != 0
        ? ((currentReport.balance - previousBalance) / previousBalance.abs()) *
            100
        : 0.0;

    // Determinar tendencia
    String trend = 'stable';
    if (currentReport.balance > previousBalance * 1.1) {
      trend = 'up';
    } else if (currentReport.balance < previousBalance * 0.9) {
      trend = 'down';
    }

    return PeriodComparison(
      incomeChange: incomeChange,
      expenseChange: expenseChange,
      balanceChange: balanceChange,
      trend: trend,
    );
  }

  // NUEVO: Analizar patrones de gasto
  Future<SpendingPattern> analyzeSpendingPatterns(WeeklyReport report) async {
    // Encontrar día con más gastos e ingresos
    final Map<String, double> dailyExpenseMap = {};
    final Map<String, double> dailyIncomeMap = {};

    for (final transaction in report.transactions) {
      final day = _formatDay(transaction.date);

      if (transaction.isIncome) {
        dailyIncomeMap[day] = (dailyIncomeMap[day] ?? 0) + transaction.amount;
      } else {
        dailyExpenseMap[day] = (dailyExpenseMap[day] ?? 0) + transaction.amount;
      }
    }

    String dayWithMostExpenses = 'N/A';
    double maxExpense = 0;
    dailyExpenseMap.forEach((day, expense) {
      if (expense > maxExpense) {
        maxExpense = expense;
        dayWithMostExpenses = day;
      }
    });

    String dayWithMostIncome = 'N/A';
    double maxIncome = 0;
    dailyIncomeMap.forEach((day, income) {
      if (income > maxIncome) {
        maxIncome = income;
        dayWithMostIncome = day;
      }
    });

    // Categoría top de gastos e ingresos
    CategoryModel topExpenseCategory = CategoryModel(
      id: 0,
      name: 'N/A',
      type: 'expense',
      icon: '❓',
      color: 'FF9E9E9E',
    );

    CategoryModel topIncomeCategory = CategoryModel(
      id: 0,
      name: 'N/A',
      type: 'income',
      icon: '❓',
      color: 'FF9E9E9E',
    );

    if (report.topCategories.isNotEmpty) {
      topExpenseCategory = report.topCategories.first.category;
    }

    // Generar sugerencias personalizadas
    final suggestions = _generateSuggestions(report);

    return SpendingPattern(
      dayWithMostExpenses: dayWithMostExpenses,
      dayWithMostIncome: dayWithMostIncome,
      topExpenseCategory: topExpenseCategory,
      topIncomeCategory: topIncomeCategory,
      suggestions: suggestions,
    );
  }

  // NUEVO: Generar sugerencias personalizadas
  List<String> _generateSuggestions(WeeklyReport report) {
    final suggestions = <String>[];

    // Sugerencia sobre tasa de ahorro
    if (report.savingsRate < 10) {
      suggestions.add(
          '💡 Tu tasa de ahorro es baja (${report.savingsRate.toStringAsFixed(1)}%). Intenta reducir gastos innecesarios.');
    } else if (report.savingsRate > 30) {
      suggestions.add(
          '🎉 ¡Excelente! Estás ahorrando ${report.savingsRate.toStringAsFixed(1)}% de tus ingresos.');
    }

    // Sugerencia sobre gastos vs ingresos
    if (report.totalExpense > report.totalIncome) {
      suggestions.add(
          '⚠️ Tus gastos superan tus ingresos. Revisa tus categorías de mayor gasto.');
    }

    // Sugerencia sobre categoría dominante
    if (report.topCategories.isNotEmpty) {
      final topCategory = report.topCategories.first;
      if (topCategory.percentage > 40) {
        suggestions.add(
            '📊 ${topCategory.category.name} representa ${topCategory.percentage.toStringAsFixed(0)}% de tus gastos. ¿Puedes optimizarlo?');
      }
    }

    // Sugerencia sobre frecuencia de transacciones
    if (report.transactionCount < 5) {
      suggestions.add(
          '📝 Registra más transacciones para un mejor análisis de tus finanzas.');
    }

    return suggestions;
  }

  /// Obtiene las top N categorías por monto gastado con mejoras
  List<CategoryTotal> _getTopCategories(
    Map<int, double> categoryTotals,
    Map<int, int> categoryTransactionCount,
    List<CategoryModel> allCategories,
    double totalExpense,
    int limit,
  ) {
    final List<CategoryTotal> result = [];

    for (final entry in categoryTotals.entries) {
      final category = allCategories.firstWhere(
        (c) => c.id == entry.key,
        orElse: () => CategoryModel(
          id: entry.key,
          name: 'Desconocida',
          type: 'expense',
          icon: '❓',
          color: 'FF9E9E9E',
        ),
      );

      final percentage =
          totalExpense > 0 ? (entry.value / totalExpense) * 100 : 0.0;

      result.add(CategoryTotal(
        category: category,
        total: entry.value,
        transactionCount: categoryTransactionCount[entry.key] ?? 0,
        percentage: percentage,
      ));
    }

    // Ordenar por monto descendente
    result.sort((a, b) => b.total.compareTo(a.total));

    // Retornar solo los top N
    return result.take(limit).toList();
  }

  /// Genera datos para gráfico de pie mejorado
  List<ChartData> generatePieChartData(WeeklyReport report) {
    return report.topCategories.map((ct) {
      return ChartData(
        label: ct.category.name,
        value: ct.total,
        color: ct.category.color,
        percentage: ct.percentage,
      );
    }).toList();
  }

  /// Genera datos para gráfico de barras mejorado
  List<DailyBarData> generateBarChartData(WeeklyReport report) {
    final Map<DateTime, double> dailyIncome = {};
    final Map<DateTime, double> dailyExpense = {};
    final Map<DateTime, int> dailyTransactionCount = {};

    // Inicializar todos los días de la semana
    for (int i = 0; i < 7; i++) {
      final day = report.weekStart.add(Duration(days: i));
      final dayKey = DateTime(day.year, day.month, day.day);
      dailyIncome[dayKey] = 0;
      dailyExpense[dayKey] = 0;
      dailyTransactionCount[dayKey] = 0;
    }

    // Sumar transacciones por día
    for (final transaction in report.transactions) {
      final dayKey = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      if (transaction.isIncome) {
        dailyIncome[dayKey] = (dailyIncome[dayKey] ?? 0) + transaction.amount;
      } else {
        dailyExpense[dayKey] = (dailyExpense[dayKey] ?? 0) + transaction.amount;
      }

      dailyTransactionCount[dayKey] = (dailyTransactionCount[dayKey] ?? 0) + 1;
    }

    // Crear lista de datos
    final List<DailyBarData> result = [];
    dailyIncome.forEach((date, income) {
      final expense = dailyExpense[date] ?? 0;
      result.add(DailyBarData(
        date: date,
        income: income,
        expense: expense,
        net: income - expense,
        transactionCount: dailyTransactionCount[date] ?? 0,
      ));
    });

    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  /// Genera datos para gráfico de línea mejorado
  List<DailyLineData> generateLineChartData(WeeklyReport report) {
    final List<DailyLineData> result = [];
    double cumulativeBalance = 0;

    // Ordenar transacciones por fecha
    final sortedTransactions = List<TransactionModel>.from(report.transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Agrupar por día
    final Map<DateTime, double> dailyBalance = {};
    final Map<DateTime, double> dailyIncome = {};
    final Map<DateTime, double> dailyExpense = {};

    for (final transaction in sortedTransactions) {
      final dayKey = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      final change =
          transaction.isIncome ? transaction.amount : -transaction.amount;

      dailyBalance[dayKey] = (dailyBalance[dayKey] ?? 0) + change;

      if (transaction.isIncome) {
        dailyIncome[dayKey] = (dailyIncome[dayKey] ?? 0) + transaction.amount;
      } else {
        dailyExpense[dayKey] = (dailyExpense[dayKey] ?? 0) + transaction.amount;
      }
    }

    // Crear puntos del gráfico
    for (int i = 0; i < 7; i++) {
      final day = report.weekStart.add(Duration(days: i));
      final dayKey = DateTime(day.year, day.month, day.day);

      cumulativeBalance += dailyBalance[dayKey] ?? 0;

      result.add(DailyLineData(
        date: dayKey,
        balance: cumulativeBalance,
        income: dailyIncome[dayKey] ?? 0,
        expense: dailyExpense[dayKey] ?? 0,
      ));
    }

    return result;
  }

  /// Genera reporte para un rango de fechas personalizado
  Future<WeeklyReport> generateCustomDateRangeReport(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final startOfDay = DateTime(startDate.year, startDate.month, startDate.day);
    final endOfDay =
        DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    final transactions = await _dbHelper.getTransactionsByDateRange(
      startOfDay,
      endOfDay,
    );

    final categories = await _dbHelper.getAllCategories();

    double totalIncome = 0;
    double totalExpense = 0;
    final Map<int, double> categoryTotals = {};
    final Map<int, int> categoryTransactionCount = {};
    final Map<DateTime, double> dailyExpenses = {};

    double largestTransaction = 0;
    double smallestTransaction = double.infinity;

    for (final transaction in transactions) {
      if (transaction.isIncome) {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;

        final dayKey = DateTime(
          transaction.date.year,
          transaction.date.month,
          transaction.date.day,
        );
        dailyExpenses[dayKey] =
            (dailyExpenses[dayKey] ?? 0) + transaction.amount;
      }

      categoryTotals[transaction.categoryId] =
          (categoryTotals[transaction.categoryId] ?? 0) + transaction.amount;

      categoryTransactionCount[transaction.categoryId] =
          (categoryTransactionCount[transaction.categoryId] ?? 0) + 1;

      if (transaction.amount > largestTransaction) {
        largestTransaction = transaction.amount;
      }
      if (transaction.amount < smallestTransaction && transaction.amount > 0) {
        smallestTransaction = transaction.amount;
      }
    }

    final daysInPeriod = endOfDay.difference(startOfDay).inDays + 1;
    final averageDailyIncome = totalIncome / daysInPeriod;
    final averageDailyExpense = totalExpense / daysInPeriod;

    final savingsRate = totalIncome > 0
        ? ((totalIncome - totalExpense) / totalIncome) * 100
        : 0.0;

    String mostExpensiveDay = 'N/A';
    double maxDailyExpense = 0;
    dailyExpenses.forEach((date, expense) {
      if (expense > maxDailyExpense) {
        maxDailyExpense = expense;
        mostExpensiveDay = _formatDay(date);
      }
    });

    final topCategories = _getTopCategories(
      categoryTotals,
      categoryTransactionCount,
      categories,
      totalExpense,
      5,
    );

    return WeeklyReport(
      weekStart: startOfDay,
      weekEnd: endOfDay,
      transactions: transactions,
      categories: categories,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: totalIncome - totalExpense,
      topCategories: topCategories,
      categoryTotals: categoryTotals,
      averageDailyIncome: averageDailyIncome,
      averageDailyExpense: averageDailyExpense,
      savingsRate: savingsRate,
      transactionCount: transactions.length,
      mostExpensiveDay: mostExpensiveDay,
      largestTransaction: largestTransaction,
      smallestTransaction:
          smallestTransaction == double.infinity ? 0 : smallestTransaction,
    );
  }

  // Método auxiliar para formatear día
  String _formatDay(DateTime date) {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return days[date.weekday - 1];
  }
}
