import 'package:flutter/material.dart';
import '../../services/drift_service.dart';
import '../../database/drift_database.dart';
import 'editar_usuario_screen.dart';

/// 👥 PANTALLA DE LISTA DE USUARIOS - DISEÑO FIGMA
///
/// Muestra todos los usuarios registrados en una tabla con:
/// - Datos principales: Cédula, Nombre, Usuario, Rol, Local
/// - Estado activo/inactivo
/// - Opciones de editar y eliminar por fila
/// - Diseño responsive con degradado rojo Figma

class ListaUsuariosScreen extends StatefulWidget {
  const ListaUsuariosScreen({super.key});

  @override
  State<ListaUsuariosScreen> createState() => _ListaUsuariosScreenState();
}

class _ListaUsuariosScreenState extends State<ListaUsuariosScreen> {
  List<Usuario> _usuarios = [];
  Map<String, String> _rolesMap = {}; // rolId -> nombre
  Map<String, String> _localesMap = {}; // localId -> nombre
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      final db = DriftService();

      // Cargar usuarios
      final usuarios = await db.obtenerUsuarios();

      // Cargar roles para mapeo
      final roles = await db.obtenerRolesActivos();
      final rolesMap = {for (var r in roles) r.id: r.nombre};

      // Cargar locales para mapeo
      final locales = await db.obtenerLocalesActivos();
      final localesMap = {for (var l in locales) l.id: l.nombre};

      setState(() {
        _usuarios = usuarios;
        _rolesMap = rolesMap;
        _localesMap = localesMap;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      _mostrarError('Error al cargar usuarios: ${e.toString()}');
    }
  }

  Future<void> _eliminarUsuario(String cedula, String nombre) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de eliminar al usuario "$nombre"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      final db = DriftService();
      await db.eliminarUsuario(cedula);
      _mostrarExito('✅ Usuario eliminado: $nombre');
      await _cargarDatos(); // Recargar lista
    } catch (e) {
      _mostrarError('❌ Error al eliminar: ${e.toString()}');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: const Color(0xFFEF4444),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: const Color(0xFF10B981),
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
          'Lista de Usuarios',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargarDatos,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _usuarios.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay usuarios registrados',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _cargarDatos,
              child: isMobile ? _buildListaMobile() : _buildTablaDesktop(),
            ),
    );
  }

  /// 📱 Vista móvil: Cards verticales
  Widget _buildListaMobile() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _usuarios.length,
      itemBuilder: (context, index) {
        final usuario = _usuarios[index];
        final rolNombre = _rolesMap[usuario.rolId] ?? 'Sin rol';
        final localNombre = _localesMap[usuario.localAsignado] ?? 'Sin local';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: usuario.activo
                          ? const Color(0xFF10B981).withOpacity(0.1)
                          : Colors.grey[300],
                      child: Icon(
                        Icons.person,
                        color: usuario.activo
                            ? const Color(0xFF10B981)
                            : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            usuario.nombresApellidos,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '@${usuario.nombreUsuario}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: usuario.activo
                            ? const Color(0xFF10B981).withOpacity(0.1)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        usuario.activo ? 'ACTIVO' : 'INACTIVO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: usuario.activo
                              ? const Color(0xFF10B981)
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildInfoRow(Icons.badge, 'Cédula', usuario.cedula),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.phone,
                  'Teléfono',
                  usuario.telefono ?? 'No registrado',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.work_outline, 'Rol', rolNombre),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.store, 'Local', localNombre),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.qr_code, 'Código', usuario.codigo),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final resultado = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditarUsuarioScreen(usuario: usuario),
                            ),
                          );
                          if (resultado == true) _cargarDatos();
                        },
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Editar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF3B82F6),
                          side: const BorderSide(color: Color(0xFF3B82F6)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _eliminarUsuario(
                          usuario.cedula,
                          usuario.nombresApellidos,
                        ),
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('Eliminar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          side: const BorderSide(color: Color(0xFFEF4444)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icono, String label, String valor) {
    return Row(
      children: [
        Icon(icono, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
        ),
        Expanded(
          child: Text(
            valor,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  /// 💻 Vista desktop: Tabla
  Widget _buildTablaDesktop() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1400),
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
            children: [
              // Header de tabla
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEA4747).withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.people, color: Colors.grey[700]),
                    const SizedBox(width: 12),
                    Text(
                      'Total de usuarios: ${_usuarios.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Tabla
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24,
                  headingRowColor: WidgetStateProperty.all(
                    const Color(0xFFF9FAFB),
                  ),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Cédula',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Nombre Completo',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Usuario',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Teléfono',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Rol',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Local',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Código',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Estado',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Acciones',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                  rows: _usuarios.map((usuario) {
                    final rolNombre = _rolesMap[usuario.rolId] ?? 'Sin rol';
                    final localNombre =
                        _localesMap[usuario.localAsignado] ?? 'Sin local';

                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            usuario.cedula,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        DataCell(
                          Text(
                            usuario.nombresApellidos,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        DataCell(
                          Text(
                            '@${usuario.nombreUsuario}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            usuario.telefono ?? 'N/A',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        DataCell(
                          Text(rolNombre, style: const TextStyle(fontSize: 13)),
                        ),
                        DataCell(
                          Text(
                            localNombre,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              usuario.codigo,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: usuario.activo
                                  ? const Color(0xFF10B981).withOpacity(0.1)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              usuario.activo ? 'ACTIVO' : 'INACTIVO',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: usuario.activo
                                    ? const Color(0xFF10B981)
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Color(0xFF3B82F6),
                                ),
                                tooltip: 'Editar',
                                onPressed: () async {
                                  final resultado = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditarUsuarioScreen(usuario: usuario),
                                    ),
                                  );
                                  if (resultado == true) _cargarDatos();
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  size: 18,
                                  color: Color(0xFFEF4444),
                                ),
                                tooltip: 'Eliminar',
                                onPressed: () => _eliminarUsuario(
                                  usuario.cedula,
                                  usuario.nombresApellidos,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
