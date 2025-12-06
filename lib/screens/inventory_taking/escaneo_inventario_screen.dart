import 'package:flutter/material.dart';
// Eliminar la siguiente línea para evitar conflictos de nombres con widgets
// import 'package:flutter/widgets.dart';
import 'package:kontaro/models/referencia_maestra.dart';
import 'package:kontaro/theme/app_colors.dart';
import 'package:kontaro/services/drift_service.dart';
import 'package:drift/drift.dart' show Value;
import 'package:kontaro/database/drift_database.dart';
// 🚀 Importar el widget PanelTallasWidget para mostrar tallas escaneadas
import 'package:kontaro/widgets/panel_tallas_widget.dart';
import '../../widgets/common/barra_superior_modulo.dart';
import '../../widgets/common/barra_inferior_modulo.dart';

/// 📱 PANTALLA DE ESCANEO DE INVENTARIO
///
/// Permite escanear códigos de barras, registrar productos y manejar excedentes.
/// 📱 PANTALLA DE ESCANEO DE INVENTARIO
/// Permite escanear códigos de barras, registrar productos y manejar excedentes.
class EscaneoInventarioScreen extends StatefulWidget {
  final Map<String, dynamic> sesion;
  final String nombreUsuario; // Nombre real del usuario
  final String rolNombre; // Nombre del rol
  const EscaneoInventarioScreen({
    Key? key,
    required this.sesion,
    required this.nombreUsuario,
    required this.rolNombre,
  }) : super(key: key);

  @override
  State<EscaneoInventarioScreen> createState() =>
      _EscaneoInventarioScreenState();
}

class _EscaneoInventarioScreenState extends State<EscaneoInventarioScreen> {
  /// 🚀 Procesar código escaneado (stub temporal)
  /// Recibe el código de barras y realiza la lógica de búsqueda/registro.
  void _procesarCodigoEscaneado(String codigo) {
    // TODO: Implementar lógica real de escaneo y registro
    debugPrint('Código escaneado: $codigo');
  }

  /// 🚀 Alternar escaneo con cámara (stub temporal)
  void _toggleEscaneo() {
    setState(() {
      _escaneandoConCamara = !_escaneandoConCamara;
    });
    // TODO: Implementar lógica real de escaneo con cámara
    debugPrint('Toggle escaneo con cámara: $_escaneandoConCamara');
  }

  /// 🚀 Cargar datos de la sesión (stub temporal)
  Future<void> _cargarDatosSesion() async {
    // TODO: Implementar carga real de datos de sesión e indicadores
    debugPrint('Cargar datos de sesión (stub)');
  }

  /// Servicio Drift para acceso a BD
  final DriftService _driftService = DriftService();

  /// Controladores para ingreso manual
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController valorController = TextEditingController();

  // Variables de estado
  int _pestanaActual = 0;
  ReferenciaMaestra? _referenciaSeleccionada;
  List<Map<String, dynamic>> _historialReciente = [];
  List<dynamic> _indicadores = [];
  final TextEditingController _codigoBarrasController = TextEditingController();
  bool _escaneandoConCamara = false;

  /// ⚠️ Mostrar diálogo de cantidad excedida
  Future<bool?> _mostrarDialogoExcedente(
    String codigo,
    String nombre,
    int cantidadEsperada,
    int cantidadActual,
  ) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber, color: AppColors.warning, size: 32),
              const SizedBox(width: 12),
              Expanded(child: Text('Cantidad Excedida')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Referencia: $codigo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(nombre, style: TextStyle(fontSize: 13)),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cantidad en inventario: $cantidadEsperada'),
                    Text('Ya escaneadas: ${cantidadActual - 1}'),
                    SizedBox(height: 8),
                    Text(
                      'Excedente: ${cantidadActual - cantidadEsperada} unidades',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                '¿Desea registrar esta unidad adicional como sobrante?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
              ),
              child: Text('ACEPTAR'),
            ),
          ],
        );
      },
    );
  }

  // Método build duplicado eliminado. El método build correcto está más abajo en el archivo y retorna el Scaffold completo.

  // Fragmentos sueltos eliminados. Todo el código de widgets debe estar dentro de métodos, funciones o clases.

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      // 🎨 Barra superior reutilizable
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: BarraSuperiorModulo(
          nombreEmpresa: 'Oxígeno Zero Grados',
          subtitulo: 'Toma de Inventario',
          nombreUsuario: widget.nombreUsuario, // ✅ Usuario real
          nombrePerfil: widget.rolNombre, // ✅ Rol real
          estadoSistema: 'En sesión',
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF102040), Color(0xFF1A202C)],
          ),
        ),
        child: Column(
          children: [
            // Título y pestañas
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Toma de Inventarios',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sistema de conteo con lectura de código de barras',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Pestañas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  _buildTab(0, Icons.qr_code_scanner, 'Escaneo'),
                  const SizedBox(width: 8),
                  _buildTab(1, Icons.bar_chart, 'Resumen'),
                  const SizedBox(width: 8),
                  _buildTab(2, Icons.list, 'Lista'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Contenido de las pestañas
            Expanded(
              child: _pestanaActual == 0
                  ? _buildPestanaEscaneo()
                  : _pestanaActual == 1
                  ? _buildPestanaResumen(isMobile)
                  : _buildPestanaLista(),
            ),
            // 🎨 Barra inferior reutilizable
            BarraInferiorModulo(
              estadoSistema: 'En sesión', // Estado del sistema
              ultimaSincronizacion: 'No sincronizado', // Última sincronización
              onVolver: () {
                Navigator.of(context).pop();
              },
              onSalir: () {
                // TODO: Implementar lógica de logout o cierre de sesión
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 🏷️ Construir pestaña individual
  Widget _buildTab(int index, IconData icon, String label) {
    final isActive = _pestanaActual == index;
    return InkWell(
      onTap: () => setState(() => _pestanaActual = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.inventoryGreen
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? AppColors.inventoryGreen
                : Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
                color: isActive ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📷 Pestaña de Escaneo (vista principal)
  Widget _buildPestanaEscaneo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 🔍 CAMPO DE ESCANEO
          _buildCampoEscaneo(),
          const SizedBox(height: 24),

          // 👕 PANEL DE TALLAS (si hay referencia seleccionada)
          if (_referenciaSeleccionada != null) ...[
            PanelTallasWidget(
              tallasDisponiblesJson: _referenciaSeleccionada!
                  .tallaDisp, // JSON de tallas disponibles
              tallasEscaneadasJson: null, // No disponible en ReferenciaMaestra
              nombreReferencia: _referenciaSeleccionada!.nomRef,
              codigoReferencia: _referenciaSeleccionada!.codRef,
            ),
            const SizedBox(height: 24),
          ],

          // 📜 HISTORIAL DE ÚLTIMOS ESCANEOS (mejorado)
          _buildHistorialRegistrosMejorado(),
        ],
      ),
    );
  }

  /// 📊 Pestaña de Resumen (estadísticas)
  Widget _buildPestanaResumen(bool isMobile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 📊 PANEL DE INDICADORES
          // TODO: Implementar IndicadoresInventarioWidget cuando esté disponible
          // if (_indicadores.isNotEmpty) ...[
          //   IndicadoresInventarioWidget(indicadores: _indicadores),
          // ],
        ],
      ),
    );
  }

  /// 📋 Pestaña de Lista de productos
  Widget _buildPestanaLista() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list_alt,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Lista de Productos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Próximamente: Ver todas las referencias, cantidades y progreso',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔍 Campo de escaneo (simplificado para pestaña principal)
  Widget _buildCampoEscaneo() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          const Text(
            'Escanear Código de Barras',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Escanea o ingresa manualmente el código',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codigoBarrasController,
                  decoration: InputDecoration(
                    hintText: 'Código de barras...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSubmitted: (codigo) => _procesarCodigoEscaneado(codigo),
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                ),
              ),
              const SizedBox(width: 8),
              // 🔍 Botón para procesar código manualmente
              ElevatedButton.icon(
                onPressed: () {
                  final codigo = _codigoBarrasController.text.trim();
                  if (codigo.isNotEmpty) {
                    _procesarCodigoEscaneado(codigo);
                  }
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('OK'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.inventoryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 📷 Botón para toggle cámara
              IconButton(
                icon: Icon(
                  _escaneandoConCamara ? Icons.cancel : Icons.qr_code_scanner,
                  size: 28,
                ),
                onPressed: _toggleEscaneo,
                tooltip: 'Escanear con cámara',
                style: IconButton.styleFrom(
                  backgroundColor: _escaneandoConCamara
                      ? AppColors.error
                      : AppColors.inventoryGreen.withOpacity(0.1),
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 📊 Card de progreso total del escaneo
  /// 📋 Historial de registros
  // 📋 Construir historial mejorado de registros con botones +/- y alertas de excedente
  Widget _buildHistorialRegistrosMejorado() {
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
          const Row(
            children: [
              Icon(Icons.history, size: 20),
              SizedBox(width: 8),
              Text(
                'Historial de Últimos Registros',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Últimos 5 productos escaneados o registrados',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          if (_historialReciente.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Aún no hay registros. Comienza escaneando productos.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ..._historialReciente.map(
              (item) => _buildHistorialItemMejorado(item),
            ),
        ],
      ),
    );
  }

  // 🎨 Construir item de historial mejorado con control de cantidad y alertas
  Widget _buildHistorialItemMejorado(Map<String, dynamic> item) {
    final int cantidadActual = item['cantidad'] ?? 0;
    final int salRef = item['salRef'] ?? 0;
    final bool tieneExcedente = cantidadActual > salRef;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tieneExcedente ? Colors.red[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),

        border: Border.all(
          color: tieneExcedente ? Colors.red[300]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila superior: Código y botón eliminar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Código: ${item['codigo']}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Colors.red[400],
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () =>
                    _mostrarDialogoEliminarReferencia(context, item),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Nombre del producto
          Text(
            item['nombre'],
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Fila de cantidad con botones +/-
          Row(
            children: [
              // Botón menos
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: InkWell(
                  onTap: cantidadActual > 0
                      ? () => _mostrarDialogoDisminuirCantidad(
                          context,
                          item,
                          cantidadActual,
                        )
                      : null,
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.remove, size: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Cantidad con ratio (clickeable para editar)
              InkWell(
                onTap: () => _mostrarDialogoIngresarCantidad(
                  context,
                  item,
                  cantidadActual,
                  salRef,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: tieneExcedente ? Colors.red[100] : Colors.blue[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: tieneExcedente
                          ? Colors.red[300]!
                          : Colors.blue[300]!,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$cantidadActual / $salRef',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: tieneExcedente
                              ? Colors.red[700]
                              : Colors.blue[700],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.edit,
                        size: 14,
                        color: tieneExcedente
                            ? Colors.red[700]
                            : Colors.blue[700],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Botón más
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: InkWell(
                  onTap: () => _mostrarDialogoAumentarCantidad(
                    context,
                    item,
                    cantidadActual,
                    salRef,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.add, size: 18),
                  ),
                ),
              ),

              const Spacer(),

              // Icono de estado
              if (tieneExcedente)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red[700],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.warning,
                    color: Colors.white,
                    size: 18,
                  ),
                )
              else if (cantidadActual == salRef)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.inventoryGreen,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
            ],
          ),

          // Alerta de excedente
          if (tieneExcedente) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 16, color: Colors.red[700]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Excedente: ${cantidadActual - salRef} unidad(es)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Timestamp
          const SizedBox(height: 8),
          Text(
            'Registrado: ${item['timestamp'] ?? 'Ahora'}',
            style: const TextStyle(fontSize: 11, color: Colors.black38),
          ),
        ],
      ),
    );
  }

  // ⚠️ Mostrar diálogo de confirmación para disminuir cantidad
  /// 🗑️ Diálogo de confirmación para eliminar referencia
  Future<void> _mostrarDialogoEliminarReferencia(
    BuildContext context,
    Map<String, dynamic> item,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete_forever, color: AppColors.error),
            const SizedBox(width: 8),
            const Text('Eliminar Referencia'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Código: ${item['codigo']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Producto: ${item['nombre']}'),
            const SizedBox(height: 4),
            Text('Cantidad registrada: ${item['cantidad']}'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, color: AppColors.error, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '⚠️ Esta acción eliminará permanentemente este registro del inventario.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('SÍ, ELIMINAR'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        // Poner cantidad en 0 para eliminar el registro del historial
        final referenciaId = item['referenciaId'];
        if (referenciaId != null) {
          // Marcar cantidad como 0 (equivalente a eliminación lógica)
          await _driftService.actualizarCantidadEscaneada(referenciaId, 0);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🗑️ ${item['nombre']} eliminado del inventario'),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 2),
              ),
            );
          }

          // Recargar datos para actualizar indicadores y historial
          await _cargarDatosSesion();
        } else {
          // Si no tiene referenciaId, solo remover de la lista visual
          setState(() {
            _historialReciente.remove(item);
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error al eliminar: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  /// ✏️ Diálogo para ingresar cantidad manualmente
  Future<void> _mostrarDialogoIngresarCantidad(
    BuildContext context,
    Map<String, dynamic> item,
    int cantidadActual,
    int salRef,
  ) async {
    final TextEditingController cantidadController = TextEditingController(
      text: cantidadActual.toString(),
    );

    final nuevaCantidad = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit_note, color: AppColors.infoBlue),
            const SizedBox(width: 8),
            const Text('Ingresar Cantidad'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Producto: ${item['nombre']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Código: ${item['codigo']}'),
            const SizedBox(height: 4),
            Text(
              'Cantidad esperada (SAL_REF): $salRef',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: cantidadController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Nueva Cantidad',
                hintText: 'Ingrese la cantidad',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.numbers),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => cantidadController.clear(),
                ),
              ),
              onSubmitted: (value) {
                final cantidad = int.tryParse(value);
                if (cantidad != null && cantidad >= 0) {
                  Navigator.of(context).pop(cantidad);
                }
              },
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Presiona Enter o "GUARDAR" para confirmar',
                      style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              final cantidad = int.tryParse(cantidadController.text);
              if (cantidad != null && cantidad >= 0) {
                Navigator.of(context).pop(cantidad);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '⚠️ Ingrese una cantidad válida (número positivo)',
                    ),
                    backgroundColor: AppColors.warning,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.infoBlue,
            ),
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );

    if (nuevaCantidad != null && nuevaCantidad != cantidadActual) {
      // Validar si la nueva cantidad crea excedente
      final seraExcedente = nuevaCantidad > salRef;
      final excedente = seraExcedente ? nuevaCantidad - salRef : 0;

      // Mostrar confirmación si hay excedente
      if (seraExcedente) {
        final confirmar = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning_amber, color: AppColors.warning),
                const SizedBox(width: 8),
                const Text('Cantidad Excedida'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'La cantidad ingresada ($nuevaCantidad) supera el saldo de referencia ($salRef).',
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '⚠️ EXCEDENTE: $excedente unidades',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('CANCELAR'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                ),
                child: const Text('SÍ, REGISTRAR'),
              ),
            ],
          ),
        );

        if (confirmar != true) return;
      }

      // Actualizar cantidad en la base de datos
      setState(() {
        item['cantidad'] = nuevaCantidad;
      });
      await _actualizarCantidadReferencia(item['codigo'], nuevaCantidad);
    }
  }

  /// ➖ Diálogo de confirmación para disminuir cantidad
  Future<void> _mostrarDialogoDisminuirCantidad(
    BuildContext context,
    Map<String, dynamic> item,
    int cantidadActual,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.remove_circle_outline, color: AppColors.warning),
            const SizedBox(width: 8),
            const Text('Disminuir Cantidad'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Producto: ${item['nombre']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Cantidad actual: $cantidadActual'),
            Text('Nueva cantidad: ${cantidadActual - 1}'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '¿Está seguro que desea disminuir la cantidad ya registrada?',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('SÍ, DISMINUIR'),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      setState(() {
        item['cantidad'] = cantidadActual - 1;
      });
      await _actualizarCantidadReferencia(item['codigo'], cantidadActual - 1);
    }
  }

  // ⚠️ Mostrar diálogo de confirmación para aumentar cantidad
  Future<void> _mostrarDialogoAumentarCantidad(
    BuildContext context,
    Map<String, dynamic> item,
    int cantidadActual,
    int salRef,
  ) async {
    final nuevaCantidad = cantidadActual + 1;
    final seraExcedente = nuevaCantidad > salRef;
    final excedente = seraExcedente ? nuevaCantidad - salRef : 0;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              seraExcedente ? Icons.warning_amber : Icons.add_circle_outline,
              color: seraExcedente ? AppColors.error : AppColors.success,
            ),
            const SizedBox(width: 8),
            Text(seraExcedente ? 'Cantidad Excedida' : 'Aumentar Cantidad'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Producto: ${item['nombre']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Cantidad en inventario: $salRef'),
            Text('Cantidad actual: $cantidadActual'),
            Text('Nueva cantidad: $nuevaCantidad'),
            if (seraExcedente) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Excedente: $excedente unidad${excedente > 1 ? 'es' : ''}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '¿Desea registrar esta unidad adicional como sobrante?',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: seraExcedente
                  ? AppColors.error
                  : AppColors.success,
            ),
            child: Text(seraExcedente ? 'SÍ, REGISTRAR' : 'SÍ, AUMENTAR'),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      setState(() {
        item['cantidad'] = nuevaCantidad;
      });
      await _actualizarCantidadReferencia(item['codigo'], nuevaCantidad);
    }
  }

  // ✏️ Actualizar cantidad de referencia en BD después de ajuste manual
  Future<void> _actualizarCantidadReferencia(
    String codRef,
    int nuevaCantidad,
  ) async {
    try {
      final db = DriftService().database;

      // Buscar referencia en la sesión actual
      final sesionId = widget.sesion['id'] as String;
      final ref =
          await (db.select(db.referencias)
                ..where((r) => r.codRef.equals(codRef))
                ..where((r) => r.sesionId.equals(sesionId)))
              .getSingleOrNull();

      if (ref != null) {
        // Calcular excedente
        final excedente = nuevaCantidad > ref.salRef
            ? nuevaCantidad - ref.salRef
            : 0;
        final completado = nuevaCantidad >= ref.salRef;

        // Actualizar cantidad usando método de Drift
        await (db.update(
          db.referencias,
        )..where((r) => r.id.equals(ref.id))).write(
          ReferenciasCompanion(
            cantidadEscaneada: Value(nuevaCantidad),
            excedente: Value(excedente),
            completado: Value(completado),
            fechaUltimoEscaneo: Value(DateTime.now()),
          ),
        );

        // Recalcular indicadores
        await _cargarDatosSesion();
      }
    } catch (e) {
      debugPrint('Error al actualizar cantidad: $e');
    }
  }
}
