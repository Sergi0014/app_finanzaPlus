# 📱 App Ingresos - Módulo de Hábitos

## 🚀 Inicio Rápido

```bash
flutter pub get
flutter run
```

Navega a la pestaña **"Hábitos"** (3ra pestaña) para comenzar.

---

## 📚 Documentación Completa

### **⭐ Empieza Aquí**

1. 📖 [RESUMEN_EJECUTIVO.md](RESUMEN_EJECUTIVO.md) - Overview completo (10 min)
2. 📘 [MODULO_HABITOS.md](MODULO_HABITOS.md) - Guía detallada (30 min)
3. 💡 [EJEMPLOS_USO.md](EJEMPLOS_USO.md) - Code snippets (20 min)

### **🔍 Referencias**

- 📋 [RESUMEN_IMPLEMENTACION.md](RESUMEN_IMPLEMENTACION.md) - Qué se implementó
- ❓ [FAQ_HABITOS.md](FAQ_HABITOS.md) - Preguntas frecuentes
- 🏗️ [ARQUITECTURA_HABITOS.txt](ARQUITECTURA_HABITOS.txt) - Diagrama visual
- 📑 [INDICE_HABITOS.md](INDICE_HABITOS.md) - Índice de archivos
- ✅ [CHECKLIST_HABITOS.md](CHECKLIST_HABITOS.md) - Verificación

---

## ✨ Características

✅ **CRUD Completo** - Crear, leer, actualizar, eliminar hábitos  
✅ **Seguimiento Diario** - Marcar hábitos como completados  
✅ **Progreso Visual** - Barra de progreso en tiempo real  
✅ **Estadísticas** - Gráfico semanal con código de colores  
✅ **Notificaciones** - Recordatorios diarios configurables  
✅ **Personalización** - 10 iconos × 10 colores = 100 combinaciones

---

## 🏗️ Arquitectura

**Pattern**: Provider (State Management)  
**Database**: SQLite (2 tablas: habits, habit_completions)  
**UI**: Material Design 3  
**Notifications**: Flutter Local Notifications

```
Screens → Provider → Database Helper → SQLite
```

---

## 📂 Estructura de Archivos

```
lib/
├── models/
│   ├── habit_model.dart
│   └── habit_completion_model.dart
├── providers/
│   └── habit_provider.dart
├── screens/
│   ├── habits_screen.dart
│   └── add_edit_habit_screen.dart
├── widgets/
│   ├── habit_card.dart
│   ├── habit_progress_bar.dart
│   └── weekly_habit_chart.dart
├── database/
│   └── database_helper.dart (modificado)
└── services/
    └── notification_service.dart (modificado)
```

---

## 🎯 Uso Básico

### **Crear un Hábito**

1. Toca el botón flotante "+"
2. Ingresa nombre (ej: "Hacer ejercicio")
3. Elige icono y color
4. (Opcional) Configura notificación
5. Guarda

### **Marcar como Completado**

- Toca la tarjeta del hábito
- El icono se llenará y el progreso se actualizará

### **Ver Estadísticas**

- Toca el icono de gráfico en la AppBar
- Ve tu progreso semanal

---

## 🔧 Expandir

El módulo está diseñado para ser extensible. Ideas:

- **Rachas** - Días consecutivos completados
- **Categorías** - Agrupar hábitos
- **Objetivos** - Metas semanales/mensuales
- **Gamificación** - Puntos y logros
- **Sincronización** - Cloud backup

Ver [MODULO_HABITOS.md](MODULO_HABITOS.md) sección "Expandir Funcionalidad".

---

## 🐛 Problemas?

Consulta [FAQ_HABITOS.md](FAQ_HABITOS.md) para:

- Errores comunes
- Configuración
- Personalización
- Rendimiento

---

## 📊 Estadísticas

- **Archivos creados**: 8 (código) + 6 (docs)
- **Archivos modificados**: 4
- **Líneas de código**: ~1,500
- **Tablas de BD**: 2
- **Widgets personalizados**: 3
- **Tiempo de lectura**: 2-3 horas
- **Estado**: ✅ Completo y probado

---

## 🎓 Aprendizaje

Este módulo es un excelente ejemplo de:

- State Management con Provider
- Base de datos SQLite con migraciones
- Arquitectura limpia y escalable
- Widgets reutilizables
- Notificaciones locales

---

## 📄 Licencia

Parte del proyecto App Ingresos.

---

**Desarrollado**: 2 de enero de 2026  
**Versión**: 1.0.0  
**Estado**: ✅ Producción

---

**¿Preguntas?** Lee la [documentación completa](MODULO_HABITOS.md) o consulta el [FAQ](FAQ_HABITOS.md).
