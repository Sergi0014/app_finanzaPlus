import 'package:flutter/material.dart';

/// Categorías predefinidas para hábitos
enum HabitCategory {
  health('Salud', Icons.favorite, 0xFFE91E63),
  productivity('Productividad', Icons.work, 0xFF2196F3),
  personal('Personal', Icons.person, 0xFF9C27B0),
  social('Social', Icons.people, 0xFFFF9800),
  learning('Aprendizaje', Icons.school, 0xFF00BCD4),
  fitness('Ejercicio', Icons.fitness_center, 0xFF4CAF50),
  mindfulness('Mindfulness', Icons.self_improvement, 0xFF673AB7),
  other('Otro', Icons.more_horiz, 0xFF607D8B);

  final String displayName;
  final IconData icon;
  final int colorValue;

  const HabitCategory(this.displayName, this.icon, this.colorValue);

  static HabitCategory fromString(String value) {
    return HabitCategory.values.firstWhere(
      (cat) => cat.name == value,
      orElse: () => HabitCategory.other,
    );
  }
}
