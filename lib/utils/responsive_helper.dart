import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter/material.dart';

/// 📱💻 HELPER PARA DISEÑO ADAPTATIVO
///
/// Esta clase ayuda a detectar en qué tipo de dispositivo se está ejecutando
/// la aplicación y a adaptar la interfaz según el tamaño de pantalla.
///
/// LECCIÓN: Es importante que tu app se vea bien en móviles, tablets y escritorio.

class ResponsiveHelper {
  // 🚫 Constructor privado
  ResponsiveHelper._();

  // ==================== BREAKPOINTS (PUNTOS DE QUIEBRE) ====================

  /// Ancho máximo para considerar que es un móvil (en píxeles)
  static const double mobileMaxWidth = 600;

  /// Ancho máximo para considerar que es una tablet
  static const double tabletMaxWidth = 900;

  /// A partir de este ancho, se considera escritorio
  static const double desktopMinWidth = 901;

  // ==================== DETECCIÓN DE PLATAFORMA ====================

  /// ¿Estamos en la web?
  static bool get isWeb => kIsWeb;

  /// ¿Estamos en Windows?
  static bool get isWindows => !kIsWeb && Platform.isWindows;

  /// ¿Estamos en macOS?
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  /// ¿Estamos en Linux?
  static bool get isLinux => !kIsWeb && Platform.isLinux;

  /// ¿Estamos en Android?
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// ¿Estamos en iOS?
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// ¿Estamos en un sistema de escritorio? (Windows, macOS, Linux o Web)
  static bool get isDesktopPlatform => isWindows || isMacOS || isLinux || isWeb;

  /// ¿Estamos en un dispositivo móvil? (Android o iOS)
  static bool get isMobilePlatform => isAndroid || isIOS;

  // ==================== DETECCIÓN POR TAMAÑO DE PANTALLA ====================

  /// ¿Es una pantalla pequeña? (móvil)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileMaxWidth;
  }

  /// ¿Es una pantalla mediana? (tablet)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileMaxWidth && width < desktopMinWidth;
  }

  /// ¿Es una pantalla grande? (escritorio)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopMinWidth;
  }

  // ==================== HELPERS COMBINADOS ====================

  /// Detecta el mejor tipo de interfaz según plataforma Y tamaño
  ///
  /// Por ejemplo: Si estás en Android pero con pantalla grande (tablet),
  /// podría decidir usar diseño de tablet en lugar de móvil
  static DeviceType getDeviceType(BuildContext context) {
    // Si es plataforma móvil (Android/iOS)
    if (isMobilePlatform) {
      // Pero tiene pantalla grande, tratarlo como tablet
      if (isTablet(context)) {
        return DeviceType.tablet;
      }
      return DeviceType.mobile;
    }

    // Si es escritorio
    if (isDesktopPlatform) {
      // Pero la ventana es pequeña, adaptar a móvil
      if (isMobile(context)) {
        return DeviceType.mobile;
      }
      // Si es mediana, tablet
      if (isTablet(context)) {
        return DeviceType.tablet;
      }
      return DeviceType.desktop;
    }

    // Por defecto, móvil
    return DeviceType.mobile;
  }

  /// Devuelve un valor diferente según el tamaño de pantalla
  ///
  /// Ejemplo:
  /// ```dart
  /// final padding = ResponsiveHelper.valueByDevice(
  ///   context,
  ///   mobile: 16.0,
  ///   tablet: 24.0,
  ///   desktop: 32.0,
  /// );
  /// ```
  static T valueByDevice<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  // ==================== INFORMACIÓN DE PANTALLA ====================

  /// Obtiene el ancho de la pantalla en píxeles
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Obtiene el alto de la pantalla en píxeles
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Obtiene la orientación (vertical u horizontal)
  static Orientation orientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// ¿Está en orientación vertical?
  static bool isPortrait(BuildContext context) {
    return orientation(context) == Orientation.portrait;
  }

  /// ¿Está en orientación horizontal?
  static bool isLandscape(BuildContext context) {
    return orientation(context) == Orientation.landscape;
  }
}

/// 📱 TIPOS DE DISPOSITIVO
enum DeviceType {
  /// Móvil (teléfono)
  mobile,

  /// Tablet
  tablet,

  /// Escritorio (PC, laptop)
  desktop,
}
