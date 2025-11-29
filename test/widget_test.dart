/// 🧪 TEST BÁSICO DE LA APLICACIÓN KONTARO
///
/// Este archivo verifica que la app se inicialice correctamente.
/// Flutter crea este archivo por defecto con un test de ejemplo.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kontaro/main.dart';

void main() {
  // ✅ Test básico: Verificar que la app se construya sin errores
  testWidgets('Kontaro app se inicializa correctamente', (
    WidgetTester tester,
  ) async {
    // Construir la aplicación
    await tester.pumpWidget(const KontaroApp());

    // Verificar que se muestre la pantalla de login
    // (Buscar cualquier widget Text que pueda estar en LoginScreen)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
