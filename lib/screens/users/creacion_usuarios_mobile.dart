import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../theme/app_colors.dart';

/// 📱 VERSIÓN MÓVIL: CREACIÓN DE USUARIOS
///
/// Diseño vertical optimizado para pantallas pequeñas.
/// Formulario con scroll y campos apilados verticalmente.

class CreacionUsuariosMobile extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nombreCompletoController;
  final TextEditingController emailController;
  final TextEditingController telefonoController;
  final TextEditingController nombreUsuarioController;
  final TextEditingController contrasenaController;
  final TextEditingController confirmarContrasenaController;
  final String? rolSeleccionado;
  final String? tiendaSeleccionada;
  final bool usuarioActivo;
  final bool mostrarContrasena;
  final bool mostrarConfirmarContrasena;
  final Function(String?) onRolChanged;
  final Function(String?) onTiendaChanged;
  final Function(bool) onActivoChanged;
  final Function(bool) onMostrarContrasenaChanged;
  final Function(bool) onMostrarConfirmarContrasenaChanged;
  final VoidCallback onGenerarUsuario;
  final VoidCallback onGuardar;
  final VoidCallback onLimpiar;

  const CreacionUsuariosMobile({
    super.key,
    required this.formKey,
    required this.nombreCompletoController,
    required this.emailController,
    required this.telefonoController,
    required this.nombreUsuarioController,
    required this.contrasenaController,
    required this.confirmarContrasenaController,
    required this.rolSeleccionado,
    required this.tiendaSeleccionada,
    required this.usuarioActivo,
    required this.mostrarContrasena,
    required this.mostrarConfirmarContrasena,
    required this.onRolChanged,
    required this.onTiendaChanged,
    required this.onActivoChanged,
    required this.onMostrarContrasenaChanged,
    required this.onMostrarConfirmarContrasenaChanged,
    required this.onGenerarUsuario,
    required this.onGuardar,
    required this.onLimpiar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Crear Usuario'),
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.pushNamed(context, '/lista-usuarios');
            },
            tooltip: 'Ver usuarios',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 📝 Sección: Información Personal
              _buildSeccionTitulo('Información Personal', Icons.person),
              const SizedBox(height: 16),

              _buildTextField(
                controller: nombreCompletoController,
                label: 'Nombre Completo',
                hint: 'Ej: Juan Pérez',
                icon: Icons.badge,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: emailController,
                label: 'Correo Electrónico',
                hint: 'ejemplo@oxigenozerogrados.com',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El correo es obligatorio';
                  }
                  if (!value.contains('@')) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: telefonoController,
                label: 'Teléfono (opcional)',
                hint: '3001234567',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),

              // 🔐 Sección: Credenciales
              _buildSeccionTitulo('Credenciales de Acceso', Icons.lock),
              const SizedBox(height: 16),

              _buildTextField(
                controller: nombreUsuarioController,
                label: 'Nombre de Usuario',
                hint: 'Generado automáticamente',
                icon: Icons.account_circle,
                readOnly: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.auto_fix_high, size: 20),
                  onPressed: onGenerarUsuario,
                  tooltip: 'Generar automáticamente',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Presiona el botón para generar';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: contrasenaController,
                label: 'Contraseña',
                hint: 'Mínimo 6 caracteres',
                icon: Icons.vpn_key,
                obscureText: !mostrarContrasena,
                suffixIcon: IconButton(
                  icon: Icon(
                    mostrarContrasena ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                  ),
                  onPressed: () =>
                      onMostrarContrasenaChanged(!mostrarContrasena),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La contraseña es obligatoria';
                  }
                  if (value.length < 6) {
                    return 'Mínimo 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: confirmarContrasenaController,
                label: 'Confirmar Contraseña',
                hint: 'Repite la contraseña',
                icon: Icons.vpn_key,
                obscureText: !mostrarConfirmarContrasena,
                suffixIcon: IconButton(
                  icon: Icon(
                    mostrarConfirmarContrasena
                        ? Icons.visibility_off
                        : Icons.visibility,
                    size: 20,
                  ),
                  onPressed: () => onMostrarConfirmarContrasenaChanged(
                    !mostrarConfirmarContrasena,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirma la contraseña';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 🏢 Sección: Asignación
              _buildSeccionTitulo('Asignación de Rol y Tienda', Icons.business),
              const SizedBox(height: 16),

              _buildDropdown(
                label: 'Rol',
                value: rolSeleccionado,
                icon: Icons.work,
                items: AppConfig.roles
                    .map(
                      (rol) => DropdownMenuItem(
                        value: rol['id'] as String,
                        child: Text(rol['nombre'] as String),
                      ),
                    )
                    .toList(),
                onChanged: onRolChanged,
              ),
              const SizedBox(height: 16),

              _buildDropdown(
                label: 'Tienda',
                value: tiendaSeleccionada,
                icon: Icons.store,
                items: AppConfig.tiendas
                    .map(
                      (tienda) => DropdownMenuItem(
                        value: tienda['id'] as String,
                        child: Text(
                          '${tienda['nombre']} - ${tienda['ciudad']}',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onTiendaChanged,
              ),
              const SizedBox(height: 16),

              // Switch de usuario activo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.toggle_on, color: Color(0xFF7C3AED)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Usuario Activo',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Switch(
                      value: usuarioActivo,
                      onChanged: onActivoChanged,
                      activeColor: AppColors.success,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 🎯 Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onLimpiar,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF7C3AED)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Limpiar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: onGuardar,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Crear Usuario',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget para título de sección
  Widget _buildSeccionTitulo(String titulo, IconData icono) {
    return Row(
      children: [
        Icon(icono, color: const Color(0xFF7C3AED), size: 24),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A202C),
          ),
        ),
      ],
    );
  }

  /// Widget para campo de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool readOnly = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
    );
  }

  /// Widget para dropdown
  Widget _buildDropdown({
    required String label,
    required String? value,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}
