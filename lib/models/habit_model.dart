/// Modelo para representar un hábito
class HabitModel {
  final int? id;
  final String name;
  final String? description;
  final String iconName; // Nombre del icono
  final int colorValue; // Valor del color
  final bool isActive; // Si el hábito está activo
  final String? notificationTime; // Hora de notificación (HH:mm)
  final String? category; // Categoría del hábito
  final DateTime createdAt;
  final DateTime updatedAt;

  HabitModel({
    this.id,
    required this.name,
    this.description,
    this.iconName = 'check_circle',
    this.colorValue = 0xFF2196F3,
    this.isActive = true,
    this.notificationTime,
    this.category,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Crea un hábito desde un mapa (base de datos)
  factory HabitModel.fromMap(Map<String, dynamic> map) {
    return HabitModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      iconName: map['icon_name'] as String? ?? 'check_circle',
      colorValue: map['color_value'] as int? ?? 0xFF2196F3,
      isActive: (map['is_active'] as int) == 1,
      notificationTime: map['notification_time'] as String?,
      category: map['category'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Convierte el hábito a un mapa (base de datos)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'icon_name': iconName,
      'color_value': colorValue,
      'is_active': isActive ? 1 : 0,
      'notification_time': notificationTime,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crea una copia del hábito con algunos campos modificados
  HabitModel copyWith({
    int? id,
    String? name,
    String? description,
    String? iconName,
    int? colorValue,
    bool? isActive,
    String? notificationTime,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
      isActive: isActive ?? this.isActive,
      notificationTime: notificationTime ?? this.notificationTime,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'HabitModel(id: $id, name: $name, isActive: $isActive)';
  }
}
