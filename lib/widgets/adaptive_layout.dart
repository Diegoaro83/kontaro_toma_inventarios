import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

/// 🎯 WIDGET ADAPTATIVO GENÉRICO
///
/// Este widget decide automáticamente qué interfaz mostrar según
/// el tipo de dispositivo (móvil, tablet o escritorio).
///
/// EJEMPLO DE USO:
/// ```dart
/// AdaptiveLayout(
///   mobileBody: MiPantallaMóvil(),
///   desktopBody: MiPantallaEscritorio(),
/// )
/// ```

class AdaptiveLayout extends StatelessWidget {
  /// Interfaz para móviles
  final Widget mobileBody;

  /// Interfaz para tablets (opcional, usa móvil si no se proporciona)
  final Widget? tabletBody;

  /// Interfaz para escritorio (opcional, usa tablet o móvil si no se proporciona)
  final Widget? desktopBody;

  const AdaptiveLayout({
    super.key,
    required this.mobileBody,
    this.tabletBody,
    this.desktopBody,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Detectar el tipo de dispositivo
        final deviceType = ResponsiveHelper.getDeviceType(context);

        // Seleccionar qué interfaz mostrar
        switch (deviceType) {
          case DeviceType.mobile:
            return mobileBody;

          case DeviceType.tablet:
            // Si no hay diseño específico para tablet, usar móvil
            return tabletBody ?? mobileBody;

          case DeviceType.desktop:
            // Si no hay diseño específico, usar tablet, y si no, móvil
            return desktopBody ?? tabletBody ?? mobileBody;
        }
      },
    );
  }
}

/// 🔧 WIDGET CONSTRUCTOR ADAPTATIVO
///
/// Similar a AdaptiveLayout pero usa un builder que recibe
/// el tipo de dispositivo. Útil cuando necesitas acceso al contexto
/// o quieres compartir código entre diferentes tamaños.
///
/// EJEMPLO:
/// ```dart
/// AdaptiveBuilder(
///   builder: (context, deviceType) {
///     if (deviceType == DeviceType.mobile) {
///       return Text('Móvil');
///     }
///     return Text('Escritorio');
///   }
/// )
/// ```

class AdaptiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const AdaptiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ResponsiveHelper.getDeviceType(context);
        return builder(context, deviceType);
      },
    );
  }
}

/// 📏 WIDGET PARA VALORES ADAPTATIVOS
///
/// Permite definir valores diferentes según el tamaño de pantalla.
/// Útil para padding, margins, tamaños de fuente, etc.
///
/// EJEMPLO:
/// ```dart
/// AdaptiveValue<double>(
///   mobile: 16.0,
///   tablet: 24.0,
///   desktop: 32.0,
///   builder: (value) => Padding(
///     padding: EdgeInsets.all(value),
///     child: Text('Hola'),
///   ),
/// )
/// ```

class AdaptiveValue<T> extends StatelessWidget {
  final T mobile;
  final T? tablet;
  final T? desktop;
  final Widget Function(T value) builder;

  const AdaptiveValue({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final value = ResponsiveHelper.valueByDevice<T>(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
    return builder(value);
  }
}
