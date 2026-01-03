import 'package:flutter_test/flutter_test.dart';
import 'package:app_ingresos/models/category_model.dart';

void main() {
  group('CategoryModel', () {
    test('debe crear una categoría correctamente', () {
      final category = CategoryModel(
        name: 'Salario',
        type: 'income',
        icon: '💼',
        color: 'FF4CAF50',
      );

      expect(category.name, 'Salario');
      expect(category.type, 'income');
      expect(category.icon, '💼');
      expect(category.color, 'FF4CAF50');
      expect(category.isIncome, true);
      expect(category.isExpense, false);
    });

    test('debe convertir a mapa correctamente', () {
      final category = CategoryModel(
        id: 1,
        name: 'Comida',
        type: 'expense',
        icon: '🍔',
        color: 'FFF44336',
      );

      final map = category.toMap();

      expect(map['id'], 1);
      expect(map['name'], 'Comida');
      expect(map['type'], 'expense');
      expect(map['icon'], '🍔');
      expect(map['color'], 'FFF44336');
    });

    test('debe crear desde mapa correctamente', () {
      final map = {
        'id': 1,
        'name': 'Transporte',
        'type': 'expense',
        'icon': '🚗',
        'color': 'FFFF5722',
        'created_at': DateTime(2024, 1, 1).toIso8601String(),
        'updated_at': DateTime(2024, 1, 1).toIso8601String(),
      };

      final category = CategoryModel.fromMap(map);

      expect(category.id, 1);
      expect(category.name, 'Transporte');
      expect(category.type, 'expense');
      expect(category.icon, '🚗');
      expect(category.color, 'FFFF5722');
    });

    test('copyWith debe actualizar campos correctamente', () {
      final category = CategoryModel(
        id: 1,
        name: 'Original',
        type: 'income',
        icon: '💼',
        color: 'FF4CAF50',
      );

      final updated = category.copyWith(
        name: 'Actualizado',
        icon: '💰',
      );

      expect(updated.id, 1);
      expect(updated.name, 'Actualizado');
      expect(updated.icon, '💰');
      expect(updated.type, 'income'); // No cambió
      expect(updated.color, 'FF4CAF50'); // No cambió
    });

    test('isIncome debe retornar true para categorías de ingreso', () {
      final category = CategoryModel(
        name: 'Salario',
        type: 'income',
        icon: '💼',
        color: 'FF4CAF50',
      );

      expect(category.isIncome, true);
      expect(category.isExpense, false);
    });

    test('isExpense debe retornar true para categorías de egreso', () {
      final category = CategoryModel(
        name: 'Comida',
        type: 'expense',
        icon: '🍔',
        color: 'FFF44336',
      );

      expect(category.isExpense, true);
      expect(category.isIncome, false);
    });
  });
}
