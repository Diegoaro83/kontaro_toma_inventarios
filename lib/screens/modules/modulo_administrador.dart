import '../../widgets/common/barra_superior_modulo.dart';
import '../../widgets/common/barra_inferior_modulo.dart';
import 'package:flutter/material.dart';
import 'modulo_base.dart';

/// 🛡️ MÓDULO ADMINISTRADOR
///
/// Pantalla personalizada para el rol Administrador.
/// - Acceso a módulos administrativos y reportes
/// - Botón de regreso al selector de módulos
class ModuloAdministrador extends StatelessWidget {
  const ModuloAdministrador({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModuloBaseScreen(
      tituloModulo: 'Selecciona un módulo',
      barraSuperior: BarraSuperiorModulo(
        nombreEmpresa: 'Oxígeno Zero Grados',
        subtitulo: 'Panel de Módulo',
        nombreUsuario: 'Diego',
        nombrePerfil: 'Administrador',
        estadoSistema: 'No sincronizado',
        avatarUrl: null,
      ),
      barraInferior: BarraInferiorModulo(
        estadoSistema: 'No sincronizado',
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
              'Accede a módulos de gestión, reportes y administración.',
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
                              Icons.report,
                              color: Color(0xFF8200DB),
                              size: 40,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Reportes',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('Ver y exportar reportes'),
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
                              Icons.settings,
                              color: Color(0xFF2B7FFF),
                              size: 40,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Configuración',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('Ajustes y administración general'),
                            SizedBox(height: 12),
                            Text(
                              'Abrir módulo →',
                              style: TextStyle(
                                color: Color(0xFF2B7FFF),
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
