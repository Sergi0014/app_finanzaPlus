import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import 'report_service.dart';

/// Servicio para exportar datos
class ExportService {
  /// Exporta reporte semanal a CSV
  Future<String> exportWeeklyReportToCSV(WeeklyReport report) async {
    final List<List<dynamic>> rows = [];

    // Encabezado del reporte
    rows.add(['Reporte Semanal']);
    rows.add([
      'Período',
      '${DateFormat('dd/MM/yyyy').format(report.weekStart)} - ${DateFormat('dd/MM/yyyy').format(report.weekEnd)}'
    ]);
    rows.add([]);

    // Resumen
    rows.add(['Resumen']);
    rows.add(['Total Ingresos', report.totalIncome]);
    rows.add(['Total Egresos', report.totalExpense]);
    rows.add(['Balance', report.balance]);
    rows.add([]);

    // Top 5 Categorías
    rows.add(['Top 5 Categorías']);
    rows.add(['#', 'Categoría', 'Tipo', 'Total']);
    for (int i = 0; i < report.topCategories.length; i++) {
      final ct = report.topCategories[i];
      rows.add([
        i + 1,
        ct.category.name,
        ct.category.isIncome ? 'Ingreso' : 'Egreso',
        ct.total,
      ]);
    }
    rows.add([]);

    // Transacciones
    rows.add(['Transacciones']);
    rows.add(['Fecha', 'Tipo', 'Categoría', 'Descripción', 'Monto']);

    final sortedTransactions = List<TransactionModel>.from(report.transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    for (final transaction in sortedTransactions) {
      final category = report.categories.firstWhere(
        (c) => c.id == transaction.categoryId,
        orElse: () => CategoryModel(
          name: 'Desconocida',
          type: transaction.type,
          icon: '❓',
          color: 'FF9E9E9E',
        ),
      );

      rows.add([
        DateFormat('dd/MM/yyyy HH:mm').format(transaction.date),
        transaction.isIncome ? 'Ingreso' : 'Egreso',
        category.name,
        transaction.description,
        transaction.amount,
      ]);
    }

    // Convertir a CSV
    final String csv = const ListToCsvConverter().convert(rows);

    // Guardar archivo
    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/reporte_semanal_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
    final File file = File(path);
    await file.writeAsString(csv);

    return path;
  }

  /// Exporta todas las transacciones a CSV
  Future<String> exportAllTransactionsToCSV(
    List<TransactionModel> transactions,
    List<CategoryModel> categories,
  ) async {
    final List<List<dynamic>> rows = [];

    // Encabezado
    rows.add(['ID', 'Fecha', 'Tipo', 'Categoría', 'Descripción', 'Monto']);

    // Transacciones
    for (final transaction in transactions) {
      final category = categories.firstWhere(
        (c) => c.id == transaction.categoryId,
        orElse: () => CategoryModel(
          name: 'Desconocida',
          type: transaction.type,
          icon: '❓',
          color: 'FF9E9E9E',
        ),
      );

      rows.add([
        transaction.id,
        DateFormat('dd/MM/yyyy HH:mm').format(transaction.date),
        transaction.isIncome ? 'Ingreso' : 'Egreso',
        category.name,
        transaction.description,
        transaction.amount,
      ]);
    }

    // Convertir a CSV
    final String csv = const ListToCsvConverter().convert(rows);

    // Guardar archivo
    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/transacciones_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
    final File file = File(path);
    await file.writeAsString(csv);

    return path;
  }

  /// Exporta reporte semanal a JSON
  Future<String> exportWeeklyReportToJSON(WeeklyReport report) async {
    final Map<String, dynamic> data = {
      'periodo': {
        'inicio': report.weekStart.toIso8601String(),
        'fin': report.weekEnd.toIso8601String(),
      },
      'resumen': {
        'total_ingresos': report.totalIncome,
        'total_egresos': report.totalExpense,
        'balance': report.balance,
      },
      'top_categorias': report.topCategories.map((ct) {
        return {
          'categoria': ct.category.name,
          'tipo': ct.category.isIncome ? 'ingreso' : 'egreso',
          'total': ct.total,
          'icono': ct.category.icon,
          'color': ct.category.color,
        };
      }).toList(),
      'transacciones': report.transactions.map((t) {
        final category = report.categories.firstWhere(
          (c) => c.id == t.categoryId,
          orElse: () => CategoryModel(
            name: 'Desconocida',
            type: t.type,
            icon: '❓',
            color: 'FF9E9E9E',
          ),
        );

        return {
          'id': t.id,
          'fecha': t.date.toIso8601String(),
          'tipo': t.type,
          'categoria': category.name,
          'descripcion': t.description,
          'monto': t.amount,
        };
      }).toList(),
    };

    // Convertir a JSON
    final String jsonString = const JsonEncoder.withIndent('  ').convert(data);

    // Guardar archivo
    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/reporte_semanal_${DateFormat('yyyyMMdd').format(DateTime.now())}.json';
    final File file = File(path);
    await file.writeAsString(jsonString);

    return path;
  }

  /// Comparte un archivo
  Future<void> shareFile(String filePath, String subject) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: subject,
    );
  }
}
