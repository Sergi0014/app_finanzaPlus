# ❓ Preguntas Frecuentes (FAQ) - Módulo de Hábitos

## 🔧 Instalación y Configuración

### **P: ¿Necesito instalar paquetes adicionales?**

**R:** No. Todos los paquetes necesarios ya están en `pubspec.yaml`:

- `provider` - Gestión de estado
- `sqflite` - Base de datos
- `flutter_local_notifications` - Notificaciones
- `intl` - Formateo de fechas

Solo ejecuta:

```bash
flutter pub get
```

### **P: ¿Qué pasa con la base de datos existente?**

**R:** La base de datos se actualiza automáticamente de la versión 1 a la 2 gracias al método `_onUpgrade`. Tus datos existentes de transacciones se mantienen intactos.

### **P: ¿Puedo usar esto en iOS y Android?**

**R:** Sí, el código es multiplataforma. Sin embargo, para notificaciones en iOS necesitas configurar permisos adicionales en `ios/Runner/Info.plist`.

---

## 🎨 Personalización

### **P: ¿Cómo agrego más iconos?**

**R:** En `add_edit_habit_screen.dart`, edita la lista `_availableIcons`:

```dart
final List<String> _availableIcons = [
  'check_circle',
  'fitness_center',
  'water_drop',      // NUEVO
  'coffee',          // NUEVO
  'emoji_events',    // NUEVO
  // ... más iconos de Material Icons
];
```

Luego agrega los casos en el método `_getIconData()`:

```dart
case 'water_drop':
  return Icons.water_drop;
case 'coffee':
  return Icons.coffee;
// ...
```

### **P: ¿Cómo cambio los colores disponibles?**

**R:** En `add_edit_habit_screen.dart`, modifica `_availableColors`:

```dart
final List<Color> _availableColors = [
  Colors.blue,
  Colors.green,
  Color(0xFF8E24AA),  // Púrpura personalizado
  Color(0xFFFF6F00),  // Naranja personalizado
  // ... más colores
];
```

### **P: ¿Puedo cambiar el diseño de las tarjetas de hábitos?**

**R:** Sí. Edita `lib/widgets/habit_card.dart`. Es un widget completamente personalizable.

---

## 💾 Base de Datos

### **P: ¿Dónde se guardan los datos?**

**R:** En una base de datos SQLite local en el dispositivo. La ruta es:

- **Android**: `/data/data/<package_name>/databases/app_ingresos.db`
- **iOS**: `Library/Application Support/app_ingresos.db`

### **P: ¿Cómo borro todos los hábitos de prueba?**

**R:** Opción 1 - Desde la app (manualmente):

- Toca los 3 puntos en cada hábito → Eliminar

Opción 2 - Desinstalar la app:

```bash
# La base de datos se eliminará
flutter clean
# Reinstala
flutter run
```

Opción 3 - Programáticamente (agregar en DatabaseHelper):

```dart
Future<void> deleteAllHabits() async {
  final db = await database;
  await db.delete('habit_completions');
  await db.delete('habits');
}
```

### **P: ¿Puedo exportar mis hábitos?**

**R:** Actualmente no está implementado, pero puedes agregarlo:

```dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> exportHabitsToJson() async {
  final habits = await _dbHelper.getAllHabits();
  final jsonData = habits.map((h) => h.toMap()).toList();

  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/habits_backup.json');
  await file.writeAsString(jsonEncode(jsonData));

  return file.path;
}
```

---

## 🔔 Notificaciones

### **P: Las notificaciones no funcionan en Android 13+**

**R:** Android 13+ requiere permisos explícitos. Ya están implementados en `NotificationService`, pero asegúrate de:

1. El usuario aceptó los permisos cuando se le preguntó
2. Verifica en Configuración > Apps > Tu App > Notificaciones

Si no funciona:

```dart
// En main.dart, después de inicializar
await NotificationService.instance.requestPermissions();
```

### **P: ¿Cómo desactivo las notificaciones de un hábito?**

**R:** En `AddEditHabitScreen`, si eliminas la hora de notificación (dejándola en null), automáticamente se cancela:

```dart
// En habit_provider.dart, al actualizar:
if (habit.notificationTime == null) {
  await NotificationService.instance.cancelHabitNotification(habit.id!);
}
```

### **P: ¿Las notificaciones funcionan cuando la app está cerrada?**

**R:** Sí, las notificaciones locales funcionan incluso cuando la app está cerrada, gracias a `flutter_local_notifications`.

---

## 📊 Estadísticas y Progreso

### **P: ¿Por qué mi progreso muestra 0% aunque completé hábitos?**

**R:** Asegúrate de que:

1. Los hábitos estén marcados como **activos** (`isActive = true`)
2. La fecha seleccionada sea hoy (por defecto lo es)
3. Los hábitos se marcaron en la fecha correcta

Debug:

```dart
print('Hábitos activos: ${habitProvider.activeHabits.length}');
print('Completados hoy: ${habitProvider.todayCompletions.length}');
print('Progreso: ${habitProvider.dailyProgress}%');
```

### **P: ¿Cómo veo estadísticas de meses anteriores?**

**R:** Actualmente solo hay estadísticas semanales. Para agregar mensuales:

```dart
// En database_helper.dart
Future<Map<String, dynamic>> getMonthlyHabitStats(DateTime month) async {
  final startOfMonth = DateTime(month.year, month.month, 1);
  final endOfMonth = DateTime(month.year, month.month + 1, 0);

  // Similar a getWeeklyHabitStats pero con rango mensual
  // ...
}
```

---

## 🐛 Problemas Comunes

### **P: Error "Table habits does not exist"**

**R:** La migración no se ejecutó. Soluciones:

1. **Desinstala completamente la app**:

```bash
# En el dispositivo/emulador, desinstala manualmente
# Luego:
flutter run
```

2. **O fuerza la recreación de la BD**:

```dart
// En database_helper.dart, temporalmente:
Future<Database> _initDB(String filePath) async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, filePath);

  // ELIMINAR ESTO DESPUÉS:
  await deleteDatabase(path);

  return await openDatabase(
    path,
    version: 2,
    onCreate: _createDB,
    onUpgrade: _onUpgrade,
  );
}
```

### **P: "RenderFlex overflowed" en HabitCard**

**R:** Pasa si el texto del nombre/descripción es muy largo. Ya está manejado con:

```dart
Text(
  habit.description!,
  maxLines: 2,
  overflow: TextOverflow.ellipsis, // ← Esto evita el overflow
)
```

### **P: El Provider no se actualiza automáticamente**

**R:** Asegúrate de:

1. Usar `Consumer<HabitProvider>` o `Provider.of<HabitProvider>(context)`
2. Llamar `notifyListeners()` después de cambios
3. No usar `listen: false` si quieres escuchar cambios

```dart
// MAL (no escucha cambios):
final provider = Provider.of<HabitProvider>(context, listen: false);

// BIEN (escucha cambios):
final provider = Provider.of<HabitProvider>(context);
```

### **P: Hot Reload no funciona después de cambios**

**R:** Para cambios en:

- **UI**: Hot Reload (r) funciona
- **Modelos/Providers**: Usa Hot Restart (R)
- **Base de datos**: Reinicia completamente la app

---

## 🚀 Rendimiento

### **P: ¿Cuántos hábitos puedo tener sin afectar el rendimiento?**

**R:** SQLite maneja miles de registros sin problemas. Pero para UI fluida:

- **Recomendado**: 10-50 hábitos activos
- **Máximo práctico**: 100+ hábitos

Si tienes muchos, considera:

```dart
// Paginación en la lista
ListView.builder(
  itemCount: min(habits.length, 50), // Solo muestra 50
  // ...
)
```

### **P: Las consultas a la BD son lentas**

**R:** Agrega índices:

```dart
// En _createDB:
await db.execute('''
  CREATE INDEX idx_habit_completions_date
  ON habit_completions(date)
''');

await db.execute('''
  CREATE INDEX idx_habit_completions_habit_id
  ON habit_completions(habit_id)
''');
```

---

## 🔐 Privacidad y Seguridad

### **P: ¿Los datos se envían a algún servidor?**

**R:** No. Todo es local. Los datos solo existen en el dispositivo del usuario.

### **P: ¿Puedo sincronizar entre dispositivos?**

**R:** No está implementado, pero puedes agregar:

- Firebase Firestore para sync en la nube
- Backend propio con API REST
- Archivo de exportación/importación

### **P: ¿Hay respaldo automático?**

**R:** No, pero Android hace respaldo automático si está configurado. Para respaldo manual:

```dart
// Usa el paquete path_provider para copiar la BD
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<void> backupDatabase() async {
  final dbPath = await getDatabasesPath();
  final db = File('$dbPath/app_ingresos.db');
  final directory = await getExternalStorageDirectory();
  final backup = File('${directory!.path}/app_ingresos_backup.db');
  await db.copy(backup.path);
}
```

---

## 🎓 Aprendizaje

### **P: No entiendo cómo funciona Provider**

**R:** Conceptos básicos:

1. **Provider** = "Proveedor" de datos
2. **Consumer** = "Consumidor" que escucha cambios
3. **notifyListeners()** = Dice "hey, cambié, actualízate"

Flujo:

```
Usuario toca botón → Provider.método() → notifyListeners() → UI se reconstruye
```

Recursos:

- [Provider Package](https://pub.dev/packages/provider)
- [Flutter State Management](https://flutter.dev/docs/development/data-and-backend/state-mgmt)

### **P: ¿Cómo aprendo más sobre SQLite en Flutter?**

**R:**

- [SQFlite Package](https://pub.dev/packages/sqflite)
- [SQL Tutorial](https://www.w3schools.com/sql/)
- Lee `database_helper.dart` con comentarios

### **P: Quiero contribuir, ¿por dónde empiezo?**

**R:**

1. Lee `MODULO_HABITOS.md` completo
2. Revisa `EJEMPLOS_USO.md`
3. Implementa una feature pequeña (ej: cambiar colores)
4. Luego features más complejas (ej: rachas, categorías)

---

## 📞 Soporte

### **P: ¿Dónde reporto bugs o sugiero features?**

**R:** Puedes:

1. Crear un issue en el repositorio del proyecto
2. Contactar al equipo de desarrollo
3. Contribuir con un Pull Request

### **P: ¿Hay una comunidad donde preguntar?**

**R:** Revisa:

- Stack Overflow con tags `flutter` y `provider`
- r/FlutterDev en Reddit
- Flutter Discord

### **P: ¿Este módulo tiene garantía o soporte?**

**R:** Es código abierto provisto "as-is". Sin embargo, está bien documentado y probado.

---

## 🔮 Futuro del Módulo

### **P: ¿Habrá actualizaciones?**

**R:** El módulo es extensible. Revisa `MODULO_HABITOS.md` sección "Próximas Mejoras Sugeridas" para ideas.

### **P: ¿Qué feature viene después?**

**R:** Sugerencias de la comunidad:

1. Sistema de rachas visible
2. Categorías de hábitos
3. Plantillas predefinidas
4. Gamificación con puntos
5. Sincronización en la nube

---

**¿No encuentras tu pregunta?** Revisa la documentación completa en `MODULO_HABITOS.md` o crea un issue.
