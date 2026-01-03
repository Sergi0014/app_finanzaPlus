/// Modelo para representar la finalización de un hábito en un día específico
class HabitCompletionModel {
  final int? id;
  final int habitId;
  final DateTime date; // Fecha del día (solo fecha, sin hora)
  final bool isCompleted;
  final String? notes; // Notas opcionales
  final DateTime createdAt;
  final DateTime updatedAt;

  HabitCompletionModel({
    this.id,
    required this.habitId,
    required this.date,
    this.isCompleted = false,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Crea una finalización desde un mapa (base de datos)
  factory HabitCompletionModel.fromMap(Map<String, dynamic> map) {
    return HabitCompletionModel(
      id: map['id'] as int?,
      habitId: map['habit_id'] as int,
      date: DateTime.parse(map['date'] as String),
      isCompleted: (map['is_completed'] as int) == 1,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Convierte la finalización a un mapa (base de datos)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'habit_id': habitId,
      'date': _dateOnly(date).toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Obtiene solo la fecha sin la hora
  DateTime _dateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Crea una copia de la finalización con algunos campos modificados
  HabitCompletionModel copyWith({
    int? id,
    int? habitId,
    DateTime? date,
    bool? isCompleted,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HabitCompletionModel(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'HabitCompletionModel(id: $id, habitId: $habitId, date: $date, isCompleted: $isCompleted)';
  }
}
