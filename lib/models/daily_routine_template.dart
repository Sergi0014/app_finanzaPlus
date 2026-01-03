import 'package:flutter/material.dart';
import 'habit_category.dart';

/// Plantilla de rutina diaria para un día específico
class DailyRoutineTemplate {
  final int dayNumber;
  final String description;
  final List<HabitTemplateByTime> habits;

  const DailyRoutineTemplate({
    required this.dayNumber,
    required this.description,
    required this.habits,
  });

  /// Obtiene todas las plantillas organizadas por días numerados
  static List<DailyRoutineTemplate> getDailyTemplates() {
    return [
      // Día 1 - Rutina básica de inicio
      DailyRoutineTemplate(
        dayNumber: 1,
        description: 'Rutina básica para empezar con buenos hábitos',
        habits: [
          HabitTemplateByTime(
            name: 'Tomar agua al despertar',
            description: '2 vasos de agua para hidratar',
            iconName: 'local_drink',
            color: Colors.blue,
            category: HabitCategory.health,
            time: '07:00',
          ),
          HabitTemplateByTime(
            name: 'Hacer ejercicio',
            description: '30 minutos de actividad física',
            iconName: 'fitness_center',
            color: Colors.red,
            category: HabitCategory.fitness,
            time: '07:30',
          ),
          HabitTemplateByTime(
            name: 'Desayuno saludable',
            description: 'Comida nutritiva y balanceada',
            iconName: 'restaurant',
            color: Colors.green,
            category: HabitCategory.health,
            time: '08:00',
          ),
          HabitTemplateByTime(
            name: 'Planificar el día',
            description: 'Revisar tareas y prioridades',
            iconName: 'edit_calendar',
            color: Colors.amber,
            category: HabitCategory.productivity,
            time: '08:30',
          ),
          HabitTemplateByTime(
            name: 'Leer 30 minutos',
            description: 'Lectura de desarrollo personal',
            iconName: 'menu_book',
            color: Colors.purple,
            category: HabitCategory.learning,
            time: '21:00',
          ),
          HabitTemplateByTime(
            name: 'Dormir temprano',
            description: 'Acostarse antes de las 10 PM',
            iconName: 'bedtime',
            color: Colors.indigo,
            category: HabitCategory.health,
            time: '22:00',
          ),
        ],
      ),

      // Día 2 - Enfoque en salud y fitness
      DailyRoutineTemplate(
        dayNumber: 2,
        description: 'Rutina enfocada en salud y bienestar físico',
        habits: [
          HabitTemplateByTime(
            name: 'Estiramientos matutinos',
            description: '15 minutos de flexibilidad',
            iconName: 'self_improvement',
            color: Colors.teal,
            category: HabitCategory.fitness,
            time: '06:30',
          ),
          HabitTemplateByTime(
            name: 'Cardio 30 min',
            description: 'Correr, bicicleta o nadar',
            iconName: 'directions_run',
            color: Colors.red,
            category: HabitCategory.fitness,
            time: '07:00',
          ),
          HabitTemplateByTime(
            name: 'Tomar vitaminas',
            description: 'Suplementos diarios',
            iconName: 'medication',
            color: Colors.orange,
            category: HabitCategory.health,
            time: '08:00',
          ),
          HabitTemplateByTime(
            name: 'Almuerzo saludable',
            description: 'Proteínas y vegetales',
            iconName: 'lunch_dining',
            color: Colors.green,
            category: HabitCategory.health,
            time: '12:30',
          ),
          HabitTemplateByTime(
            name: 'Caminar 10,000 pasos',
            description: 'Actividad física ligera',
            iconName: 'directions_walk',
            color: Colors.lightGreen,
            category: HabitCategory.fitness,
            time: '18:00',
          ),
          HabitTemplateByTime(
            name: 'Yoga nocturno',
            description: '20 minutos de relajación',
            iconName: 'self_improvement',
            color: Colors.purple,
            category: HabitCategory.mindfulness,
            time: '20:00',
          ),
        ],
      ),

      // Día 3 - Productividad y aprendizaje
      DailyRoutineTemplate(
        dayNumber: 3,
        description: 'Rutina para máxima productividad y aprendizaje',
        habits: [
          HabitTemplateByTime(
            name: 'Revisión de metas',
            description: 'Objetivos del día',
            iconName: 'flag',
            color: Colors.amber,
            category: HabitCategory.productivity,
            time: '08:00',
          ),
          HabitTemplateByTime(
            name: 'Sesión Pomodoro',
            description: '4 bloques de 25 minutos',
            iconName: 'timer',
            color: Colors.blue,
            category: HabitCategory.productivity,
            time: '09:00',
          ),
          HabitTemplateByTime(
            name: 'Estudiar idiomas',
            description: '30 minutos de práctica',
            iconName: 'language',
            color: Colors.cyan,
            category: HabitCategory.learning,
            time: '11:00',
          ),
          HabitTemplateByTime(
            name: 'Curso online',
            description: 'Completar lección del día',
            iconName: 'school',
            color: Colors.deepPurple,
            category: HabitCategory.learning,
            time: '19:00',
          ),
          HabitTemplateByTime(
            name: 'Revisar emails',
            description: 'Inbox Zero',
            iconName: 'email',
            color: Colors.indigo,
            category: HabitCategory.productivity,
            time: '17:00',
          ),
          HabitTemplateByTime(
            name: 'Planificar mañana',
            description: 'Agenda del día siguiente',
            iconName: 'calendar_month',
            color: Colors.orange,
            category: HabitCategory.productivity,
            time: '21:00',
          ),
        ],
      ),

      // Día 4 - Balance y mindfulness
      DailyRoutineTemplate(
        dayNumber: 4,
        description: 'Rutina equilibrada con enfoque en bienestar mental',
        habits: [
          HabitTemplateByTime(
            name: 'Meditación',
            description: '15 minutos de mindfulness',
            iconName: 'self_improvement',
            color: Colors.deepPurple,
            category: HabitCategory.mindfulness,
            time: '06:30',
          ),
          HabitTemplateByTime(
            name: 'Gratitud matutina',
            description: '3 cosas por las que estoy agradecido',
            iconName: 'volunteer_activism',
            color: Colors.pink,
            category: HabitCategory.mindfulness,
            time: '07:00',
          ),
          HabitTemplateByTime(
            name: 'Ejercicio moderado',
            description: '30 minutos de actividad',
            iconName: 'fitness_center',
            color: Colors.red,
            category: HabitCategory.fitness,
            time: '07:30',
          ),
          HabitTemplateByTime(
            name: 'Desconectar pantallas',
            description: '1 hora sin dispositivos',
            iconName: 'do_not_disturb_on',
            color: Colors.orange,
            category: HabitCategory.mindfulness,
            time: '13:00',
          ),
          HabitTemplateByTime(
            name: 'Respiración profunda',
            description: '5 minutos de ejercicios',
            iconName: 'air',
            color: Colors.lightBlue,
            category: HabitCategory.mindfulness,
            time: '16:00',
          ),
          HabitTemplateByTime(
            name: 'Diario de gratitud',
            description: 'Escribir reflexiones del día',
            iconName: 'edit_note',
            color: Colors.purple,
            category: HabitCategory.mindfulness,
            time: '21:00',
          ),
        ],
      ),

      // Día 5 - Vida social y conexiones
      DailyRoutineTemplate(
        dayNumber: 5,
        description: 'Rutina que prioriza relaciones y conexiones',
        habits: [
          HabitTemplateByTime(
            name: 'Llamar a un ser querido',
            description: 'Conectar con familia o amigos',
            iconName: 'phone',
            color: Colors.green,
            category: HabitCategory.social,
            time: '09:00',
          ),
          HabitTemplateByTime(
            name: 'Almuerzo social',
            description: 'Comer con compañeros',
            iconName: 'restaurant_menu',
            color: Colors.teal,
            category: HabitCategory.social,
            time: '13:00',
          ),
          HabitTemplateByTime(
            name: 'Networking',
            description: 'Interactuar con comunidad',
            iconName: 'groups',
            color: Colors.blue,
            category: HabitCategory.social,
            time: '17:00',
          ),
          HabitTemplateByTime(
            name: 'Actividad en familia',
            description: 'Tiempo de calidad juntos',
            iconName: 'family_restroom',
            color: Colors.pink,
            category: HabitCategory.social,
            time: '19:00',
          ),
          HabitTemplateByTime(
            name: 'Cena especial',
            description: 'Cocinar algo delicioso',
            iconName: 'dinner_dining',
            color: Colors.brown,
            category: HabitCategory.personal,
            time: '20:00',
          ),
        ],
      ),

      // Día 6 - Autocuidado personal
      DailyRoutineTemplate(
        dayNumber: 6,
        description: 'Rutina de autocuidado y desarrollo personal',
        habits: [
          HabitTemplateByTime(
            name: 'Arreglar la cama',
            description: 'Primera victoria del día',
            iconName: 'bed',
            color: Colors.brown,
            category: HabitCategory.personal,
            time: '07:00',
          ),
          HabitTemplateByTime(
            name: 'Rutina de skincare',
            description: 'Cuidado de la piel',
            iconName: 'spa',
            color: Colors.pink,
            category: HabitCategory.personal,
            time: '07:30',
          ),
          HabitTemplateByTime(
            name: 'Hobby creativo',
            description: 'Pintar, música, manualidades',
            iconName: 'brush',
            color: Colors.purple,
            category: HabitCategory.personal,
            time: '10:00',
          ),
          HabitTemplateByTime(
            name: 'Organizar espacio',
            description: 'Limpiar y ordenar',
            iconName: 'cleaning_services',
            color: Colors.cyan,
            category: HabitCategory.personal,
            time: '14:00',
          ),
          HabitTemplateByTime(
            name: 'Baño relajante',
            description: 'Tiempo para ti mismo',
            iconName: 'spa',
            color: Colors.teal,
            category: HabitCategory.personal,
            time: '20:00',
          ),
          HabitTemplateByTime(
            name: 'Película favorita',
            description: 'Entretenimiento y relax',
            iconName: 'movie',
            color: Colors.red,
            category: HabitCategory.personal,
            time: '21:00',
          ),
        ],
      ),

      // Día 7 - Preparación para la semana
      DailyRoutineTemplate(
        dayNumber: 7,
        description: 'Rutina para organizar y preparar la semana',
        habits: [
          HabitTemplateByTime(
            name: 'Revisar finanzas',
            description: 'Gastos de la semana',
            iconName: 'account_balance_wallet',
            color: Colors.amber,
            category: HabitCategory.productivity,
            time: '09:00',
          ),
          HabitTemplateByTime(
            name: 'Planificar semana',
            description: 'Objetivos y calendario',
            iconName: 'calendar_month',
            color: Colors.blue,
            category: HabitCategory.productivity,
            time: '10:00',
          ),
          HabitTemplateByTime(
            name: 'Meal prep',
            description: 'Preparar comidas de la semana',
            iconName: 'kitchen',
            color: Colors.teal,
            category: HabitCategory.productivity,
            time: '11:00',
          ),
          HabitTemplateByTime(
            name: 'Organizar ropa',
            description: 'Planchar y preparar outfits',
            iconName: 'checkroom',
            color: Colors.brown,
            category: HabitCategory.personal,
            time: '15:00',
          ),
          HabitTemplateByTime(
            name: 'Revisión de metas',
            description: 'Evaluar progreso semanal',
            iconName: 'emoji_events',
            color: Colors.orange,
            category: HabitCategory.productivity,
            time: '17:00',
          ),
          HabitTemplateByTime(
            name: 'Dormir temprano',
            description: 'Prepararse para el lunes',
            iconName: 'bedtime',
            color: Colors.indigo,
            category: HabitCategory.health,
            time: '21:30',
          ),
        ],
      ),
    ];
  }

  /// Obtiene una plantilla específica por número de día
  static DailyRoutineTemplate? getTemplateByDay(int dayNumber) {
    final templates = getDailyTemplates();
    try {
      return templates.firstWhere((t) => t.dayNumber == dayNumber);
    } catch (e) {
      return null;
    }
  }
}

/// Hábito individual dentro de una plantilla con horario
class HabitTemplateByTime {
  final String name;
  final String description;
  final String iconName;
  final Color color;
  final HabitCategory category;
  final String time;

  const HabitTemplateByTime({
    required this.name,
    required this.description,
    required this.iconName,
    required this.color,
    required this.category,
    required this.time,
  });
}
