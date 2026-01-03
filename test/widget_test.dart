import 'package:flutter_test/flutter_test.dart';
import 'package:app_ingresos/models/transaction_model.dart';
import 'package:app_ingresos/models/category_model.dart';

void main() {
  test('Modelos de datos funcionan correctamente', () {
    // Test Transaction
    final transaction = TransactionModel(
      type: 'income',
      amount: 1000.0,
      categoryId: 1,
      description: 'Test',
      date: DateTime(2024, 1, 1),
    );
    expect(transaction.isIncome, true);

    // Test Category
    final category = CategoryModel(
      name: 'Test',
      type: 'expense',
      icon: '📝',
      color: 'FFEF4444',
    );
    expect(category.isExpense, true);
  });
}
