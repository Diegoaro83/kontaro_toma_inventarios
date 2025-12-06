import 'package:kontaro/database/drift_database.dart';
import 'package:drift/drift.dart' as drift;

///  📦 PANTALLA MAESTRA DE REFERENCIAS
///
/// Permite ver, importar, exportar y editar referencias maestras.
/// - Responsive: modal en desktop/tablet, integrado en móvil
/// - Importación y exportación Excel
/// - Filtros y búsqueda

import 'package:flutter/material.dart';
import '../../widgets/common/barra_superior_modulo.dart';
import '../../widgets/common/barra_inferior_modulo.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../models/referencia_maestra.dart';
import '../../services/drift_service.dart';

/// 📦 MAESTRA DE REFERENCIAS - UI BASE
///
/// Pantalla para consultar, importar/exportar y gestionar referencias maestras.
/// Incluye tabla, búsqueda, botones de importación/exportación y acciones CRUD.
/// 📦 MAESTRA DE REFERENCIAS - UI BASE
/// Ahora recibe nombreUsuario y nombrePerfil para mostrar el usuario actual
class MaestraReferenciasScreen extends StatefulWidget {
  final String nombreUsuario; // Nombre de usuario actual
  final String nombrePerfil; // Perfil/rol actual

  const MaestraReferenciasScreen({
    super.key,
    required this.nombreUsuario,
    required this.nombrePerfil,
  });

  @override
  State<MaestraReferenciasScreen> createState() =>
      _MaestraReferenciasScreenState();
}

class _MaestraReferenciasScreenState extends State<MaestraReferenciasScreen> {
  /// 🎨 Mostrar modal de edición de referencia
  void _mostrarModalEditarReferencia(ReferenciaMaestra ref) {
    final nombreController = TextEditingController(text: ref.nomRef);
    final valorController = TextEditingController(text: ref.valRef.toString());
    final cantidadController = TextEditingController(
      text: ref.salRef.toString(),
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Referencia'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: valorController,
                  decoration: const InputDecoration(labelText: 'Valor'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: cantidadController,
                  decoration: const InputDecoration(labelText: 'Cantidad'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Actualizar referencia en BD
                final actualizado = ReferenciasMaestrasCompanion(
                  codRef: drift.Value(ref.codRef),
                  nomRef: drift.Value(nombreController.text),
                  codTip: drift.Value(ref.codTip),
                  codPrv: drift.Value(ref.codPrv),
                  valRef: drift.Value(
                    (double.tryParse(valorController.text) ?? ref.valRef)
                        .toInt(),
                  ),
                  codEmp: drift.Value(ref.codEmp),
                  nomRef1: drift.Value(ref.nomRef1),
                  nomRef2: drift.Value(ref.nomRef2),
                  refPrv: drift.Value(ref.refPrv),
                  valRef1: drift.Value(ref.valRef1.toInt()),
                  codMar: drift.Value(ref.codMar),
                  vrunc: drift.Value(ref.vrunc.toInt()),
                  cos001: drift.Value(ref.cos001),
                  codBarra: drift.Value(ref.codBarra),
                  salRef: drift.Value(
                    int.tryParse(cantidadController.text) ?? ref.salRef,
                  ),
                  tallaDisp: drift.Value(ref.tallaDisp),
                  conRec: drift.Value(ref.conRec),
                  valLista1: drift.Value(ref.valLista1.toInt()),
                  valLista2: drift.Value(ref.valLista2.toInt()),
                  valLista3: drift.Value(ref.valLista3.toInt()),
                  activo: drift.Value(ref.activo),
                );
                await driftService.actualizarReferenciaMaestra(
                  ref.codRef,
                  actualizado,
                );
                await _buscarReferencias(_busquedaController.text);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Referencia actualizada')),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  /// 🚀 Servicio Drift para operaciones de BD
  final DriftService driftService = DriftService();
  // Secuencia y nombres de columnas igual al Excel original
  final List<String> columnasExcel = [
    'COD_REF',
    'NOM_REF',
    'COD_TIP',
    'COD_PRV',
    'VAL_REF',
    'COD_EMP',
    'NOM_REF1',
    'NOM_REF2',
    'REF_PRV',
    'VAL_REF1',
    'COD_MAR',
    'VRUNC',
    'COS_001',
    'COD_BARRA',
    'SAL_REF',
    'TALLA_DISP',
    'CON_REC',
    'VAL_LISTA1',
    'VAL_LISTA2',
    'VAL_LISTA3',
  ];

  /// 📦 Lista de referencias maestras usando el modelo manual
  /// Tipo correcto: List<ReferenciasMaestra> generado por Drift
  List<ReferenciaMaestra> referencias = [];

  /// 🔍 Controlador para el campo de búsqueda
  final TextEditingController _busquedaController = TextEditingController();

  /// 🔍 Buscar referencias en la base de datos según el texto ingresado
  Future<void> _buscarReferencias(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        referencias = [];
      });
      return;
    }
    final refs = await driftService.buscarReferencias(query);
    setState(() {
      referencias = refs;
    });
  }

  /// 📥 IMPORTAR REFERENCIAS DESDE EXCEL Y GUARDAR EN BD
  ///
  /// Permite seleccionar un archivo Excel (.xlsx), valida duplicados, actualiza la lista local y guarda todas las referencias en la base de datos Drift.
  /// - Reemplaza todas las referencias en la BD (borrado y carga nueva)
  Future<void> importarExcel() async {
    try {
      // ⚠️ Guardar contexto principal para SnackBar seguro
      final scaffoldContext = context;
      // 🎨 Mostrar modal de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            content: Row(
              children: const [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Cargando referencias...'),
              ],
            ),
          );
        },
      );

      // 📂 Seleccionar archivo Excel
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );
      if (result == null || result.files.isEmpty) {
        Navigator.of(context).pop(); // Cerrar modal
        return;
      }
      // Soporte para desktop: si bytes es null, leer por path
      Uint8List? fileBytes = result.files.first.bytes;
      if (fileBytes == null) {
        final path = result.files.first.path;
        if (path == null) {
          Navigator.of(context).pop();
          return;
        }
        fileBytes = File(path).readAsBytesSync();
      }

      final excel = Excel.decodeBytes(fileBytes);
      final hoja = excel.tables.keys.first;
      final rows = excel.tables[hoja]?.rows ?? [];
      // 🐞 Depuración: imprimir filas leídas
      print('--- FILAS LEÍDAS DEL EXCEL ---');
      for (var i = 0; i < rows.length; i++) {
        print(
          'Fila $i: ' +
              rows[i].map((c) => c?.value?.toString() ?? '').join(' | '),
        );
      }

      /// 📥 Importar referencias desde Excel y mapear a modelo Dart
      List<ReferenciaMaestra> nuevasReferencias = [];
      Set<String> codigos = {};
      int total = rows.length - 1;
      int ignoradasVacias = 0;
      int ignoradasDuplicadas = 0;
      for (var row in rows.skip(1)) {
        final codRef = row[0]?.value?.toString() ?? '';
        if (codRef.isEmpty) {
          ignoradasVacias++;
          continue;
        }
        if (codigos.contains(codRef)) {
          ignoradasDuplicadas++;
          continue;
        }
        codigos.add(codRef);
        final codBarraRaw = row[13]?.value?.toString() ?? '';
        nuevasReferencias.add(
          ReferenciaMaestra(
            codRef: codRef,
            nomRef: row[1]?.value?.toString() ?? '',
            codTip: row[2]?.value?.toString() ?? '',
            codPrv: row[3]?.value?.toString() ?? '',
            valRef: (double.tryParse(row[4]?.value?.toString() ?? '0') ?? 0),
            codEmp: row[5]?.value?.toString() ?? '',
            nomRef1: row[6]?.value?.toString() ?? '',
            nomRef2: row[7]?.value?.toString() ?? '',
            refPrv: row[8]?.value?.toString() ?? '',
            valRef1: (double.tryParse(row[9]?.value?.toString() ?? '0') ?? 0),
            codMar: row[10]?.value?.toString() ?? '',
            vrunc: (double.tryParse(row[11]?.value?.toString() ?? '0') ?? 0),
            cos001: row[12]?.value?.toString() ?? '',
            codBarra: codBarraRaw.isEmpty ? null : codBarraRaw,
            salRef: int.tryParse(row[14]?.value?.toString() ?? '0') ?? 0,
            tallaDisp: row[15]?.value?.toString() ?? '',
            conRec: row[16]?.value?.toString() ?? '',
            valLista1:
                (double.tryParse(row[17]?.value?.toString() ?? '0') ?? 0),
            valLista2:
                (double.tryParse(row[18]?.value?.toString() ?? '0') ?? 0),
            valLista3:
                (double.tryParse(row[19]?.value?.toString() ?? '0') ?? 0),
            activo: true,
          ),
        );
      }

      // 🗑️ Borrar todas las referencias previas en la BD
      await driftService.eliminarTodasReferenciasMaestras();
      // ✅ Guardar todas las nuevas referencias en la BD
      for (final ref in nuevasReferencias) {
        await driftService.insertarReferenciaMaestra(ref);
      }

      // ⚠️ Después de importar, recargar desde la BD para reflejar cambios
      await _buscarReferencias(_busquedaController.text);
      Navigator.of(context).pop(); // Cerrar modal de carga
      if (nuevasReferencias.isNotEmpty) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Cargue exitoso: ${nuevasReferencias.length} referencias importadas de $total filas.\nIgnoradas vacías: $ignoradasVacias\nIgnoradas duplicadas: $ignoradasDuplicadas',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text(
              '⚠️ No se pudo cargar ninguna referencia.\nIgnoradas vacías: $ignoradasVacias\nIgnoradas duplicadas: $ignoradasDuplicadas\nVerifica que la columna COD_REF no esté vacía ni repetida y que los valores numéricos sean correctos.',
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Cerrar modal si hay error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al importar: $e')));
    }
  }

  /// 📤 EXPORTAR REFERENCIAS DESDE LA BASE DE DATOS A EXCEL
  ///
  /// Genera un archivo Excel (.xlsx) con todas las referencias guardadas en la base de datos Drift y permite guardarlo en el dispositivo.
  Future<void> exportarExcel() async {
    try {
      // 🔍 Obtener todas las referencias desde la BD
      final referenciasBD = await driftService
          .obtenerTodasReferenciasMaestras();
      final excel = Excel.createExcel();
      final hoja = excel['Referencias'];
      // Agregar encabezados
      hoja.appendRow(columnasExcel.map((col) => TextCellValue(col)).toList());
      // Agregar filas de datos
      for (final ref in referenciasBD) {
        hoja.appendRow([
          TextCellValue(ref.codRef.toString()),
          TextCellValue(ref.nomRef.toString()),
          TextCellValue(ref.codTip.toString()),
          TextCellValue(ref.codPrv.toString()),
          TextCellValue(ref.valRef.toString()),
          TextCellValue(ref.codEmp.toString()),
          TextCellValue(ref.nomRef1.toString()),
          TextCellValue(ref.nomRef2.toString()),
          TextCellValue(ref.refPrv.toString()),
          TextCellValue(ref.valRef1.toString()),
          TextCellValue(ref.codMar.toString()),
          TextCellValue(ref.vrunc.toString()),
          TextCellValue(ref.cos001.toString()),
          TextCellValue(ref.codBarra.toString()),
          TextCellValue(ref.salRef.toString()),
          TextCellValue(ref.tallaDisp.toString()),
          TextCellValue(ref.conRec.toString()),
          TextCellValue(ref.valLista1.toString()),
          TextCellValue(ref.valLista2.toString()),
          TextCellValue(ref.valLista3.toString()),
        ]);
      }
      // Guardar archivo en dispositivo (solo desktop soportado)
      final bytes = excel.encode();
      if (bytes == null) throw Exception('No se pudo generar el archivo Excel');
      // Permitir elegir ubicación si es desktop
      String? filePath;
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final result = await FilePicker.platform.saveFile(
          dialogTitle: 'Guardar archivo Excel',
          fileName: 'referencias_exportadas.xlsx',
        );
        filePath = result ?? 'referencias_exportadas.xlsx';
      } else {
        filePath = 'referencias_exportadas.xlsx';
      }
      try {
        final file = File(filePath);
        await file.writeAsBytes(bytes, flush: true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Archivo exportado correctamente en:\n$filePath\nPuedes editarlo y luego importarlo para actualizar la maestra.',
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar archivo: $e')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al exportar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    // Solo mostrar resultados si hay búsqueda
    final referenciasFiltradas = referencias;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            BarraSuperiorModulo(
              nombreEmpresa: 'Oxígeno Zero Grados',
              subtitulo: 'Maestra de Referencias',
              nombreUsuario: widget.nombreUsuario, // Ahora dinámico
              nombrePerfil: widget.nombrePerfil, // Ahora dinámico
              estadoSistema: 'Activo',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        /// 🔍 Campo de búsqueda que consulta la BD en cada cambio
                        TextField(
                          controller: _busquedaController,
                          decoration: InputDecoration(
                            hintText: 'Buscar referencia...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          onChanged: (v) {
                            _buscarReferencias(v);
                          },
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: importarExcel, // Importar Excel
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Importar Excel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF06B6D4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: exportarExcel, // Exportar Excel
                          icon: const Icon(Icons.download),
                          label: const Text('Exportar Excel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2B7FFF),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {}, // TODO: Crear referencia manual
                          icon: const Icon(Icons.add),
                          label: const Text('Nueva Referencia'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _busquedaController,
                            decoration: InputDecoration(
                              hintText: 'Buscar referencia...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onChanged: (v) {
                              _buscarReferencias(v);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: importarExcel, // Importar Excel
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Importar Excel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF06B6D4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: exportarExcel, // Exportar Excel
                          icon: const Icon(Icons.download),
                          label: const Text('Exportar Excel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2B7FFF),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {}, // TODO: Crear referencia manual
                          icon: const Icon(Icons.add),
                          label: const Text('Nueva Referencia'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: referenciasFiltradas.isEmpty
                      ? const Center(
                          child: Text(
                            'Busca una referencia para ver resultados',
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: DataTable(
                              dataRowMinHeight: 13,
                              dataRowMaxHeight: 15,
                              headingRowHeight: 15,
                              columnSpacing: 2,
                              columns: [
                                ...columnasExcel.map(
                                  (col) => DataColumn(
                                    label: Text(
                                      col,
                                      style: const TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const DataColumn(
                                  label: Text(
                                    'Acciones',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],

                              /// 🎨 Renderizar tabla compacta y scrollable usando modelo Dart
                              rows: referenciasFiltradas.map((ref) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        child: Text(
                                          ref.codRef,
                                          style: const TextStyle(fontSize: 9),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        child: Text(
                                          ref.nomRef,
                                          style: const TextStyle(fontSize: 9),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        child: Text(
                                          ref.codTip,
                                          style: const TextStyle(fontSize: 9),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        child: Text(
                                          ref.codPrv,
                                          style: const TextStyle(fontSize: 9),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        child: Text(
                                          ref.valRef.toString(),
                                          style: const TextStyle(fontSize: 9),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        child: Text(
                                          ref.codEmp,
                                          style: const TextStyle(fontSize: 9),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        child: Text(
                                          ref.nomRef1,
                                          style: const TextStyle(fontSize: 9),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        child: Text(
                                          ref.nomRef2,
                                          style: const TextStyle(fontSize: 9),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        child: Text(
                                          ref.refPrv,
                                          style: const TextStyle(fontSize: 9),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        child: Text(
                                          ref.valRef1.toString(),
                                          style: const TextStyle(fontSize: 9),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        child: Text(
                                          ref.codMar,
                                          style: const TextStyle(fontSize: 9),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        child: Text(
                                          ref.vrunc.toString(),
                                          style: const TextStyle(fontSize: 9),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        child: Text(
                                          ref.cos001,
                                          style: const TextStyle(fontSize: 9),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        child: Text(
                                          ref.codBarra ?? '-',
                                          style: const TextStyle(fontSize: 9),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        child: Text(
                                          ref.salRef.toString(),
                                          style: const TextStyle(fontSize: 9),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        child: Text(
                                          ref.tallaDisp,
                                          style: const TextStyle(fontSize: 9),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        child: Text(
                                          ref.conRec,
                                          style: const TextStyle(fontSize: 9),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        child: Text(
                                          ref.valLista1.toString(),
                                          style: const TextStyle(fontSize: 9),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        child: Text(
                                          ref.valLista2.toString(),
                                          style: const TextStyle(fontSize: 9),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        child: Text(
                                          ref.valLista3.toString(),
                                          style: const TextStyle(fontSize: 9),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Color(0xFF3B82F6),
                                              size: 16,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () =>
                                                _mostrarModalEditarReferencia(
                                                  ref,
                                                ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Color(0xFFEF4444),
                                              size: 16,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed:
                                                () {}, // TODO: Eliminar referencia
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                ),
              ),
            ),
            BarraInferiorModulo(
              estadoSistema: 'Sistema activo',
              ultimaSincronizacion: 'hace 2 min',
              onVolver: () => Navigator.pop(context),
              onSalir: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}
