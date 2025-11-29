import 'package:flutter/material.dart';
import 'dart:math';
import '../../services/drift_service.dart';
import '../../theme/app_colors.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _nombresApellidosController = TextEditingController();
  final _nombreUsuarioController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();

  String? _rolIdSeleccionado;
  String? _localAsignadoSeleccionado;
  bool _activoCheckbox = true;
  bool _mostrarContrasena = false;
  bool _mostrarConfirmarContrasena = false;

  List<Map<String, dynamic>> _rolesDisponibles = [];
  List<Map<String, dynamic>> _localesDisponibles = [];
  bool _cargandoDatos = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  @override
  void dispose() {
    _cedulaController.dispose();
    _nombresApellidosController.dispose();
    _nombreUsuarioController.dispose();
    _telefonoController.dispose();
    _contrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }

  String _generarCodigoAleatorio() {
    final random = Random();
    final codigo = random.nextInt(9000) + 1000;
    return codigo.toString();
  }

  Future<void> _cargarDatosIniciales() async {
    try {
      final db = DriftService();
      final roles = await db.obtenerRolesActivos();
      final locales = await db.obtenerLocalesActivos();

      setState(() {
        _rolesDisponibles = roles.map((rol) {
          return {
            'id': rol.id,
            'nombre': rol.nombre,
            'descripcion': rol.descripcion,
          };
        }).toList();

        _localesDisponibles = locales.map((local) {
          return {'id': local.id, 'nombre': local.nombre, 'tipo': local.tipo};
        }).toList();

        _cargandoDatos = false;
      });
    } catch (e) {
      setState(() => _cargandoDatos = false);
      _mostrarError('Error al cargar datos: ${e.toString()}');
    }
  }

  Future<void> _guardarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    if (_rolIdSeleccionado == null) {
      _mostrarError('⚠️ Debes seleccionar un rol');
      return;
    }

    if (_localAsignadoSeleccionado == null) {
      _mostrarError('⚠️ Debes seleccionar un local');
      return;
    }

    if (_contrasenaController.text != _confirmarContrasenaController.text) {
      _mostrarError('⚠️ Las contraseñas no coinciden');
      return;
    }

    try {
      final db = DriftService();
      final codigoGenerado = _generarCodigoAleatorio();

      await db.crearUsuario(
        cedula: _cedulaController.text.trim(),
        nombresApellidos: _nombresApellidosController.text.trim(),
        nombreUsuario: _nombreUsuarioController.text.trim(),
        telefono: _telefonoController.text.trim().isEmpty
            ? null
            : _telefonoController.text.trim(),
        contrasena: _contrasenaController.text,
        rolId: _rolIdSeleccionado!,
        localAsignado: _localAsignadoSeleccionado!,
        codigo: codigoGenerado,
        activo: _activoCheckbox,
      );

      _mostrarExito(
        '✅ Usuario creado: ${_nombreUsuarioController.text} | Código: $codigoGenerado',
      );

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) _limpiarFormulario();
      });
    } catch (e) {
      String mensajeError = 'Error al crear usuario';
      final errorString = e.toString();
      if (errorString.contains('PRIMARY KEY')) {
        mensajeError = '⚠️ Ya existe un usuario con esta cédula';
      } else if (errorString.contains('UNIQUE') &&
          errorString.contains('codigo')) {
        mensajeError = '⚠️ El código de usuario ya está en uso';
      } else if (errorString.contains('UNIQUE') &&
          errorString.contains('nombreUsuario')) {
        mensajeError = '⚠️ El nombre de usuario ya está registrado';
      } else {
        mensajeError = '❌ Error: $errorString';
      }
      _mostrarError(mensajeError);
    }
  }

  void _limpiarFormulario() {
    _formKey.currentState?.reset();
    _cedulaController.clear();
    _nombresApellidosController.clear();
    _nombreUsuarioController.clear();
    _telefonoController.clear();
    _contrasenaController.clear();
    _confirmarContrasenaController.clear();
    setState(() {
      _rolIdSeleccionado = null;
      _localAsignadoSeleccionado = null;
      _activoCheckbox = true;
      _mostrarContrasena = false;
      _mostrarConfirmarContrasena = false;
    });
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Crear Usuario',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEA4747), Color(0xFF4A2020), Color(0xFF470707)],
              stops: [0.0, 0.529, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: _cargandoDatos
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
                        _buildSeccionCard(
                          icono: Icons.person_outline,
                          colorIcono: const Color(0xFFEA4747),
                          titulo: 'Información Personal',
                          isMobile: isMobile,
                          children: [
                            if (isMobile) ...[
                              _buildCampo(
                                label: 'Cedula',
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
                            ] else ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildCampo(
                                      label: 'Cedula',
                                      icono: Icons.badge_outlined,
                                      controller: _cedulaController,
                                      keyboardType: TextInputType.number,
                                      validator: (v) =>
                                          v == null || v.trim().isEmpty
                                          ? 'Requerido'
                                          : v.trim().length < 6
                                          ? 'Mínimo 6 dígitos'
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildCampo(
                                      label: 'Nombre Completo',
                                      icono: Icons.person,
                                      controller: _nombresApellidosController,
                                      validator: (v) =>
                                          v == null || v.trim().isEmpty
                                          ? 'Requerido'
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildCampo(
                                      label: 'Teléfono (opcional)',
                                      icono: Icons.phone_outlined,
                                      controller: _telefonoController,
                                      keyboardType: TextInputType.phone,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildCodigoInfo()),
                                ],
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 20),
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
                            if (isMobile) ...[
                              _buildCampoContrasena(
                                label: 'Contraseña',
                                controller: _contrasenaController,
                                mostrar: _mostrarContrasena,
                                onToggle: () => setState(
                                  () =>
                                      _mostrarContrasena = !_mostrarContrasena,
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
                            ] else ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildCampoContrasena(
                                      label: 'Contraseña',
                                      controller: _contrasenaController,
                                      mostrar: _mostrarContrasena,
                                      onToggle: () => setState(
                                        () => _mostrarContrasena =
                                            !_mostrarContrasena,
                                      ),
                                      validator: (v) => v == null || v.isEmpty
                                          ? 'Requerido'
                                          : v.length < 6
                                          ? 'Mínimo 6 caracteres'
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildCampoContrasena(
                                      label: 'Confirmar Contraseña',
                                      controller:
                                          _confirmarContrasenaController,
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
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildSeccionCard(
                          icono: Icons.business_outlined,
                          colorIcono: const Color(0xFFEA4747),
                          titulo: 'Asignación de Rol y Tienda',
                          isMobile: isMobile,
                          children: [
                            if (isMobile) ...[
                              _buildDropdown(
                                label: 'Rol',
                                icono: Icons.work_outline,
                                value: _rolIdSeleccionado,
                                items: _rolesDisponibles,
                                onChanged: (v) =>
                                    setState(() => _rolIdSeleccionado = v),
                                isRol: true,
                              ),
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
                            ] else ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDropdown(
                                      label: 'Rol',
                                      icono: Icons.work_outline,
                                      value: _rolIdSeleccionado,
                                      items: _rolesDisponibles,
                                      onChanged: (v) => setState(
                                        () => _rolIdSeleccionado = v,
                                      ),
                                      isRol: true,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildDropdown(
                                      label: 'Tienda Principal',
                                      icono: Icons.store_outlined,
                                      value: _localAsignadoSeleccionado,
                                      items: _localesDisponibles,
                                      onChanged: (v) => setState(
                                        () => _localAsignadoSeleccionado = v,
                                      ),
                                      isRol: false,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 20),
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
                                  color: const Color(
                                    0xFFEA4747,
                                  ).withOpacity(0.1),
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
                                onChanged: (v) =>
                                    setState(() => _activoCheckbox = v),
                                activeColor: const Color(0xFF06B6D4),
                                activeTrackColor: const Color(
                                  0xFF06B6D4,
                                ).withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        if (isMobile) ...[
                          SizedBox(
                            width: double.infinity,
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
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
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
                        ] else ...[
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
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSeccionCard({
    required IconData icono,
    required Color colorIcono,
    required String titulo,
    required bool isMobile,
    required List<Widget> children,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorIcono.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icono, color: colorIcono, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
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

  Widget _buildCampo({
    required String label,
    required IconData icono,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    IconData? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFEA4747),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, size: 16, color: Colors.grey[400])
                : null,
            errorStyle: const TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildCampoContrasena({
    required String label,
    required TextEditingController controller,
    required bool mostrar,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lock_outline, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !mostrar,
          validator: validator,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFEA4747),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            suffixIcon: IconButton(
              icon: Icon(
                mostrar ? Icons.visibility_off : Icons.visibility,
                size: 16,
                color: Colors.grey[400],
              ),
              onPressed: onToggle,
            ),
            errorStyle: const TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icono,
    required String? value,
    required List<Map<String, dynamic>> items,
    required ValueChanged<String?> onChanged,
    required bool isRol,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          items: items.map((item) {
            String displayText = isRol
                ? '${item['nombre']} - ${item['descripcion']}'
                : '${item['nombre']} (${item['tipo']})';
            return DropdownMenuItem<String>(
              value: item['id'] as String,
              child: Text(
                displayText,
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFEA4747),
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
          ),
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
        ),
      ],
    );
  }

  Widget _buildCodigoInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.qr_code, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                'Código interno',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Se genera automáticamente',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
