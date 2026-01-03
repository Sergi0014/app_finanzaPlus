import 'package:flutter_test/flutter_test.dart';
import 'package:app_ingresos/models/transaction_model.dart';

void main() {
  group('TransactionModel', () {
    test('debe crear una transacción correctamente', () {
      final transaction = TransactionModel(
        type: 'income',
        amount: 1000.0,
        categoryId: 1,
        description: 'Salario',
        date: DateTime(2024, 1, 1),
      );

      expect(transaction.type, 'income');
      expect(transaction.amount, 1000.0);
      expect(transaction.categoryId, 1);
      expect(transaction.description, 'Salario');
      expect(transaction.isIncome, true);
      expect(transaction.isExpense, false);
    });

    test('debe convertir a mapa correctamente', () {
      final transaction = TransactionModel(
        id: 1,
        type: 'expense',
        amount: 50.0,
        categoryId: 2,
        description: 'Almuerzo',
        date: DateTime(2024, 1, 1),
      );

      final map = transaction.toMap();

      expect(map['id'], 1);
      expect(map['type'], 'expense');
      expect(map['amount'], 50.0);
      expect(map['category_id'], 2);
      expect(map['description'], 'Almuerzo');
    });

    test('debe crear desde mapa correctamente', () {
      final map = {
        'id': 1,
        'type': 'income',
        'amount': 500.0,
        'category_id': 1,
        'description': 'Freelance',
        'date': DateTime(2024, 1, 1).toIso8601String(),
        'created_at': DateTime(2024, 1, 1).toIso8601String(),
        'updated_at': DateTime(2024, 1, 1).toIso8601String(),
      };

      final transaction = TransactionModel.fromMap(map);

      expect(transaction.id, 1);
      expect(transaction.type, 'income');
      expect(transaction.amount, 500.0);
      expect(transaction.categoryId, 1);
      expect(transaction.description, 'Freelance');
    });

    test('copyWith debe actualizar campos correctamente', () {
      final transaction = TransactionModel(
        id: 1,
        type: 'expense',
        amount: 100.0,
        categoryId: 1,
        description: 'Original',
        date: DateTime(2024, 1, 1),
      );

      final updated = transaction.copyWith(
        description: 'Actualizado',
        amount: 150.0,
      );

      expect(updated.id, 1);
      expect(updated.description, 'Actualizado');
      expect(updated.amount, 150.0);
      expect(updated.categoryId, 1); // No cambió
    });

    test('isIncome debe retornar true para ingresos', () {
      final transaction = TransactionModel(
        type: 'income',
        amount: 100.0,
        categoryId: 1,
        description: 'Test',
        date: DateTime(2024, 1, 1),
      );

      expect(transaction.isIncome, true);
      expect(transaction.isExpense, false);
    });

    test('isExpense debe retornar true para egresos', () {
      final transaction = TransactionModel(
        type: 'expense',
        amount: 100.0,
        categoryId: 1,
        description: 'Test',
        date: DateTime(2024, 1, 1),
      );

      expect(transaction.isExpense, true);
      expect(transaction.isIncome, false);
    });
  });
}
