import 'package:flutter/material.dart';
import '../../services/drift_service.dart';
import '../../widgets/common/barra_superior_modulo.dart';
import '../../widgets/common/barra_inferior_modulo.dart';
import '../modules/modulo_base.dart';
// 🔒 Paquete para hash seguro de contraseñas
// 🔒 Paquete para hash seguro de contraseñas
import 'package:password_hash_plus/password_hash_plus.dart';
import 'dart:convert';

/// 👤 PANTALLA DE CREACIÓN DE USUARIOS - DISEÑO FIGMA
///
/// Formulario con diseño basado en mockup de Figma:
/// - 3 secciones agrupadas en cards con íconos morados
/// - Layout de 2 columnas
/// - Toggle switch cyan para usuario activo
/// - Fondo gris claro

class CreacionUsuarioScreen extends StatefulWidget {
  const CreacionUsuarioScreen({super.key});

  @override
  State<CreacionUsuarioScreen> createState() => _CreacionUsuarioScreenState();
}

class _CreacionUsuarioScreenState extends State<CreacionUsuarioScreen> {
  /// 🔒 Genera un salt aleatorio seguro en base64
  ///
  /// Usado para hashear contraseñas con PBKDF2
  String _generarSalt({int length = 16}) {
    final random = List<int>.generate(
      length,
      (i) => (DateTime.now().microsecondsSinceEpoch * (i + 1)) % 256,
    );
    return base64Url.encode(random);
  }

  /// 🎨 CARD DE SECCIÓN CON HEADER ESTILO MÓDULOS
  ///
  /// Ícono grande, fondo saturado y cuadrado, título alineado verticalmente.
  Widget _buildSeccionCard({
    required IconData icono,
    required Color colorIcono,
    required String titulo,
    required bool isMobile,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 18),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorIcono.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Icon(icono, color: colorIcono, size: 32)),
              ),
              const SizedBox(width: 18),
              Text(
                titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                  color: Color(0xFF1A202C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  // 🎨 Widget de campo de texto simple
  Widget _buildCampo({
    required String label,
    required IconData icono,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    IconData? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icono),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // 🎨 Widget campo contraseña
  Widget _buildCampoContrasena({
    required String label,
    required TextEditingController controller,
    required bool mostrar,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !mostrar,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(mostrar ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // 🎨 Widget dropdown simple
  Widget _buildDropdown({
    required String label,
    required IconData icono,
    required String? value,
    required dynamic items,
    required ValueChanged<String?> onChanged,
    required bool isRol,
  }) {
    // Si es dropdown de rol, mostrar nombre y guardar id
    if (isRol) {
      return DropdownButtonFormField<String>(
        value: value,
        items: items
            .map<DropdownMenuItem<String>>(
              (item) => DropdownMenuItem<String>(
                value: item['id'],
                child: Text(item['nombre']),
              ),
            )
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icono),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } else {
      // Dropdown de locales, mostrar nombre y guardar id
      return DropdownButtonFormField<String>(
        value: value,
        items: items
            .map<DropdownMenuItem<String>>(
              (item) => DropdownMenuItem<String>(
                value: item['id'],
                child: Text(item['nombre']),
              ),
            )
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icono),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  // 🎨 Widget info de código (placeholder)
  Widget _buildCodigoInfo() {
    return Row(
      children: [
        const Icon(Icons.qr_code, color: Color(0xFFEA4747)),
        const SizedBox(width: 8),
        Text(
          _codigoGenerado > 0
              ? 'Código generado: $_codigoGenerado'
              : 'Código generado: ----',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // 🚀 Variables y controladores para el formulario de usuario
  final _formKey = GlobalKey<FormState>();
  bool _cargandoDatos = false;
  bool _activoCheckbox = true;
  // Controladores de texto
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _nombresApellidosController =
      TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _nombreUsuarioController =
      TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _confirmarContrasenaController =
      TextEditingController();
  // Otros campos simulados
  String? _rolIdSeleccionado;
  String? _localAsignadoSeleccionado;
  List<Map<String, String>> _rolesDisponibles = [];
  List<Map<String, String>> _localesDisponibles = [];
  int _codigoGenerado = 0;
  @override
  void initState() {
    super.initState();
    _cargarDatosDropdown();
  }

  /// 🔄 Cargar roles y locales activos desde la base de datos Drift
  Future<void> _cargarDatosDropdown() async {
    setState(() => _cargandoDatos = true);
    final roles = await DriftService().obtenerRolesActivos();
    final locales = await DriftService().obtenerLocalesActivos();
    setState(() {
      // Guardar como lista de mapas: {id, nombre}
      _rolesDisponibles = roles
          .map((r) => {'id': r.id, 'nombre': r.nombre})
          .toList();
      _localesDisponibles = locales
          .map((l) => {'id': l.id, 'nombre': l.nombre})
          .toList();
      _cargandoDatos = false;
    });
  }

  bool _mostrarContrasena = false;
  bool _mostrarConfirmarContrasena = false;

  // 🚀 Métodos de acción del formulario
  /// ✏️ Limpiar todos los campos del formulario y reiniciar el código generado
  void _limpiarFormulario() {
    _formKey.currentState?.reset();
    _cedulaController.clear();
    _nombresApellidosController.clear();
    _telefonoController.clear();
    _nombreUsuarioController.clear();
    _contrasenaController.clear();
    _confirmarContrasenaController.clear();
    setState(() {
      _rolIdSeleccionado = null;
      _localAsignadoSeleccionado = null;
      _activoCheckbox = true;
      _codigoGenerado = 0;
    });
  }

  /// ✅ Guardar usuario en la base de datos Drift
  /// Genera un código aleatorio de 4 dígitos antes de guardar
  Future<void> _guardarUsuario() async {
    // Validar local solo si el rol es 3 o 4
    bool localRequerido =
        _rolIdSeleccionado == '3' || _rolIdSeleccionado == '4';
    bool localValido =
        !localRequerido ||
        (_localAsignadoSeleccionado != null &&
            _localAsignadoSeleccionado!.isNotEmpty);
    if ((_formKey.currentState?.validate() ?? false) && localValido) {
      // Generar código aleatorio de 4 dígitos (1000-9999)
      int codigoGenerado =
          1000 + (DateTime.now().millisecondsSinceEpoch % 9000);
      setState(() {
        _codigoGenerado = codigoGenerado;
      });
      // 🔒 Hashear la contraseña antes de guardar
      final hasher = PBKDF2();
      final salt = _generarSalt();
      final hash = hasher.generateBase64Key(
        _contrasenaController.text,
        salt,
        1000,
        32,
      );
      final contrasenaHash = 'pbkdf2:$salt:$hash';
      await DriftService().crearUsuario(
        cedula: _cedulaController.text.trim(),
        nombresApellidos: _nombresApellidosController.text.trim(),
        nombreUsuario: _nombreUsuarioController.text.trim(),
        telefono: _telefonoController.text.trim(),
        contrasena: contrasenaHash, // Guardar hash seguro
        rolId: _rolIdSeleccionado!,
        localAsignado: localRequerido ? _localAsignadoSeleccionado! : '',
        codigo: codigoGenerado.toString(),
        activo: _activoCheckbox,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuario creado exitosamente. Código: $codigoGenerado'),
        ),
      );
      _limpiarFormulario();
    } else if (!localValido) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar una tienda para este rol.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    // 🎨 Barra superior personalizada
    final barraSuperior = BarraSuperiorModulo(
      nombreEmpresa: "Oxígeno Zero Grados",
      subtitulo: "Crear Usuario",
      nombreUsuario: "Dirección General",
      nombrePerfil: "Administrador",
      estadoSistema: "Activo",
    );

    // 🎨 Barra inferior personalizada
    final barraInferior = BarraInferiorModulo(
      estadoSistema: "Activo",
      ultimaSincronizacion: "Sincronizado",
      onVolver: () => Navigator.of(context).pop(),
      onSalir: () {
        // Aquí puedes poner la lógica de logout
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      },
    );

    // 🎨 Contenido principal del formulario
    final contenidoFormulario = _cargandoDatos
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16.0 : 40.0),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Información Personal
                      _buildSeccionCard(
                        icono: Icons.person_outline,
                        colorIcono: const Color(0xFFEA4747),
                        titulo: 'Información Personal',
                        isMobile: isMobile,
                        children: [
                          _buildCampo(
                            label: 'Cédula',
                            icono: Icons.badge_outlined,
                            controller: _cedulaController,
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Requerido'
                                : v.trim().length < 6
                                ? 'Mínimo 6 dígitos'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _buildCampo(
                            label: 'Nombre Completo',
                            icono: Icons.person,
                            controller: _nombresApellidosController,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Requerido'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _buildCampo(
                            label: 'Teléfono (opcional)',
                            icono: Icons.phone_outlined,
                            controller: _telefonoController,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          _buildCodigoInfo(),
                        ],
                      ),
                      // Credenciales de Acceso
                      _buildSeccionCard(
                        icono: Icons.key_outlined,
                        colorIcono: const Color(0xFFEA4747),
                        titulo: 'Credenciales de Acceso',
                        isMobile: isMobile,
                        children: [
                          _buildCampo(
                            label: 'Nombre de Usuario',
                            icono: Icons.account_circle_outlined,
                            controller: _nombreUsuarioController,
                            suffixIcon: Icons.edit_outlined,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Requerido'
                                : v.trim().length < 4
                                ? 'Mínimo 4 caracteres'
                                : !RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(v)
                                ? 'Solo letras, números, . y _'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _buildCampoContrasena(
                            label: 'Contraseña',
                            controller: _contrasenaController,
                            mostrar: _mostrarContrasena,
                            onToggle: () => setState(
                              () => _mostrarContrasena = !_mostrarContrasena,
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Requerido'
                                : v.length < 6
                                ? 'Mínimo 6 caracteres'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _buildCampoContrasena(
                            label: 'Confirmar Contraseña',
                            controller: _confirmarContrasenaController,
                            mostrar: _mostrarConfirmarContrasena,
                            onToggle: () => setState(
                              () => _mostrarConfirmarContrasena =
                                  !_mostrarConfirmarContrasena,
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Requerido'
                                : v != _contrasenaController.text
                                ? 'No coincide'
                                : null,
                          ),
                        ],
                      ),
                      // Asignación de Rol y Tienda
                      _buildSeccionCard(
                        icono: Icons.business_outlined,
                        colorIcono: const Color(0xFFEA4747),
                        titulo: 'Asignación de Rol y Tienda',
                        isMobile: isMobile,
                        children: [
                          _buildDropdown(
                            label: 'Rol',
                            icono: Icons.work_outline,
                            value: _rolIdSeleccionado,
                            items: _rolesDisponibles,
                            onChanged: (v) {
                              setState(() {
                                _rolIdSeleccionado = v;
                                // Si el rol cambia y no es 3 o 4, limpiar local
                                if (v != '3' && v != '4') {
                                  _localAsignadoSeleccionado = null;
                                }
                              });
                            },
                            isRol: true,
                          ),
                          // Solo mostrar el dropdown de local si el rol es 3 o 4
                          if (_rolIdSeleccionado == '3' ||
                              _rolIdSeleccionado == '4') ...[
                            const SizedBox(height: 16),
                            _buildDropdown(
                              label: 'Tienda Principal',
                              icono: Icons.store_outlined,
                              value: _localAsignadoSeleccionado,
                              items: _localesDisponibles,
                              onChanged: (v) => setState(
                                () => _localAsignadoSeleccionado = v,
                              ),
                              isRol: false,
                            ),
                          ],
                        ],
                      ),
                      // Switch de usuario activo
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEA4747).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.toggle_on_outlined,
                                color: Color(0xFFEA4747),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Usuario Activo',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Los usuarios inactivos no pueden iniciar sesión',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _activoCheckbox,
                              onChanged: (v) {
                                setState(() {
                                  _activoCheckbox = v;
                                });
                              },
                              activeColor: const Color(0xFF06B6D4),
                              activeTrackColor: const Color(
                                0xFF06B6D4,
                              ).withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Botones de acción
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _limpiarFormulario,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: const BorderSide(
                                  color: Color(0xFFD1D5DB),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Limpiar Formulario',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: _guardarUsuario,
                              icon: const Icon(
                                Icons.person_add,
                                color: Colors.white,
                                size: 18,
                              ),
                              label: const Text(
                                'Crear Usuario',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB94A48),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ], // cierre de children de Column
                  ), // cierre de Column
                ), // cierre de Form
              ), // cierre de Container
            ), // cierre de Center
          ); // cierre de SingleChildScrollView

    // 🟢 Usar el layout base ModuloBaseScreen
    return ModuloBaseScreen(
      tituloModulo: 'Crear Usuario',
      barraSuperior: barraSuperior,
      barraInferior: barraInferior,
      child: contenidoFormulario,
    );
  }

  // ...existing code...
}
