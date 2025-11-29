/// 📦 PANTALLA MAESTRA DE REFERENCIAS
///
/// Permite ver, importar, exportar y editar referencias maestras.
/// - Responsive: modal en desktop/tablet, integrado en móvil
/// - Importación y exportación Excel
/// - Filtros y búsqueda

import 'package:flutter/material.dart';

class MaestraReferenciasScreen extends StatelessWidget {
  const MaestraReferenciasScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 📱 Detectar si es móvil o desktop
    final isMobile = MediaQuery.of(context).size.width < 900;
    return Scaffold(
      appBar: AppBar(title: const Text('Maestra de Referencias')),
      body: Center(child: Text('Aquí irá la tabla, importación y formulario.')),
    );
  }
}
