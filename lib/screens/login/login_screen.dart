// 🖼️ Importa los widgets y componentes visuales de Flutter
import 'package:flutter/material.dart';
// 🎨 Colores y estilos personalizados de la app
import '../../theme/app_colors.dart';
// 🛡️ Modelo de roles/perfiles de usuario
import '../../models/rol.dart';
// 🚀 Pantalla de selección de módulos general (post-login)
import '../modules/module_selector_screen.dart';

/// 🔐 PANTALLA DE LOGIN . es la primer pantalla de la appS
///
/// Esta es la primera pantalla que verá el usuario.
/// Aquí iniciará sesión con usuario, contraseña y seleccionará su perfil.
///
/// LECCIÓN: StatefulWidget = Widget con ESTADO
/// Esto significa que la pantalla puede cambiar (por ejemplo, mostrar/ocultar contraseña)

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// Estado privado de la pantalla de login
/// El guion bajo _ significa que es privado (solo se usa aquí)
class _LoginScreenState extends State<LoginScreen> {
  // ==================== CONTROLADORES ====================
  // Los controladores "controlan" lo que escribes en los campos de texto

  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();

  // ==================== VARIABLES DE ESTADO ====================
  // Estas variables guardan el "estado" de la pantalla

  /// ¿La contraseña está oculta?
  bool _ocultarContrasena = true;

  /// Rol/perfil seleccionado
  String? _rolSeleccionado;

  /// Lista de roles disponibles
  final List<Rol> _roles = Rol.rolesDefault();

  // ==================== MÉTODOS ====================

  /// Obtener el nombre del rol basándose en el ID
  String _obtenerNombreRol(String rolId) {
    final rol = _roles.firstWhere((r) => r.id == rolId);
    return rol.nombre;
  }

  /// Este método se llama cuando el usuario presiona "INICIAR SESIÓN"
  void _iniciarSesion() {
    // Obtener los valores escritos
    String usuario = _usuarioController.text.trim();
    String contrasena = _contrasenaController.text.trim();

    // Validar que todos los campos estén llenos
    if (usuario.isEmpty) {
      _mostrarMensaje('Por favor ingresa tu usuario');
      return;
    }

    if (contrasena.isEmpty) {
      _mostrarMensaje('Por favor ingresa tu contraseña');
      return;
    }

    if (_rolSeleccionado == null) {
      _mostrarMensaje('Por favor selecciona tu perfil');
      return;
    }

    // TODO: Aquí validaremos con el servidor más adelante
    // Por ahora solo mostramos un mensaje de éxito
    _mostrarMensaje('¡Bienvenido! Login exitoso');

    // Navegación al selector de módulos
    print('Login exitoso: $usuario - Rol: $_rolSeleccionado');

    // Todos los roles navegan al selector de módulos general
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ModuleSelectorScreen(
          nombreUsuario: usuario,
          rolId: _rolSeleccionado!,
          rolNombre: _obtenerNombreRol(_rolSeleccionado!),
        ),
      ),
    );
  }

  /// Mostrar un mensaje en pantalla (SnackBar)
  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Limpiar memoria cuando se cierre la pantalla
  @override
  void dispose() {
    _usuarioController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  // ==================== INTERFAZ DE USUARIO ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 📱 Detectar tamaño de pantalla
            final screenWidth = constraints.maxWidth;
            final isMobile = screenWidth < 600;
            final isTablet = screenWidth >= 600 && screenWidth < 900;

            // 🎨 Calcular dimensiones responsivas más compactas
            final maxWidth = isMobile
                ? screenWidth *
                      0.88 // Móvil: 88% del ancho
                : isTablet
                ? 360.0 // Tablet: más compacto
                : 380.0; // Desktop: más compacto

            final logoSize = isMobile
                ? screenWidth *
                      0.65 // Móvil: 65% del ancho (más grande)
                : isTablet
                ? 240.0 // Tablet: más grande
                : 280.0; // Desktop: más grande

            final horizontalPadding = isMobile ? 20.0 : 32.0;
            final verticalPadding = isMobile ? 16.0 : 24.0;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: isMobile ? 8 : 16),

                      // ========== LOGO ==========
                      _buildLogo(logoSize),

                      SizedBox(height: isMobile ? 4 : 8),

                      // ========== CAMPOS DE ENTRADA ==========
                      _buildCampoUsuario(),

                      const SizedBox(height: 12),

                      _buildCampoContrasena(),

                      const SizedBox(height: 12),

                      _buildCampoPerfil(),

                      const SizedBox(height: 20),

                      // ========== BOTÓN DE LOGIN ==========
                      _buildBotonLogin(),

                      const SizedBox(height: 16),

                      // ========== ENLACE DE AYUDA ==========
                      _buildEnlaceAyuda(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 🏢 LOGO DE OXÍGENO ZERO GRADOS
  Widget _buildLogo(double size) {
    return Center(
      child: Image.asset(
        'assets/images/oxygen_zero_grados_transparente.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }

  /// Campo de Usuario
  Widget _buildCampoUsuario() {
    return TextField(
      controller: _usuarioController,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: 'Usuario',
        hintStyle: const TextStyle(color: Color(0xFF6A7381), fontSize: 15),
        prefixIcon: const Icon(
          Icons.person_outline,
          color: Color(0xFF4A5568),
          size: 20,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 48,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DD), width: 1.1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DD), width: 1.1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A5568), width: 1.5),
        ),
      ),
    );
  }

  /// Campo de Contraseña
  Widget _buildCampoContrasena() {
    return TextField(
      controller: _contrasenaController,
      obscureText: _ocultarContrasena,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: 'Contraseña',
        hintStyle: const TextStyle(color: Color(0xFF6A7381), fontSize: 15),
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: Color(0xFF4A5568),
          size: 20,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _ocultarContrasena
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: const Color(0xFF6A7381),
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _ocultarContrasena = !_ocultarContrasena;
            });
          },
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 48,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DD), width: 1.1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DD), width: 1.1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A5568), width: 1.5),
        ),
      ),
    );
  }

  /// Campo de Perfil
  Widget _buildCampoPerfil() {
    return DropdownButtonFormField<String>(
      value: _rolSeleccionado,
      hint: const Text(
        'Perfil',
        style: TextStyle(color: Color(0xFF6A7381), fontSize: 15),
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down,
        color: Color(0xFF6A7381),
        size: 20,
      ),
      style: const TextStyle(fontSize: 15, color: Color(0xFF4A5568)),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.badge_outlined,
          color: Color(0xFF4A5568),
          size: 20,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 48,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DD), width: 1.1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DD), width: 1.1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A5568), width: 1.5),
        ),
      ),
      items: _roles.map((Rol rol) {
        return DropdownMenuItem<String>(value: rol.id, child: Text(rol.nombre));
      }).toList(),
      onChanged: (String? nuevoValor) {
        setState(() {
          _rolSeleccionado = nuevoValor;
        });
      },
    );
  }

  /// 🔘 BOTÓN DE INICIAR SESIÓN
  Widget _buildBotonLogin() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF010101), Color(0xFF320C0C), Color(0xFF8E1C1C)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.0, 0.529, 1.0],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E1C1C).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _iniciarSesion,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'INICIAR SESIÓN',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  /// 💬 ENLACE DE AYUDA
  Widget _buildEnlaceAyuda() {
    return TextButton(
      onPressed: () {
        _mostrarMensaje('Contacta al administrador del sistema');
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
      child: const Text(
        '¿Problemas para acceder? Contacta al\nadministrador del sistema.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: Color(0xFF6A7381), height: 1.4),
      ),
    );
  }
}
