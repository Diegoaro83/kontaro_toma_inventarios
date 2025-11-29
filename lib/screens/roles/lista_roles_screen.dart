import 'package:flutter/material.dart';
import '../../database/drift_database.dart';
import '../../services/drift_service.dart';
import '../../theme/app_colors.dart';

/// 👔 PANTALLA DE LISTA DE ROLES
///
/// Muestra todos los roles del sistema con sus permisos.

class ListaRolesScreen extends StatefulWidget {
  const ListaRolesScreen({super.key});

  @override
  State<ListaRolesScreen> createState() => _ListaRolesScreenState();
}

class _ListaRolesScreenState extends State<ListaRolesScreen> {
  final _db = DriftService();
  List<Role> _roles = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarRoles();
  }

  Future<void> _cargarRoles() async {
    setState(() => _cargando = true);

    try {
      final roles = await _db.obtenerRoles();
      setState(() {
        _roles = roles;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      _mostrarError('Error al cargar roles: $e');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Roles del Sistema'),
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarRoles,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _roles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay roles registrados',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _roles.length,
              itemBuilder: (context, index) {
                final rol = _roles[index];
                return _buildRolCard(rol);
              },
            ),
    );
  }

  Widget _buildRolCard(Role rol) {
    final permisos = rol.permisos.split(',');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado con nombre y badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.work,
                      color: Color(0xFF7C3AED),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rol.nombre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A202C),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${rol.id}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!rol.activo)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'INACTIVO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Descripción
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  rol.descripcion,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A5568),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Permisos en chips
              const Text(
                'Permisos:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A202C),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: permisos
                    .map((permiso) => _buildPermisoChip(permiso))
                    .toList(),
              ),
              const SizedBox(height: 16),

              // Capacidades especiales
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (rol.accesoTodosModulos)
                    _buildCapacidadBadge(
                      'Todos los módulos',
                      Icons.apps,
                      Colors.blue,
                    ),
                  if (rol.informacionTiempoReal)
                    _buildCapacidadBadge(
                      'Tiempo real',
                      Icons.update,
                      Colors.green,
                    ),
                  if (rol.accesoInventarios)
                    _buildCapacidadBadge(
                      'Inventarios',
                      Icons.inventory_2,
                      AppColors.inventoryGreen,
                    ),
                  if (rol.accesoPuntoVenta)
                    _buildCapacidadBadge(
                      'POS',
                      Icons.point_of_sale,
                      AppColors.posPurple,
                    ),
                  if (rol.accesoConsultas)
                    _buildCapacidadBadge(
                      'Consultas',
                      Icons.search,
                      AppColors.referencesAmber,
                    ),
                  if (rol.accesoReportes)
                    _buildCapacidadBadge(
                      'Reportes',
                      Icons.assessment,
                      AppColors.reportsIndigo,
                    ),
                  if (rol.gestionCantidades)
                    _buildCapacidadBadge(
                      'Gestión cantidades',
                      Icons.edit,
                      Colors.orange,
                    ),
                  if (rol.gestionPrecios)
                    _buildCapacidadBadge(
                      'Gestión precios',
                      Icons.attach_money,
                      Colors.teal,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermisoChip(String permiso) {
    final permisoLimpio = permiso.trim();
    return Chip(
      label: Text(
        permisoLimpio,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: const Color(0xFF7C3AED),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildCapacidadBadge(String texto, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            texto,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
