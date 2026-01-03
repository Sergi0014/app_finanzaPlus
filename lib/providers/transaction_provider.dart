import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';

/// Provider para gestionar las transacciones
class TransactionProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<TransactionModel> get transactions => _transactions;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Obtiene todas las transacciones y categorías
  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _dbHelper.getAllTransactions();
      _categories = await _dbHelper.getAllCategories();
    } catch (e) {
      _error = 'Error al cargar datos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtiene el balance actual
  Future<Map<String, double>> getBalance() async {
    return await _dbHelper.getBalance();
  }

  /// Obtiene transacciones por tipo
  List<TransactionModel> getTransactionsByType(String type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  /// Obtiene categorías por tipo
  List<CategoryModel> getCategoriesByType(String type) {
    return _categories.where((c) => c.type == type).toList();
  }

  /// Obtiene una categoría por ID
  CategoryModel? getCategoryById(int id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // ==================== OPERACIONES CRUD TRANSACCIONES ====================

  /// Crea una nueva transacción
  Future<bool> addTransaction(TransactionModel transaction) async {
    try {
      final newTransaction = await _dbHelper.createTransaction(transaction);
      _transactions.insert(0, newTransaction);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al crear transacción: $e';
      notifyListeners();
      return false;
    }
  }

  /// Actualiza una transacción existente
  Future<bool> updateTransaction(TransactionModel transaction) async {
    try {
      await _dbHelper.updateTransaction(transaction);
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Error al actualizar transacción: $e';
      notifyListeners();
      return false;
    }
  }

  /// Elimina una transacción
  Future<bool> deleteTransaction(int id) async {
    try {
      await _dbHelper.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al eliminar transacción: $e';
      notifyListeners();
      return false;
    }
  }

  // ==================== OPERACIONES CRUD CATEGORÍAS ====================

  /// Crea una nueva categoría
  Future<bool> addCategory(CategoryModel category) async {
    try {
      final newCategory = await _dbHelper.createCategory(category);
      _categories.add(newCategory);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al crear categoría: $e';
      notifyListeners();
      return false;
    }
  }

  /// Actualiza una categoría existente
  Future<bool> updateCategory(CategoryModel category) async {
    try {
      await _dbHelper.updateCategory(category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Error al actualizar categoría: $e';
      notifyListeners();
      return false;
    }
  }

  /// Elimina una categoría
  Future<bool> deleteCategory(int id) async {
    try {
      await _dbHelper.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al eliminar categoría: $e';
      notifyListeners();
      return false;
    }
  }

  /// Limpia el mensaje de error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
