import 'package:flutter/material.dart';
import 'habit_category.dart';

/// Plantilla predefinida para crear hábitos rápidamente
class HabitTemplate {
  final String name;
  final String description;
  final String iconName;
  final Color color;
  final HabitCategory category;
  final String? suggestedTime;

  const HabitTemplate({
    required this.name,
    required this.description,
    required this.iconName,
    required this.color,
    required this.category,
    this.suggestedTime,
  });

  /// Lista de plantillas predefinidas para hábitos comunes
  static List<HabitTemplate> getTemplates() {
    return [
      // Salud
      const HabitTemplate(
        name: 'Tomar agua',
        description: 'Beber 8 vasos de agua al día',
        iconName: 'local_drink',
        color: Colors.blue,
        category: HabitCategory.health,
        suggestedTime: '08:00',
      ),
      const HabitTemplate(
        name: 'Dormir 8 horas',
        description: 'Mantener un horario regular de sueño',
        iconName: 'bedtime',
        color: Colors.indigo,
        category: HabitCategory.health,
        suggestedTime: '22:00',
      ),
      const HabitTemplate(
        name: 'Tomar vitaminas',
        description: 'Tomar suplementos vitamínicos diarios',
        iconName: 'medication',
        color: Colors.orange,
        category: HabitCategory.health,
        suggestedTime: '09:00',
      ),

      // Fitness
      const HabitTemplate(
        name: 'Hacer ejercicio',
        description: '30 minutos de actividad física',
        iconName: 'fitness_center',
        color: Colors.red,
        category: HabitCategory.fitness,
        suggestedTime: '07:00',
      ),
      const HabitTemplate(
        name: 'Caminar 10,000 pasos',
        description: 'Alcanzar la meta diaria de pasos',
        iconName: 'directions_run',
        color: Colors.green,
        category: HabitCategory.fitness,
        suggestedTime: '18:00',
      ),
      const HabitTemplate(
        name: 'Estiramientos',
        description: '15 minutos de estiramientos y flexibilidad',
        iconName: 'self_improvement',
        color: Colors.teal,
        category: HabitCategory.fitness,
        suggestedTime: '06:30',
      ),

      // Aprendizaje
      const HabitTemplate(
        name: 'Leer 30 minutos',
        description: 'Dedicar tiempo a la lectura diaria',
        iconName: 'menu_book',
        color: Colors.purple,
        category: HabitCategory.learning,
        suggestedTime: '20:00',
      ),
      const HabitTemplate(
        name: 'Estudiar un idioma',
        description: 'Practicar idioma extranjero 20 minutos',
        iconName: 'language',
        color: Colors.cyan,
        category: HabitCategory.learning,
        suggestedTime: '19:00',
      ),
      const HabitTemplate(
        name: 'Curso online',
        description: 'Completar lección del día',
        iconName: 'school',
        color: Colors.deepPurple,
        category: HabitCategory.learning,
        suggestedTime: '19:30',
      ),

      // Productividad
      const HabitTemplate(
        name: 'Planificar el día',
        description: 'Revisar agenda y prioridades',
        iconName: 'edit_calendar',
        color: Colors.amber,
        category: HabitCategory.productivity,
        suggestedTime: '08:30',
      ),
      const HabitTemplate(
        name: 'Revisar emails',
        description: 'Inbox Zero - organizar correos',
        iconName: 'email',
        color: Colors.blue,
        category: HabitCategory.productivity,
        suggestedTime: '09:30',
      ),
      const HabitTemplate(
        name: 'Pomodoro de trabajo',
        description: 'Sesión enfocada de 25 minutos',
        iconName: 'timer',
        color: Colors.red,
        category: HabitCategory.productivity,
        suggestedTime: '10:00',
      ),

      // Mindfulness
      const HabitTemplate(
        name: 'Meditar',
        description: '10 minutos de meditación consciente',
        iconName: 'self_improvement',
        color: Colors.deepPurple,
        category: HabitCategory.mindfulness,
        suggestedTime: '07:00',
      ),
      const HabitTemplate(
        name: 'Diario de gratitud',
        description: 'Escribir 3 cosas por las que estoy agradecido',
        iconName: 'edit_note',
        color: Colors.pink,
        category: HabitCategory.mindfulness,
        suggestedTime: '21:00',
      ),
      const HabitTemplate(
        name: 'Respiración profunda',
        description: '5 minutos de ejercicios de respiración',
        iconName: 'air',
        color: Colors.lightBlue,
        category: HabitCategory.mindfulness,
        suggestedTime: '12:00',
      ),

      // Personal
      const HabitTemplate(
        name: 'Arreglar la cama',
        description: 'Empezar el día con una pequeña victoria',
        iconName: 'bed',
        color: Colors.brown,
        category: HabitCategory.personal,
        suggestedTime: '07:30',
      ),
      const HabitTemplate(
        name: 'Cuidado personal',
        description: 'Rutina de cuidado de la piel',
        iconName: 'spa',
        color: Colors.pink,
        category: HabitCategory.personal,
        suggestedTime: '21:30',
      ),

      // Social
      const HabitTemplate(
        name: 'Llamar a un ser querido',
        description: 'Conectar con familia o amigos',
        iconName: 'phone',
        color: Colors.green,
        category: HabitCategory.social,
        suggestedTime: '18:30',
      ),
      const HabitTemplate(
        name: 'Networking',
        description: 'Interactuar con la comunidad profesional',
        iconName: 'groups',
        color: Colors.blue,
        category: HabitCategory.social,
        suggestedTime: '17:00',
      ),
    ];
  }

  /// Obtener plantillas por categoría
  static List<HabitTemplate> getTemplatesByCategory(HabitCategory category) {
    return getTemplates()
        .where((template) => template.category == category)
        .toList();
  }
}
