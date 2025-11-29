import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/painting.dart' as painting;
import 'package:drift/drift.dart' hide Column;
import '../../theme/app_colors.dart';
import '../../services/drift_service.dart';
import '../../database/drift_database.dart';
import '../../widgets/indicadores_inventario_widget.dart';
import '../../widgets/panel_tallas_widget.dart';
import '../../utils/currency_formatter.dart';

/// 📱 PANTALLA DE ESCANEO DE INVENTARIO
///
/// Pantalla para escanear códigos de barras y registrar productos
/// Muestra:
/// - Progreso total del inventario
/// - Valor total acumulado
/// - Referencias escaneadas
/// - Campo de escaneo manual/cámara
/// - Historial de últimos 5 registros

class EscaneoInventarioScreen extends StatefulWidget {
  final Map<String, dynamic> sesion;

  const EscaneoInventarioScreen({super.key, required this.sesion});

  @override
  State<EscaneoInventarioScreen> createState() =>
      _EscaneoInventarioScreenState();
}

class _EscaneoInventarioScreenState extends State<EscaneoInventarioScreen> {
  final DriftService _driftService = DriftService();
  final TextEditingController _codigoBarrasController = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController();

  // Estado
  bool _escaneandoConCamara = false;
  int _pestanaActual = 0; // 0: Escaneo, 1: Resumen, 2: Lista
  Map<String, dynamic> _indicadores = {}; // Indicadores calculados
  List<Map<String, dynamic>> _historialReciente = [];
  Referencia? _referenciaSeleccionada; // Referencia actual para panel de tallas

  @override
  void initState() {
    super.initState();
    _cargarDatosSesion();
  }

  @override
  void dispose() {
    _codigoBarrasController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  /// 🔄 Cargar datos de la sesión actual y calcular indicadores
  Future<void> _cargarDatosSesion() async {
    try {
      final sesionId = widget.sesion['id'];

      // 🧹 Limpiar tabla obsoleta de ReferenciasNoEncontradas
      // (ahora todos los productos van directo a Referencias)
      await _driftService.eliminarReferenciasNoEncontradasDeSesion(sesionId);

      // Calcular todos los indicadores usando el método del servicio
      final indicadores = await _driftService.calcularIndicadoresInventario(
        sesionId,
      );

      // Cargar historial reciente (últimos 10 escaneos)
      final referencias = await _driftService.obtenerReferenciasPorSesion(
        sesionId,
      );
      final historial = <Map<String, dynamic>>[];

      for (var ref in referencias) {
        if (ref.cantidadEscaneada > 0) {
          historial.add({
            'codigo': ref.codRef,
            'nombre': ref.nomRef,
            'cantidad': ref.cantidadEscaneada,
            'salRef': ref.salRef,
            'excedente': ref.excedente,
            'completado': ref.completado,
            'referenciaId': ref.id,
            'timestamp':
                ref.fechaUltimoEscaneo?.toString() ??
                ref.fechaPrimerEscaneo?.toString() ??
                'Ahora',
          });
        }
      }

      // Ordenar por fecha más reciente y tomar solo los últimos 5
      historial.sort((a, b) {
        final fechaA = a['timestamp'] as String;
        final fechaB = b['timestamp'] as String;
        return fechaB.compareTo(fechaA);
      });

      setState(() {
        _indicadores = indicadores;
        _historialReciente = historial.take(5).toList();
      });
    } catch (e) {
      print('❌ Error al cargar datos: $e');
    }
  }

  /// 📷 Alternar modo de escaneo (manual/cámara)
  void _toggleEscaneo() {
    setState(() {
      _escaneandoConCamara = !_escaneandoConCamara;
    });
  }

  /// 🔍 Procesar código escaneado (LÓGICA COMPLETA DE VALIDACIÓN)
  Future<void> _procesarCodigoEscaneado(String codigo) async {
    if (codigo.trim().isEmpty) return;

    final sesionId = widget.sesion['id'];

    try {
      // 🔍 PASO 1: Buscar en referencias del inventario actual
      final referencia = await _driftService.buscarReferenciaPorCodigo(
        sesionId,
        codigo,
      );

      if (referencia != null) {
        // ✅ PRODUCTO ENCONTRADO EN INVENTARIO
        await _procesarProductoEncontrado(referencia);
      } else {
        // ❌ PRODUCTO NO ENCONTRADO - Buscar en BD maestra
        await _procesarProductoNoEncontrado(codigo);
      }

      // Limpiar campo
      _codigoBarrasController.clear();
    } catch (e) {
      print('❌ Error al procesar código: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// ✅ Procesar producto que SÍ está en el inventario
  Future<void> _procesarProductoEncontrado(Referencia referencia) async {
    final nuevaCantidad = referencia.cantidadEscaneada + 1;

    // 🚨 VALIDACIÓN: ¿Se excede la cantidad del Excel?
    if (nuevaCantidad > referencia.salRef) {
      // Mostrar diálogo de confirmación de excedente
      final aceptar = await _mostrarDialogoExcedente(
        referencia.codRef,
        referencia.nomRef,
        referencia.salRef,
        nuevaCantidad,
      );

      if (aceptar == true) {
        // Registrar excedente
        final excedente = nuevaCantidad - referencia.salRef;
        await _driftService.registrarExcedente(referencia.id, excedente);
        await _driftService.actualizarCantidadEscaneada(
          referencia.id,
          nuevaCantidad,
        );

        // Mostrar confirmación
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '⚠️ Excedente registrado: ${referencia.nomRef} (+$excedente)',
              ),
              backgroundColor: AppColors.warning,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Usuario canceló, no registrar
        return;
      }
    } else {
      // ✅ Cantidad dentro del rango, registrar normalmente
      await _driftService.actualizarCantidadEscaneada(
        referencia.id,
        nuevaCantidad,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ ${referencia.nomRef} - $nuevaCantidad/${referencia.salRef}',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    // Actualizar referencia seleccionada para panel de tallas
    setState(() => _referenciaSeleccionada = referencia);

    // Recargar datos
    await _cargarDatosSesion();
  }

  /// ❌ Procesar producto que NO está en el inventario
  Future<void> _procesarProductoNoEncontrado(String codigo) async {
    // 🔍 Buscar en BD maestra
    final referenciaMaestra = await _driftService
        .buscarReferenciaMaestraPorCodigo(codigo);

    if (referenciaMaestra != null) {
      // 🎯 Encontrado en BD maestra
      await _mostrarDialogoAgregarAlInventario(codigo, referenciaMaestra);
    } else {
      // 🤷 No existe en ninguna BD - Ingreso manual
      await _mostrarDialogoIngresoManual(codigo);
    }
  }

  /// 🚨 Diálogo de confirmación de excedente
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
              const Expanded(child: Text('Cantidad Excedida')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Referencia: $codigo',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(nombre, style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cantidad en inventario: $cantidadEsperada'),
                    Text('Ya escaneadas: ${cantidadActual - 1}'),
                    const SizedBox(height: 8),
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
              const SizedBox(height: 16),
              const Text(
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
              child: const Text('ACEPTAR'),
            ),
          ],
        );
      },
    );
  }

  /// ➕ Diálogo para agregar producto al inventario local
  Future<void> _mostrarDialogoAgregarAlInventario(
    String codigo,
    ReferenciasMaestra referenciaMaestra,
  ) async {
    final agregar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.add_shopping_cart,
                color: AppColors.infoBlue,
                size: 32,
              ),
              const SizedBox(width: 12),
              const Expanded(child: Text('Agregar al Inventario')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.infoBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Código: $codigo',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(referenciaMaestra.nomRef),
                    const SizedBox(height: 8),
                    Text(
                      'Valor sugerido: ${formatCurrency(referenciaMaestra.valorSugerido ?? 0.0)}',
                    ),
                    Text('Categoría: ${referenciaMaestra.categoria ?? "N/A"}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '✅ Producto encontrado en base de datos maestra',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '¿Agregar este producto al inventario del local "${widget.sesion['nombreLocal']}"?',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('NO'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
              child: const Text('SÍ, AGREGAR'),
            ),
          ],
        );
      },
    );

    if (agregar == true) {
      // 🔄 Agregar directamente a la tabla Referencias (inventario principal)
      final sesionId = widget.sesion['id'];

      // Generar ID único para la nueva referencia
      final count = await _driftService.contarReferenciasEnSesion(sesionId);
      final id = '$sesionId-ref-${(count + 1).toString().padLeft(4, "0")}';

      // Crear la nueva referencia en el inventario principal usando crearReferencia básico
      await _driftService.crearReferencia(
        id: id,
        sesionId: sesionId,
        codRef: codigo,
        nomRef: referenciaMaestra.nomRef,
        salRef: 0, // No tiene saldo inicial porque es nuevo
        valRef: referenciaMaestra.valorSugerido ?? 0.0,
        valTotal: referenciaMaestra.valorSugerido ?? 0.0,
      );

      // ✅ Actualizar cantidad escaneada a 1 (CRÍTICO para que aparezca en historial)
      await _driftService.actualizarCantidadEscaneada(id, 1);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '➕ ${referenciaMaestra.nomRef} agregado al inventario (EXCEDENTE)',
            ),
            backgroundColor: AppColors.warning,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Recargar datos completos para actualizar indicadores Y el historial
      await _cargarDatosSesion();
    }
  }

  /// ✏️ Diálogo para ingreso manual de producto no encontrado
  Future<void> _mostrarDialogoIngresoManual(String codigo) async {
    final TextEditingController nombreController = TextEditingController();
    final TextEditingController valorController = TextEditingController();

    final ingresar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 32),
              const SizedBox(width: 12),
              const Expanded(child: Text('Código No Registrado')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Código: $codigo',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '❌ Este código no está en el inventario ni en la base de datos maestra.',
                  style: TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ingrese los datos manualmente:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción del producto',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: valorController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Valor unitario',
                    border: OutlineInputBorder(),
                    prefixText: '\$ ',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.infoBlue,
              ),
              child: const Text('GUARDAR'),
            ),
          ],
        );
      },
    );

    if (ingresar == true && nombreController.text.isNotEmpty) {
      final valor = double.tryParse(valorController.text) ?? 0.0;

      // Crear referencia no encontrada con datos manuales
      final sesionId = widget.sesion['id'];
      final count = await _driftService.contarReferenciasNoEncontradas(
        sesionId,
      );
      final id =
          '$sesionId-noencontrada-${(count + 1).toString().padLeft(4, "0")}';

      await _driftService.crearReferenciaNoEncontrada(
        id: id,
        sesionId: sesionId,
        codRef: codigo,
        nomRef: nombreController.text,
        cantidadEscaneada: 1,
        valRef: valor,
        valTotal: valor,
        agregadoAInventario: false,
        encontradoEnMaestra: false,
        observaciones: 'Ingreso manual durante inventario',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📝 ${nombreController.text} registrado manualmente'),
            backgroundColor: AppColors.infoBlue,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      await _cargarDatosSesion();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          height: 80,
          decoration: const BoxDecoration(
            color: Color(0xFF1A2332),
            border: Border(
              bottom: BorderSide(color: Color(0xFF1E293B), width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Oxígeno Zero Grados',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Toma de Inventario',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Diego',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Auditor',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFF3B82F6),
                child: Text(
                  'D',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A1628), Color(0xFF1A2845), Color(0xFF0D1B2E)],
            stops: [0.0, 0.5, 1.0],
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
            // Footer inferior con estado del sistema
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0B1A2E),
                border: Border(
                  top: BorderSide(color: Color(0xFF1E293B), width: 1),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF3B82F6), size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Estado del sistema',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Última sincronización: No sincronizado',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
          border: painting.Border.all(
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
              tallasDisponiblesJson: _referenciaSeleccionada!.tallasDisponibles,
              tallasEscaneadasJson: _referenciaSeleccionada!.tallasEscaneadas,
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
          if (_indicadores.isNotEmpty) ...[
            IndicadoresInventarioWidget(indicadores: _indicadores),
          ],
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
                  onSubmitted: _procesarCodigoEscaneado,
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
        border: painting.Border.all(
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
                  border: painting.Border.all(color: Colors.grey[300]!),
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
                    border: painting.Border.all(
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
                  border: painting.Border.all(color: Colors.grey[300]!),
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
