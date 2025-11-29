# 📱💻 Sistema de Diseño Adaptativo - Kontaro

## Resumen de Implementación

Hemos implementado un sistema completo de diseños adaptativos que detecta automáticamente el tamaño de pantalla y muestra la interfaz óptima para cada dispositivo.

---

## 🏗️ Arquitectura

### Breakpoints Definidos
```dart
mobile:  < 600px
tablet:  600px - 900px
desktop: >= 900px
```

### Componentes Principales

#### 1. **ResponsiveHelper** (`lib/utils/responsive_helper.dart`)
Utilidad central para detectar tipo de dispositivo y calcular valores responsivos.

```dart
// Detectar tipo de dispositivo
ResponsiveHelper.getDeviceType(context) // → DeviceType.mobile/tablet/desktop

// Valores diferentes por dispositivo
ResponsiveHelper.valueByDevice<double>(
  context,
  mobile: 16.0,
  tablet: 20.0,
  desktop: 24.0,
)

// Detectar plataforma
ResponsiveHelper.isMobile    // true en Android/iOS
ResponsiveHelper.isDesktop   // true en Windows/MacOS/Linux
ResponsiveHelper.isWeb       // true en navegador
```

#### 2. **AdaptiveLayout** (`lib/widgets/adaptive_layout.dart`)
Widget genérico que muestra automáticamente el layout correcto según el tamaño de pantalla.

```dart
// Uso básico
AdaptiveLayout(
  mobileBody: MiWidgetMobile(),
  desktopBody: MiWidgetDesktop(),
)

// Con soporte para tablet
AdaptiveLayout(
  mobileBody: MiWidgetMobile(),
  tabletBody: MiWidgetTablet(),   // Opcional
  desktopBody: MiWidgetDesktop(),
)
```

**Widgets Auxiliares:**

- **AdaptiveBuilder**: Constructor con tipo de dispositivo
  ```dart
  AdaptiveBuilder(
    builder: (context, deviceType) {
      if (deviceType == DeviceType.mobile) {
        return MobileLayout();
      }
      return DesktopLayout();
    },
  )
  ```

- **AdaptiveValue**: Para valores escalares responsivos
  ```dart
  AdaptiveValue<double>(
    mobile: 16.0,
    desktop: 24.0,
    builder: (context, value) => Text('Size: $value'),
  )
  ```

---

## 📱 Pantallas Implementadas

### ModuleSelectorScreen

**Estructura Actual:**
```
module_selector_screen.dart     → Wrapper adaptativo (decide cuál mostrar)
module_selector_mobile.dart     → Versión móvil/tablet
module_selector_desktop.dart    → Versión escritorio
```

#### Versión Móvil (`module_selector_mobile.dart`)
- **Layout**: Lista vertical con scroll
- **Iconos**: 48x48px
- **Padding**: 16px entre elementos
- **Info Card**: Compacta, 2 líneas (Perfil activo + Usuario)
- **Módulos**: Lista vertical con separación de 12px
- **Fuentes**: Título 28px, texto 14-16px

#### Versión Desktop (`module_selector_desktop.dart`)
- **Layout**: Barra lateral (280px) + área principal
- **Iconos**: 64x64px (más grandes)
- **Grid**: 3 columnas con aspect ratio 1.5
- **Sidebar**: Logo, hora, perfil, botón logout abajo
- **Espaciado**: 24px entre cards (más aire)
- **Fuentes**: Título 32px, texto 16-18px

---

## 🎨 Diferencias Visuales

| Característica | Móvil | Desktop |
|---|---|---|
| **Layout** | Vertical scroll | Sidebar + Grid |
| **Iconos** | 48x48px | 64x64px |
| **Columnas** | 1 (lista) | 3 (grid) |
| **Padding** | 16px | 24px |
| **Info Card** | Compacta | Extendida en sidebar |
| **Título** | 28px | 32px |
| **Logout** | Icono arriba-derecha | Botón completo abajo |

---

## 🚀 Cómo Usar en Nuevas Pantallas

### Patrón Recomendado

1. **Crear 3 archivos:**
   ```
   mi_pantalla_screen.dart        → Wrapper con AdaptiveLayout
   mi_pantalla_mobile.dart        → Implementación móvil
   mi_pantalla_desktop.dart       → Implementación desktop
   ```

2. **Wrapper (mi_pantalla_screen.dart):**
   ```dart
   import 'package:flutter/material.dart';
   import '../../widgets/adaptive_layout.dart';
   import 'mi_pantalla_mobile.dart';
   import 'mi_pantalla_desktop.dart';

   class MiPantallaScreen extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return AdaptiveLayout(
         mobileBody: MiPantallaMobile(),
         desktopBody: MiPantallaDesktop(),
       );
     }
   }
   ```

3. **Versiones específicas:** Diseñar cada una óptima para su dispositivo

---

## 📋 Checklist de Diseño Responsivo

Cuando crees pantallas adaptativas, considera:

### Móvil
- [ ] Layout vertical con scroll
- [ ] Iconos 48px o menos
- [ ] Padding 16px
- [ ] Fuentes legibles (mínimo 14px)
- [ ] Elementos táctiles >= 44px altura
- [ ] Sin hover effects (touch only)

### Desktop
- [ ] Aprovechar espacio horizontal (sidebars, grids)
- [ ] Iconos 64px o más
- [ ] Padding 24-32px
- [ ] Fuentes escaladas (18-32px títulos)
- [ ] Hover effects en botones/cards
- [ ] Atajos de teclado considerados

---

## 🔧 Testing

### Probar Diferentes Tamaños
```powershell
# Escritorio (Windows)
flutter run -d windows

# Móvil (Android emulador)
flutter run -d android

# Web con diferentes tamaños
flutter run -d chrome
# Luego redimensiona la ventana manualmente
```

### Verificar Breakpoints
1. Ejecutar en Windows
2. Redimensionar ventana gradualmente
3. Verificar que cambie de desktop → tablet → mobile

---

## 📚 Dependencias

```yaml
dependencies:
  responsive_builder: ^0.7.0    # Detección de tamaño de pantalla
  flutter_screenutil: ^5.9.3    # Escalado proporcional (no usado aún)
```

---

## 🎯 Próximos Pasos

1. **LoginScreen Adaptativo**
   - Móvil: Layout vertical actual
   - Desktop: Split screen (logo izquierda, form derecha)

2. **Inventory Taking**
   - Móvil: Scanner fullscreen
   - Desktop: Scanner + lista lateral simultánea

3. **Reports**
   - Móvil: Cards verticales
   - Desktop: Dashboard con gráficos lado a lado

---

## 🐛 Troubleshooting

**Problema**: El layout no cambia al redimensionar
- **Solución**: Asegúrate de usar `LayoutBuilder` o `AdaptiveLayout`, no `MediaQuery.of(context).size` en build directo

**Problema**: Breakpoints no coinciden
- **Solución**: Revisa `ResponsiveHelper.mobileMaxWidth` y `tabletMaxWidth`

**Problema**: Fonts muy pequeñas en móvil
- **Solución**: Usa `AdaptiveValue` o `valueByDevice` para escalar fuentes

---

**Estado**: ✅ Sistema base completo | 🚧 En testing  
**Última actualización**: 22 de noviembre de 2025
