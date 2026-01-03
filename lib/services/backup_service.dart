import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';

/// Servicio para backup, restauración e importación
class BackupService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<String> _getDbPath() async {
    final dbDir = await getDatabasesPath();
    final dbPath = p.join(dbDir, 'app_ingresos.db');
    return dbPath;
  }

  /// Crea un backup completo de la base de datos
  Future<String> createBackup() async {
    try {
      final dbPath = await _getDbPath();
      final tmpDir = await getTemporaryDirectory();
      final backupPath = p.join(
        tmpDir.path,
        'backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.db',
      );

      final dbFile = File(dbPath);
      if (!await dbFile.exists()) {
        throw Exception('Base de datos no encontrada en: $dbPath');
      }

      await dbFile.copy(backupPath);

      // Compartir el backup
      await Share.shareXFiles(
        [XFile(backupPath)],
        subject: 'Backup App Ingresos',
      );

      return backupPath;
    } catch (e) {
      rethrow;
    }
  }

  /// Restaura un backup desde un archivo
  Future<bool> restoreBackup() async {
    try {
      // Seleccionar archivo de backup
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return false;
      }

      final pickedFile = result.files.first;
      if (pickedFile.path == null) {
        return false;
      }

      // Copiar el backup seleccionado a la ubicación de la BD real
      final dbPath = await _getDbPath();

      // Cerrar la base de datos actual
      await _dbHelper.close();

      // Reemplazar con el backup
      final backupFile = File(pickedFile.path!);
      await backupFile.copy(dbPath);

      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Importa transacciones desde un archivo CSV
  Future<bool> importFromCSV() async {
    try {
      // Seleccionar archivo CSV
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return false;
      }

      final pickedFile = result.files.first;
      if (pickedFile.path == null) {
        return false;
      }

      // Leer el archivo CSV
      final file = File(pickedFile.path!);
      final csvString = await file.readAsString();
      final rows = const CsvToListConverter().convert(csvString);

      if (rows.isEmpty) {
        throw Exception('El archivo CSV está vacío');
      }

      // Obtener categorías existentes
      final categories = await _dbHelper.getAllCategories();
      final categoryMap = <String, int>{};
      for (final cat in categories) {
        categoryMap[cat.name.toLowerCase()] = cat.id!;
      }

      // Procesar filas (saltar encabezado)
      int imported = 0;
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length < 5) continue;

        try {
          // Formato esperado: Fecha, Tipo, Categoría, Descripción, Monto
          final dateStr = row[0].toString();
          final type = row[1].toString().toLowerCase();
          final categoryName = row[2].toString().toLowerCase();
          final description = row[3].toString();
          final amount = double.parse(row[4].toString());

          // Buscar categoría
          int? categoryId = categoryMap[categoryName];

          // Si no existe, crear categoría genérica
          if (categoryId == null) {
            final newCategory = CategoryModel(
              name: row[2].toString(),
              type: type == 'ingreso' ? 'income' : 'expense',
              icon: '📝',
              color: type == 'ingreso' ? 'FF10B981' : 'FFEF4444',
            );
            final created = await _dbHelper.createCategory(newCategory);
            categoryId = created.id!;
            categoryMap[categoryName] = categoryId;
          }

          // Parsear fecha
          DateTime date;
          try {
            date = DateFormat('dd/MM/yyyy HH:mm').parse(dateStr);
          } catch (e) {
            try {
              date = DateFormat('dd/MM/yyyy').parse(dateStr);
            } catch (e) {
              date = DateTime.now();
            }
          }

          // Crear transacción
          final transaction = TransactionModel(
            type: type == 'ingreso' ? 'income' : 'expense',
            amount: amount,
            categoryId: categoryId,
            description: description,
            date: date,
          );

          await _dbHelper.createTransaction(transaction);
          imported++;
        } catch (e) {
          // Saltar fila con error
          continue;
        }
      }

      return imported > 0;
    } catch (e) {
      rethrow;
    }
  }
}
