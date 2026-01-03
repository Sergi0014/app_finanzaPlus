import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'report_service.dart';

/// Servicio de notificaciones locales
class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final ReportService _reportService = ReportService();

  NotificationService._init();

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  /// Solicita permisos de notificación
  Future<bool> requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    return true;
  }

  /// Programa notificación semanal
  Future<void> scheduleWeeklyNotification() async {
    await _notifications.zonedSchedule(
      0,
      'Reporte Semanal Disponible',
      'Tu reporte semanal está listo. ¡Revisa tus finanzas!',
      _nextInstanceOfMonday(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_report_channel',
          'Reportes Semanales',
          channelDescription: 'Notificaciones de reportes semanales',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// Cancela todas las notificaciones programadas
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Muestra notificación inmediata con resumen semanal
  Future<void> showWeeklySummary() async {
    final report = await _reportService.generateWeeklyReport();

    final String body = 'Balance: \$${report.balance.toStringAsFixed(2)}\n'
        'Ingresos: \$${report.totalIncome.toStringAsFixed(2)}\n'
        'Egresos: \$${report.totalExpense.toStringAsFixed(2)}';

    await _notifications.show(
      1,
      'Resumen Semanal',
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_summary_channel',
          'Resúmenes Semanales',
          channelDescription: 'Resúmenes de la semana',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Calcula la próxima instancia de lunes a las 9:00 AM
  tz.TZDateTime _nextInstanceOfMonday() {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      9,
      0,
    );

    // Si ya pasó las 9 AM, programar para el siguiente lunes
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Avanzar hasta el lunes
    while (scheduledDate.weekday != DateTime.monday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // ==================== NOTIFICACIONES DE HÁBITOS ====================

  /// Programa notificación diaria para un hábito
  Future<void> scheduleHabitNotification({
    required int habitId,
    required String habitName,
    required int hour,
    required int minute,
  }) async {
    await _notifications.zonedSchedule(
      habitId + 1000, // ID único basado en el ID del hábito
      'Recordatorio de Hábito',
      '¡Es hora de: $habitName!',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_reminder_channel',
          'Recordatorios de Hábitos',
          channelDescription: 'Notificaciones diarias para recordar hábitos',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancela la notificación de un hábito específico
  Future<void> cancelHabitNotification(int habitId) async {
    await _notifications.cancel(habitId + 1000);
  }

  /// Calcula la próxima instancia de una hora específica
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Si ya pasó la hora, programar para mañana
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Muestra una notificación de motivación cuando se completa un hábito
  Future<void> showHabitCompletionMotivation(String habitName) async {
    const motivationalMessages = [
      '¡Excelente trabajo!',
      '¡Sigue así!',
      '¡Un día más de éxito!',
      '¡Vas por buen camino!',
      '¡Felicitaciones!',
    ];

    final message = (motivationalMessages..shuffle()).first;

    await _notifications.show(
      9999,
      message,
      'Has completado: $habitName',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_completion_channel',
          'Logros de Hábitos',
          channelDescription:
              'Notificaciones de motivación al completar hábitos',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
