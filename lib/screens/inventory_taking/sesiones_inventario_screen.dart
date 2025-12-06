import 'package:flutter/material.dart';
import 'package:kontaro/screens/inventory_taking/escaneo_inventario_screen.dart'
    as escaneo;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' as material;
import 'package:kontaro/widgets/common/barra_superior_modulo.dart';
import 'package:kontaro/widgets/common/barra_inferior_modulo.dart';

/// 📱 SESIONES DE INVENTARIO
/// Pantalla completa con listado, creación y escaneo
class SesionesInventarioScreen extends StatefulWidget {
  final String nombreUsuario;
  final String rolNombre;

  const SesionesInventarioScreen({
    super.key,
    this.nombreUsuario = 'Usuario',
    this.rolNombre = 'Auditor',
  });

  @override
  State<SesionesInventarioScreen> createState() =>
      _SesionesInventarioScreenState();
}

class _SesionesInventarioScreenState extends State<SesionesInventarioScreen> {
  /// ⚠️ CONFIRMACIÓN DE ELIMINACIÓN DE SESIÓN
  ///
  /// Muestra un diálogo de alerta antes de eliminar una sesión de inventario.
  /// - Si el usuario confirma, elimina la sesión.
  /// - Si cancela, no realiza ninguna acción.
  /// - El mensaje advierte que la acción es irreversible.
  void _confirmarEliminarSesion(int index) {
    // 🎨 DIÁLOGO DE CONFIRMACIÓN CON ESTILO Figma
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final nombreSesion = _sesiones[index]['id'] ?? '';
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7D6), // Fondo amarillo suave
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFF59E0B),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Confirmar eliminación',
                      style: material.TextStyle(
                        fontWeight: material.FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  '¿Está seguro que desea eliminar la sesión "$nombreSesion"?\n\nEsta acción no se puede deshacer.',
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF5F5F5),
                          foregroundColor: const Color(0xFF06B6D4),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _sesiones.removeAt(index);
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFEA4747),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Eliminar',
                          style: TextStyle(fontWeight: FontWeight.w600),
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

  List<Map<String, dynamic>> _sesiones = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarSesiones();
  }

  Future<void> _cargarSesiones() async {
    setState(() => _cargando = true);
    // Simulación: deberías usar _driftService.obtenerSesiones() en producción
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _sesiones = [
        {
          'id': 'sesion-001',
          'nombreLocal': 'visto',
          'estado': 'en_progreso',
          'fechaCreacion': DateTime.now(),
          'totalReferencias': 729,
          'referenciasEscaneadas': 0,
        },
      ];
      _cargando = false;
    });
  }

  void _mostrarModalNuevaSesion() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        String nombreSesion = '';
        PlatformFile? archivoExcel;
        int referenciasEncontradas = 0;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Crear Nueva Sesión de Inventario',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Importa un archivo Excel con las referencias iniciales o comienza una sesión vacía',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la Sesión (Local)',
                      hintText: 'Ej: Inventario Mes Local',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setModalState(() => nombreSesion = v),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Opciones de Inicio',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 6),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Importar desde Excel',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        archivoExcel == null
                            ? ElevatedButton.icon(
                                icon: const Icon(Icons.upload_file),
                                label: const Text('Seleccionar Archivo'),
                                onPressed: () async {
                                  FilePickerResult? result = await FilePicker
                                      .platform
                                      .pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: ['xlsx', 'xls'],
                                      );
                                  if (result != null &&
                                      result.files.isNotEmpty) {
                                    setModalState(() {
                                      archivoExcel = result.files.first;
                                      referenciasEncontradas =
                                          729; // Simulación
                                    });
                                  }
                                },
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${archivoExcel!.name}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '$referenciasEncontradas referencias encontradas',
                                          style: const TextStyle(
                                            color: Colors.green,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            size: 18,
                                          ),
                                          onPressed: () => setModalState(
                                            () => archivoExcel = null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        _sesiones.add({
                                          'id': 'sesion-001',
                                          'nombreLocal': nombreSesion,
                                          'estado': 'en_progreso',
                                          'fechaCreacion': DateTime.now(),
                                          'totalReferencias':
                                              referenciasEncontradas,
                                          'referenciasEscaneadas': 0,
                                        });
                                      });
                                    },
                                    child: Text(
                                      'Crear con Excel ($referenciasEncontradas refs)',
                                    ),
                                  ),
                                ],
                              ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Columnas requeridas en el Excel:',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '- COD_REF (código de barras)\n- NOM_REF (nombre del producto)\n- VAL_REF (precio unitario)\n- SAL_REF (cantidad en stock)\n- Val_total (valor total del lote)',
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ); // <- cierre de Padding
          },
        ); // <- cierre de StatefulBuilder
      },
    ); // <- cierre de showModalBottomSheet
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF102040), Color(0xFF1A202C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            BarraSuperiorModulo(
              nombreEmpresa: 'Oxígeno Zero Grados',
              subtitulo: 'Sesiones de Inventario',
              nombrePerfil: widget.nombreUsuario,
              estadoSistema: 'Activo',
              nombreUsuario: widget.nombreUsuario,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 900;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            buildNuevaSesionButton(_mostrarModalNuevaSesion),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (_cargando)
                          const Center(child: CircularProgressIndicator())
                        else if (_sesiones.isEmpty)
                          const Center(child: Text('No hay sesiones creadas'))
                        else if (isDesktop) ...[
                          Wrap(
                            alignment: WrapAlignment.start,
                            spacing: 24,
                            runSpacing: 24,
                            children: [
                              for (int i = 0; i < _sesiones.length; i++)
                                SizedBox(
                                  width: 389.36,
                                  height: 291.86,
                                  child: buildSesionCard(
                                    nombreSesion: _sesiones[i]['id'],
                                    fecha: _formatearFecha(
                                      _sesiones[i]['fechaCreacion'],
                                    ),
                                    totalReferencias:
                                        _sesiones[i]['totalReferencias'],
                                    referenciasEscaneadas:
                                        _sesiones[i]['referenciasEscaneadas'],
                                    estado: _sesiones[i]['estado'],
                                    nombreLocal: _sesiones[i]['nombreLocal'],
                                    onContinuar: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              escaneo.EscaneoInventarioScreen(
                                                sesion: _sesiones[i],
                                                nombreUsuario:
                                                    widget.nombreUsuario,
                                                rolNombre: widget.rolNombre,
                                              ),
                                        ),
                                      );
                                    },
                                    onDelete: () {
                                      _confirmarEliminarSesion(i);
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ] else ...[
                          for (int i = 0; i < _sesiones.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: SizedBox(
                                width: double.infinity,
                                child: buildSesionCard(
                                  nombreSesion: _sesiones[i]['id'],
                                  fecha: _formatearFecha(
                                    _sesiones[i]['fechaCreacion'],
                                  ),
                                  totalReferencias:
                                      _sesiones[i]['totalReferencias'],
                                  referenciasEscaneadas:
                                      _sesiones[i]['referenciasEscaneadas'],
                                  estado: _sesiones[i]['estado'],
                                  nombreLocal: _sesiones[i]['nombreLocal'],
                                  onContinuar: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            escaneo.EscaneoInventarioScreen(
                                              sesion: _sesiones[i],
                                              nombreUsuario:
                                                  widget.nombreUsuario,
                                              rolNombre: widget.rolNombre,
                                            ),
                                      ),
                                    );
                                  },
                                  onDelete: () {
                                    _confirmarEliminarSesion(i);
                                  },
                                ),
                              ),
                            ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
            BarraInferiorModulo(
              estadoSistema: 'Activo',
              ultimaSincronizacion: 'Hoy, 12:00',
              onVolver: () {
                Navigator.of(context).pop();
              },
              onSalir: () {
                // Aquí podrías mostrar un diálogo de confirmación o cerrar sesión
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 🎨 Botón + Nueva Sesión con degradado Figma, tamaño y posición personalizada
  Widget buildNuevaSesionButton(VoidCallback onPressed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end, // A la derecha
      children: [
        Container(
          width: 136.68, // ancho exacto
          height: 36, // alto exacto
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00C950), Color(0xFF00B94A), Color(0xFF008236)],
              stops: [0.0, 0.39, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add, color: Colors.white, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Nueva Sesión',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  } // HASTA ACA VA EL CODIGO DEL BOTÓN

  /// 🎨 CARD DE SESIÓN DE INVENTARIO (estilo módulo)
  Widget buildSesionCard({
    required String nombreSesion,
    required String fecha,
    required int totalReferencias,
    required int referenciasEscaneadas,
    required String estado,
    required VoidCallback onContinuar,
    String? nombreLocal,
    VoidCallback? onDelete,
  }) {
    final porcentaje = totalReferencias == 0
        ? 0.0
        : referenciasEscaneadas / totalReferencias;
    final estadoColor = estado == 'en_progreso'
        ? const Color(0xFF00C950) // Verde Figma
        : const Color(0xFF06B6D4); // cyclicalCyan
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Eliminado el ícono de inventario
          // Info principal
          Row(
            children: [
              Expanded(
                child: Text(
                  nombreSesion,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Badge de estado
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: estadoColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  estado == 'en_progreso' ? 'En Progreso' : 'Finalizada',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Fecha: $fecha',
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '$referenciasEscaneadas / $totalReferencias referencias',
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Fila de progreso y papelera
          Row(
            /// 🖥️ Fila responsive con Expanded para evitar overflow
            children: [
              Expanded(
                child: Text(
                  'Progreso del inventario',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${(porcentaje * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF00B4FF),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  if (onDelete != null) onDelete();
                },
                child: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFE53935),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Barra de progreso con degradado Figma
          SizedBox(
            height: 12,
            child: Stack(
              children: [
                // Fondo gris claro
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                      255,
                      110,
                      109,
                      109,
                    ).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                // Progreso con degradado Figma
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: porcentaje,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF00C950),
                          Color(0xFF00B94A),
                          Color(0xFF008236),
                        ],
                        stops: [0.0, 0.39, 1.0],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF00C950),
                    Color(0xFF00B94A),
                    Color(0xFF008236),
                  ],
                  stops: [0.0, 0.39, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: onContinuar,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      /// 🖥️ Fila con Flexible para evitar overflow en el texto
                      children: [
                        const Icon(
                          Icons.qr_code_scanner,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: const Text(
                            'Continuar Escaneo',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}, ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}
