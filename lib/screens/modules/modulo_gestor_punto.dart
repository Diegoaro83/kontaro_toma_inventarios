import '../../widgets/common/barra_superior_modulo.dart';
import '../../widgets/common/barra_inferior_modulo.dart';
import 'package:flutter/material.dart';
import 'modulo_base.dart';

/// 🏪 MÓDULO GESTOR DE PUNTO
/// Pantalla para el rol Gestor de Punto usando la estructura visual estándar.
class ModuloGestorPunto extends StatelessWidget {
  const ModuloGestorPunto({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModuloBaseScreen(
      tituloModulo: 'Selecciona un módulo',
      barraSuperior: BarraSuperiorModulo(
        nombreEmpresa: 'Oxígeno Zero Grados',
        subtitulo: 'Panel de Módulo',
        nombreUsuario: 'Usuario Demo',
        nombrePerfil: 'Gestor de Punto',
        estadoSistema: 'Activo',
        avatarUrl: null,
      ),
      barraInferior: BarraInferiorModulo(
        estadoSistema: 'Activo',
        ultimaSincronizacion: 'Hace 2 min',
        onVolver: () {
          Navigator.of(context).pop();
        },
        onSalir: () {
          Navigator.of(context).pushReplacementNamed('/login');
        },
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gestión de inventarios, ventas y reportes para puntos de venta.',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 420,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.point_of_sale,
                              color: Color(0xFF8200DB),
                              size: 40,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Punto de Venta',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('Gestión de ventas y cobros'),
                            SizedBox(height: 12),
                            Text(
                              'Abrir módulo →',
                              style: TextStyle(
                                color: Color(0xFF8200DB),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 24),
                  Flexible(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.inventory,
                              color: Color(0xFF00BC7D),
                              size: 40,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Inventarios',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('Toma y gestión de inventarios'),
                            SizedBox(height: 12),
                            Text(
                              'Abrir módulo →',
                              style: TextStyle(
                                color: Color(0xFF00BC7D),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
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
}
