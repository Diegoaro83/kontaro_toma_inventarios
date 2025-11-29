import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'config/app_config.dart';
import 'screens/login/login_screen.dart';
import 'screens/users/lista_usuarios_screen_temp.dart';
import 'screens/roles/lista_roles_screen.dart';
import 'database/roles_iniciales.dart';
import 'database/locales_iniciales.dart';
import 'database/referencias_maestras_iniciales.dart';

/// 🚀 PUNTO DE ENTRADA DE LA APLICACIÓN
///
/// Este es el archivo más importante de Flutter.
/// Es el primer código que se ejecuta cuando abres la app.
///
/// LECCIÓN: La función main() es como el "interruptor" que enciende toda la app

void main() async {
  // Asegurar que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // 🎭 Inicializar roles del sistema
  try {
    await RolesIniciales.inicializarRoles();
  } catch (e) {
    print('⚠️ Error al inicializar roles: $e');
  }

  // 🏪 Inicializar locales (tiendas y bodegas)
  try {
    await LocalesIniciales.inicializarLocales();
  } catch (e) {
    print('⚠️ Error al inicializar locales: $e');
  }

  // 📚 Inicializar referencias maestras (catálogo de productos)
  try {
    await ReferenciasMaestrasIniciales.inicializarReferencias();
  } catch (e) {
    print('⚠️ Error al inicializar referencias maestras: $e');
  }

  // Iniciar la aplicación
  runApp(const KontaroApp());
}

/// 📱 APLICACIÓN PRINCIPAL DE KONTARO
class KontaroApp extends StatelessWidget {
  const KontaroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ===== CONFIGURACIÓN GENERAL =====

      /// Título de la app (aparece en el administrador de tareas)
      title: AppConfig.appName,

      /// Quitar el banner de "DEBUG" en la esquina
      debugShowCheckedModeBanner: false,

      /// 🎨 Activar Material Design 3 (diseño moderno de Google)
      theme: AppTheme.lightTheme,

      /// Pantalla inicial: Login
      home: const LoginScreen(),

      /// Rutas de navegación
      routes: {
        '/lista-usuarios': (context) => const ListaUsuariosScreen(),
        '/lista-roles': (context) => const ListaRolesScreen(),
      },
    );
  }
}
