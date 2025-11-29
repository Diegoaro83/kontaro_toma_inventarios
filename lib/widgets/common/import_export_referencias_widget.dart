/// 📤 WIDGET DE IMPORTACIÓN/EXPORTACIÓN DE REFERENCIAS
///
/// Permite seleccionar archivo Excel/CSV para importar referencias maestras
/// y exportar la tabla actual a Excel.
/// - Muestra preview del archivo
/// - Llama a métodos de DriftService

import 'package:flutter/material.dart';

class ImportExportReferenciasWidget extends StatelessWidget {
  const ImportExportReferenciasWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // TODO: Implementar importación
          },
          child: const Text('Importar desde Excel/CSV'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Implementar exportación
          },
          child: const Text('Exportar a Excel'),
        ),
      ],
    );
  }
}
