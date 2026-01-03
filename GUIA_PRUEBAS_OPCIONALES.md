# 🧪 Guía de Pruebas - Funcionalidades Opcionales

Esta guía te ayudará a probar todas las nuevas funcionalidades implementadas en el módulo de hábitos.

---

## 🚀 Preparación

### 1. Ejecutar la aplicación

```bash
cd "d:\AITEC\PROYECTO_TITULACION\Nueva carpeta\appIngresos"
flutter run
```

### 2. Navegar al módulo de hábitos

- Desde la pantalla principal, toca "Hábitos" en el menú de navegación

---

## ✅ Pruebas por Funcionalidad

### 1️⃣ Rachas Visibles (Streaks)

**Objetivo**: Verificar que se muestra el contador de días consecutivos

#### Pasos:

1. Crea un nuevo hábito (cualquiera)
2. Márcalo como completado hoy
3. Verifica que **NO** aparece el ícono de fuego (racha = 0 días)
4. Para simular racha:
   - Ve a SQLite y agrega completaciones para días anteriores, O
   - Espera al día siguiente y vuelve a completarlo
5. Deberías ver: 🔥 **X días seguidos** en la esquina superior derecha del card

#### Resultado esperado:

- ✅ Ícono de fuego visible cuando racha > 0
- ✅ Número correcto de días consecutivos
- ✅ Color naranja del ícono

---

### 2️⃣ Categorías de Hábitos

**Objetivo**: Clasificar y filtrar hábitos por categoría

#### Parte A: Asignar Categoría

1. Toca el botón **+** para crear un nuevo hábito
2. Completa el nombre (ej: "Hacer ejercicio")
3. Busca la sección **"Categoría"** (después de Descripción)
4. Abre el dropdown
5. Selecciona una categoría (ej: "Ejercicio" 💪)
6. Verifica que se muestra con ícono y nombre
7. Guarda el hábito

#### Parte B: Filtrar por Categoría

1. Crea al menos 3 hábitos con diferentes categorías
2. En la pantalla principal, toca el ícono de **filtro** (en AppBar)
3. Selecciona una categoría específica
4. Verifica que solo se muestran hábitos de esa categoría
5. Selecciona "Todas las categorías" para ver todos
6. Verifica que el ícono cambia:
   - Sin filtro: `filter_alt_outlined`
   - Con filtro: `filter_alt` (relleno)

#### Resultado esperado:

- ✅ Dropdown muestra las 8 categorías con íconos y colores
- ✅ Filtro funciona correctamente
- ✅ Ícono visual indica estado del filtro
- ✅ Menú solo aparece si hay categorías activas

---

### 3️⃣ Plantillas Predefinidas

**Objetivo**: Crear hábitos rápidamente desde plantillas

#### Pasos:

1. En la pantalla principal de hábitos, toca el ícono de **caja** 📦 (AppBar)
2. Se abre la pantalla de plantillas
3. Verifica que hay **18 plantillas** organizadas
4. Usa los chips de filtro:
   - Toca "Salud" → Solo plantillas de salud
   - Toca "Ejercicio" → Solo plantillas de ejercicio
   - Toca "Todas" → Todas las plantillas
5. Selecciona una plantilla (ej: "Tomar agua")
6. Se abre el formulario de edición con datos **pre-cargados**:
   - ✅ Nombre: "Tomar agua"
   - ✅ Descripción: "Beber 8 vasos de agua al día"
   - ✅ Ícono: `local_drink`
   - ✅ Color: Azul
   - ✅ Categoría: "Salud"
   - ✅ Recordatorio: 08:00
7. Puedes editar cualquier campo antes de guardar
8. Guarda el hábito

#### Resultado esperado:

- ✅ 18 plantillas disponibles
- ✅ Filtros por categoría funcionan
- ✅ Datos pre-cargados correctamente
- ✅ Formulario editable antes de guardar
- ✅ Navegación fluida

---

### 4️⃣ Gráficos Mensuales

**Objetivo**: Visualizar progreso del mes actual

#### Pasos:

1. Asegúrate de tener algunos hábitos creados
2. Completa algunos hábitos hoy
3. Toca el ícono de **insights** 📊 (gráfico) en AppBar
4. Se abre un modal con tabs
5. Verifica que hay **2 tabs**:
   - "Semanal" (existente)
   - "Mensual" (nuevo)
6. Cambia a tab **"Mensual"**
7. Verifica los componentes:
   - **Card de resumen** con 3 métricas:
     - 📅 Días: Número de días del mes
     - 📈 Promedio: Porcentaje promedio
     - ⭐ Días perfectos: Días con 100%
   - **Gráfico de barras**:
     - Una barra por día del mes
     - Colores según porcentaje:
       - 🟢 Verde: 80-100%
       - 🔵 Azul: 60-79%
       - 🟠 Naranja: 40-59%
       - 🔴 Rojo: <40%
     - Eje X: Días del mes (1, 2, 3...)
     - Eje Y: Porcentaje (0%, 25%, 50%, 75%, 100%)
   - **Leyenda** explicando los colores
8. Toca una barra del gráfico
9. Verifica que aparece **tooltip** con fecha y porcentaje

#### Resultado esperado:

- ✅ Tab "Mensual" visible
- ✅ Resumen estadístico correcto
- ✅ Gráfico de barras con colores
- ✅ Tooltips interactivos
- ✅ Leyenda visible
- ✅ Sin días futuros en el gráfico

#### Nota:

⚠️ Los datos mensuales son actualmente **simulados** (placeholder). En una versión futura, se implementará la carga de datos históricos reales desde la base de datos.

---

### 5️⃣ Compartir Progreso

**Objetivo**: Compartir estadísticas en redes sociales

#### Pasos:

1. Crea al menos 2-3 hábitos
2. Completa algunos (no todos)
3. En la sección **"Progreso de hoy"**, busca el ícono de **compartir** (share)
4. Está ubicado a la derecha del texto "X de Y hábitos completados"
5. Toca el ícono de compartir
6. Se abre el diálogo nativo de compartir
7. Verifica el contenido del mensaje:

   ```
   📊 Mi Progreso de Hábitos - [Fecha]

   ✅ Completados: X/Y hábitos
   📈 Progreso: XX%

   Mis hábitos de hoy:
   ✅ Hábito completado 1
   ✅ Hábito completado 2
   ⬜ Hábito pendiente 1

   ¡Construyendo mejores hábitos cada día! 💪
   ```

8. Selecciona una app (WhatsApp, Notas, etc.)
9. Verifica que el mensaje se copia correctamente

#### Resultado esperado:

- ✅ Botón de compartir visible
- ✅ Formato de texto estructurado
- ✅ Fecha en español correcta
- ✅ Checkmarks (✅/⬜) para cada hábito
- ✅ Porcentaje correcto
- ✅ Integración con share_plus funciona

---

## 🔄 Prueba de Integración Completa

### Flujo Completo: De Plantilla a Compartir

1. **Inicio**: Pantalla principal → Hábitos
2. **Crear desde plantilla**:
   - Tap ícono de caja
   - Filtrar "Ejercicio"
   - Seleccionar "Hacer ejercicio"
   - Verificar categoría pre-seleccionada
   - Guardar
3. **Crear manualmente**:
   - Tap botón +
   - Nombre: "Meditar"
   - Categoría: "Mindfulness"
   - Color: Morado
   - Guardar
4. **Completar hábitos**:
   - Marcar "Hacer ejercicio" ✅
   - Dejar "Meditar" sin completar ⬜
5. **Filtrar**:
   - Tap ícono filtro
   - Seleccionar "Ejercicio"
   - Verificar solo se muestra 1 hábito
   - Volver a "Todas"
6. **Ver estadísticas**:
   - Tap ícono insights
   - Ver tab "Semanal"
   - Cambiar a "Mensual"
   - Verificar datos
7. **Compartir**:
   - Tap ícono compartir
   - Verificar mensaje
   - Compartir en una app

#### Resultado esperado:

- ✅ Todas las funcionalidades trabajan juntas sin conflictos
- ✅ Navegación fluida entre pantallas
- ✅ Datos consistentes en toda la app

---

## 🐛 Casos Edge a Probar

### Sin Hábitos

1. Elimina todos los hábitos
2. Verifica que aparece el **empty state** (ícono grande + mensaje)
3. Verifica que:
   - ✅ Botón + visible
   - ✅ Botón de plantillas visible
   - ✅ Botón de filtro **no visible** (no hay categorías)
   - ✅ Progreso = 0%

### Todos Completados

1. Marca todos los hábitos como completados
2. Verifica que:
   - ✅ Progreso = 100%
   - ✅ Todos los checkboxes verdes
   - ✅ Mensaje de compartir muestra todos con ✅

### Sin Categoría

1. Crea un hábito sin seleccionar categoría
2. Guarda
3. Verifica que:
   - ✅ Hábito se guarda correctamente
   - ✅ No aparece en ningún filtro de categoría
   - ✅ Solo aparece en "Todas las categorías"

### Racha Larga

1. Simula una racha de 30+ días (insertar datos en BD)
2. Verifica que:
   - ✅ Número se muestra correctamente
   - ✅ No hay problemas de layout
   - ✅ Color del ícono correcto

---

## ⚠️ Problemas Conocidos

### Datos Simulados en Gráfico Mensual

- **Descripción**: Los datos mensuales son placeholders (patrón repetitivo)
- **Impacto**: No refleja datos reales históricos
- **Solución futura**: Implementar carga de completaciones históricas por día

### Deprecation Warnings

- **Descripción**: Algunos warnings de `withOpacity` y `.value`
- **Impacto**: Ninguno (solo warnings, no errores)
- **Solución futura**: Migrar a nuevas APIs cuando Flutter las estabilice

---

## 📊 Checklist de Pruebas

### Rachas

- [ ] Racha de 0 días (no muestra ícono)
- [ ] Racha de 1+ días (muestra ícono y número)
- [ ] Racha se actualiza al completar

### Categorías

- [ ] Selector muestra 8 categorías
- [ ] Categorías con íconos y colores correctos
- [ ] Filtro funciona correctamente
- [ ] Ícono de filtro cambia con estado

### Plantillas

- [ ] 18 plantillas disponibles
- [ ] Filtros por categoría funcionan
- [ ] Datos se pre-cargan en formulario
- [ ] Campos son editables

### Gráficos Mensuales

- [ ] Tab "Mensual" visible
- [ ] Card de resumen con 3 métricas
- [ ] Gráfico de barras con colores
- [ ] Tooltips interactivos
- [ ] Leyenda visible

### Compartir

- [ ] Botón visible en progreso
- [ ] Formato de texto correcto
- [ ] Checkmarks para cada hábito
- [ ] Fecha en español
- [ ] Share dialog se abre

### Integración

- [ ] Todas las funcionalidades trabajan juntas
- [ ] Sin crashes
- [ ] Datos consistentes
- [ ] Navegación fluida

---

## 🎯 Resumen

**Total de funcionalidades a probar**: 5  
**Tiempo estimado de pruebas**: 30-45 minutos  
**Nivel de prioridad**: Alta (funcionalidades principales)

---

## 📝 Reporte de Bugs

Si encuentras algún problema, documenta:

1. **Funcionalidad afectada**
2. **Pasos para reproducir**
3. **Resultado esperado**
4. **Resultado obtenido**
5. **Screenshots** (si aplica)

---

**Última actualización**: Diciembre 2024  
**Versión de pruebas**: 1.0.0
