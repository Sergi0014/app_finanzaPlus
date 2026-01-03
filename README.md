# FinanzasPlus 💰

Aplicación móvil Flutter para registro y gestión de finanzas personales y hábitos con almacenamiento local, reportes automáticos, exportación de datos y seguimiento de hábitos diarios.

## 📱 Características Principales

### ✅ Sprint 1: CRUD y Persistencia (Completado)

- ✅ CRUD completo de transacciones (ingresos/egresos)
- ✅ CRUD completo de categorías personalizadas
- ✅ Dashboard con balance total y transacciones recientes
- ✅ Persistencia local con SQLite
- ✅ Provider para gestión de estado
- ✅ 14 categorías predefinidas (5 ingresos, 9 egresos)
- ✅ Tests unitarios de modelos (13 tests)

### ✅ Sprint 2: Reportes y Exportación (Completado)

- ✅ Reporte semanal automático con rango de fechas
- ✅ Tabla Top 5 categorías más usadas
- ✅ Gráfico de pie (distribución de gastos)
- ✅ Gráfico de barras (ingresos vs egresos por día)
- ✅ Gráfico de línea (balance acumulado)
- ✅ Exportación a CSV con formato tabular
- ✅ Exportación a JSON con estructura completa
- ✅ Compartir archivos exportados

### ✅ Sprint 3: UI y Animaciones (Completado)

- ✅ Onboarding de 3 pantallas con PageView
- ✅ Paleta de colores vibrante implementada
- ✅ Navegación por pestañas (Dashboard, Transacciones, Categorías, Reportes)
- ✅ Material Design 3
- ✅ Iconos emoji para categorías
- ✅ Animaciones de transición suaves
- ✅ Tests de widgets (3 tests)

### ✅ Sprint 4: Configuración Avanzada (Completado)

- ✅ Configuración de moneda (USD, EUR, MXN, COP, ARS)
- ✅ Configuración de inicio de semana (Lunes/Domingo)
- ✅ Backup y restauración de base de datos
- ✅ Importación de datos CSV
- ✅ Notificaciones semanales automáticas
- ✅ Pantalla de configuración completa

### ✅ Sprint 5: Testing y Optimización (Completado)

- ✅ Suite de tests completa (31 tests)
- ✅ Validación de migraciones de base de datos

### ✅ Sprint 6: Sistema de Hábitos (Completado)

- ✅ CRUD completo de hábitos personalizados
- ✅ Seguimiento diario de completación de hábitos
- ✅ 18 plantillas prediseñadas por categorías (Salud, Productividad, Mindfulness, etc.)
- ✅ 7 rutinas diarias completas (Día 1-7) con 5-6 hábitos cada una
- ✅ Animaciones de celebración con emojis al completar hábitos
- ✅ Validación de hábitos duplicados con notificaciones
- ✅ Reseteo automático diario de hábitos
- ✅ Detección de cambio de día al reanudar la app
- ✅ Configuración de notificaciones por hábito
- ✅ Categorización de hábitos (7 categorías)
- ✅ Iconos y colores personalizables
- ✅ Estadísticas de progreso diario
- ✅ Compartir progreso de hábitos
- ✅ Optimización de consultas SQLite
- ✅ Documentación técnica completa
- ✅ Listo para producción

## 🚀 Instalación

### Prerequisitos

- Flutter SDK >=3.0.0
- Dart SDK >=3.0.0
- Android Studio / VS Code
- Dispositivo Android/iOS o Emulador

### Pasos de Instalación

1. **Clonar el repositorio**

```bash
git clone <repository-url>
cd appIngresos
```

2. **Instalar dependencias**

```bash
flutter pub get
```

3. **Ejecutar la aplicación**

```bash
flutter run
```

4. **Ejecutar tests**

```bash
flutter test
```

## 📦 Dependencias Principales

- **sqflite**: Base de datos SQLite
- **provider**: Gestión de estado
- **fl_chart**: Gráficos interactivos
- **intl**: Internacionalización y formato
- **csv**: Exportación CSV
- **share_plus**: Compartir archivos

## 💾 Base de Datos

### Categorías Predefinidas

**Ingresos:** 💼 Salario, 💻 Freelance, 📈 Inversiones, 🛍️ Ventas, 💰 Otros

**Egresos:** 🍔 Alimentación, 🚗 Transporte, 🏠 Vivienda, 💡 Servicios, 🎬 Entretenimiento, ⚕️ Salud, 📚 Educación, 🛒 Compras, 💸 Otros

## 🧪 Testing

### Tests Implementados (31 tests) ✅

- **Modelos**: 13 tests (Transaction, Category)
- **Servicios**: 10 tests (Report, Export, Backup)
- **Widgets**: 3 tests (Onboarding)
- **Providers**: 5 tests (TransactionProvider)
- **Cobertura**: ~85%

```bash
# Ejecutar todos los tests
flutter test

# Ver cobertura
flutter test --coverage
```

**Resultado**: ✅ **31/31 tests pasando**

## 🎨 Paleta de Colores

- **Primary**: #6366F1 (Índigo vibrante)
- **Income**: #10B981 (Verde esmeralda)
- **Expense**: #EF4444 (Rojo vibrante)

## 📦 Archivos del Proyecto

1. **Código fuente**: 27 archivos Dart (~6,000 líneas)
2. **Tests**: 13 archivos de test (31 tests)
3. **README.md**: Documentación de usuario
4. **ESTADO_PROYECTO.md**: Documentación técnica detallada

## 🏆 Características Destacadas

- 🎨 **UI Moderna**: Material Design 3 con colores vibrantes
- 📊 **Gráficos Interactivos**: 3 tipos de visualizaciones
- 💾 **Backup Automático**: Respaldo de base de datos
- 🔔 **Notificaciones**: Recordatorios semanales
- 📤 **Exportación**: CSV y JSON con compartir
- ⚙️ **Configurable**: Moneda, inicio de semana, tema
- 🧪 **Testeado**: 31 tests con 85% de cobertura
- 📱 **Onboarding**: Introducción de 3 pantallas

## 🚀 Listo para Producción

La aplicación está completamente funcional y lista para ser desplegada en:

- ✅ Google Play Store (Android)
- ✅ Apple App Store (iOS)

---

**Proyecto de Titulación AITEC**  
**Fecha inicio**: 17 de noviembre de 2025  
**Fecha fin**: 11 de diciembre de 2025  
**Estado**: ✅ **COMPLETADO Y LISTO PARA PRODUCCIÓN**
