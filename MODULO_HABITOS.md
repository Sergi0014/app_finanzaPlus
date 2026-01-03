# Módulo de Gestión de Hábitos

## 📋 Descripción

Este módulo agrega funcionalidad completa de gestión de hábitos a la aplicación de ingresos. Permite a los usuarios crear, seguir y completar hábitos diarios, con visualización de progreso y recordatorios.

## ✨ Características Implementadas

### 1. **Gestión CRUD de Hábitos**

- ✅ Crear nuevos hábitos con nombre, descripción, icono y color personalizados
- ✅ Editar hábitos existentes
- ✅ Eliminar hábitos
- ✅ Activar/desactivar hábitos

### 2. **Seguimiento Diario**

- ✅ Marcar hábitos como completados/pendientes
- ✅ Barra de progreso que muestra el porcentaje de hábitos completados del día
- ✅ Interfaz intuitiva con tarjetas de hábitos
- ✅ Indicadores visuales de estado (completado/pendiente)

### 3. **Visualización de Progreso**

- ✅ Gráfico de barras semanal que muestra el progreso diario
- ✅ Estadísticas semanales con promedio de cumplimiento
- ✅ Código de colores según nivel de progreso:
  - Rojo: < 30%
  - Naranja: 30-60%
  - Azul: 60-90%
  - Verde: ≥ 90%

### 4. **Notificaciones (Opcional)**

- ✅ Recordatorios diarios configurables por hábito
- ✅ Notificaciones de motivación al completar hábitos
- ✅ Configuración de hora específica para cada hábito

## 🏗️ Arquitectura

El módulo sigue el patrón **Provider** para la gestión de estado y está organizado de la siguiente manera:

```
lib/
├── models/
│   ├── habit_model.dart                    # Modelo de datos del hábito
│   └── habit_completion_model.dart         # Modelo de finalización diaria
├── providers/
│   └── habit_provider.dart                 # Gestor de estado (Provider)
├── screens/
│   ├── habits_screen.dart                  # Pantalla principal de hábitos
│   └── add_edit_habit_screen.dart          # Pantalla para crear/editar hábitos
├── widgets/
│   ├── habit_card.dart                     # Widget de tarjeta de hábito
│   ├── habit_progress_bar.dart             # Barra de progreso personalizada
│   └── weekly_habit_chart.dart             # Gráfico semanal
├── database/
│   └── database_helper.dart                # Operaciones de base de datos (actualizado)
└── services/
    └── notification_service.dart           # Servicio de notificaciones (actualizado)
```

## 💾 Base de Datos

### Tabla `habits`

```sql
CREATE TABLE habits (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  icon_name TEXT NOT NULL,
  color_value INTEGER NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1,
  notification_time TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
```

### Tabla `habit_completions`

```sql
CREATE TABLE habit_completions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  habit_id INTEGER NOT NULL,
  date TEXT NOT NULL,
  is_completed INTEGER NOT NULL DEFAULT 0,
  notes TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE,
  UNIQUE(habit_id, date)
)
```

## 🚀 Cómo Usar

### 1. **Agregar un Hábito**

```dart
// En habits_screen.dart, toca el botón flotante "+"
// Completa el formulario con:
// - Nombre del hábito
// - Descripción (opcional)
// - Icono (selecciona de la lista)
// - Color (selecciona de la paleta)
// - Hora de recordatorio (opcional)
```

### 2. **Marcar un Hábito como Completado**

```dart
// Toca la tarjeta del hábito en la lista
// El icono se llenará y el texto se tachará
// La barra de progreso se actualizará automáticamente
```

### 3. **Ver Estadísticas Semanales**

```dart
// Toca el icono de estadísticas en la AppBar
// Se abrirá un bottom sheet con el gráfico semanal
```

## 🔧 Expandir Funcionalidad

### **Agregar Nuevas Características**

#### 1. **Rachas (Streaks)**

Ya existe una función base en `HabitProvider`:

```dart
Future<int> getHabitStreak(int habitId) async {
  // Calcula los días consecutivos que se completó el hábito
}
```

Para mostrar rachas en la UI:

```dart
// En habit_card.dart, agrega:
FutureBuilder<int>(
  future: Provider.of<HabitProvider>(context).getHabitStreak(habit.id!),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return Text('🔥 ${snapshot.data} días');
    }
    return const SizedBox.shrink();
  },
)
```

#### 2. **Categorías de Hábitos**

Actualiza el modelo:

```dart
// En habit_model.dart, agrega:
final String category; // 'health', 'productivity', 'personal', etc.

// Crea una nueva tabla en database_helper.dart:
CREATE TABLE habit_categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  icon TEXT NOT NULL,
  color INTEGER NOT NULL
)
```

#### 3. **Objetivos Semanales/Mensuales**

```dart
// En habit_model.dart, agrega:
final int weeklyGoal; // Número de veces por semana
final int monthlyGoal; // Número de veces por mes

// En habit_provider.dart, agrega:
Future<Map<String, dynamic>> getHabitProgress(int habitId) async {
  final completions = await getHabitCompletions(habitId);
  // Calcula progreso vs objetivos
}
```

#### 4. **Compartir Progreso**

```dart
// Usa el paquete share_plus (ya instalado)
import 'package:share_plus/share_plus.dart';

Future<void> shareWeeklyProgress() async {
  final stats = await habitProvider.getWeeklyProgress();
  final message = 'Esta semana completé ${stats['averageProgress']}% de mis hábitos!';
  await Share.share(message);
}
```

#### 5. **Gráficos Más Avanzados**

Instala el paquete `fl_chart`:

```bash
flutter pub add fl_chart
```

Luego crea gráficos de líneas, circulares, etc:

```dart
import 'package:fl_chart/fl_chart.dart';

// Ejemplo de gráfico de líneas mensual
LineChart(
  LineChartData(
    // Configura datos mensuales
  ),
)
```

#### 6. **Modo Oscuro para Hábitos**

```dart
// En app_theme.dart, agrega:
static final darkTheme = ThemeData.dark().copyWith(
  // Personaliza colores para hábitos
);

// En main.dart:
MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: ThemeMode.system,
)
```

#### 7. **Sincronización en la Nube**

```dart
// Usa Firebase o tu backend preferido
// En habit_provider.dart:
Future<void> syncWithCloud() async {
  final habits = await _dbHelper.getAllHabits();
  // Envía a Firebase/Backend
  await firebaseService.uploadHabits(habits);
}
```

## 🎨 Personalización

### **Cambiar Iconos Disponibles**

En `add_edit_habit_screen.dart`:

```dart
final List<String> _availableIcons = [
  'check_circle',
  'fitness_center',
  // Agrega más iconos de Material Icons
  'coffee',
  'water_drop',
  'emoji_events',
];
```

### **Cambiar Colores de Progreso**

En `habit_progress_bar.dart`:

```dart
List<Color> _getProgressColors(double progress) {
  if (progress < 25) return [Colors.red[400]!, Colors.red[600]!];
  if (progress < 50) return [Colors.orange[400]!, Colors.orange[600]!];
  if (progress < 75) return [Colors.blue[400]!, Colors.blue[600]!];
  return [Colors.green[400]!, Colors.green[600]!];
}
```

## 📱 Integración con la App

El módulo de hábitos está completamente integrado:

1. **Navegación**: Nueva pestaña "Hábitos" en la barra de navegación inferior
2. **Provider**: `HabitProvider` agregado en el `MultiProvider` del `main.dart`
3. **Base de Datos**: Migración automática de la versión 1 a 2
4. **Notificaciones**: Integrado con el `NotificationService` existente

## 🐛 Solución de Problemas

### **Error: Tabla no existe**

```dart
// La base de datos se actualiza automáticamente
// Si persiste, desinstala y reinstala la app para recrear la BD
```

### **Las notificaciones no funcionan**

```dart
// Verifica permisos en:
// - Android: Configuración > Apps > Tu App > Notificaciones
// - iOS: Configuración > Notificaciones > Tu App
```

### **El progreso no se actualiza**

```dart
// Asegúrate de llamar a notifyListeners() en HabitProvider
// O usa Consumer/Provider.of para escuchar cambios
```

## 📚 Recursos Adicionales

- [Provider Documentation](https://pub.dev/packages/provider)
- [SQFlite Documentation](https://pub.dev/packages/sqflite)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [Material Icons Gallery](https://fonts.google.com/icons)

## 🔮 Próximas Mejoras Sugeridas

1. ✨ **Importar/Exportar** hábitos en formato JSON
2. ✨ **Plantillas** de hábitos predefinidos (ejercicio, meditación, etc.)
3. ✨ **Recordatorios inteligentes** basados en comportamiento del usuario
4. ✨ **Gamificación** con puntos y logros
5. ✨ **Análisis de tendencias** con IA/ML
6. ✨ **Integración con wearables** (Google Fit, Apple Health)
7. ✨ **Grupos y desafíos** con otros usuarios
8. ✨ **Widgets de pantalla de inicio** para acceso rápido

## 📄 Licencia

Este módulo es parte de la aplicación App Ingresos y sigue la misma licencia del proyecto principal.

---

**¿Necesitas ayuda?** Revisa el código fuente o contacta al equipo de desarrollo.
