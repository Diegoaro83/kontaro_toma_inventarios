/// 💰 UTILIDADES DE FORMATO DE MONEDA
///
/// Helpers para formatear valores monetarios en pesos colombianos ($)
/// con separadores de miles usando puntos (.)
///
/// Ejemplos:
/// - formatCurrency(1234567) → "\$1.234.567"
/// - formatCurrency(5000) → "\$5.000"
/// - formatCurrency(999) → "\$999"

/// 💵 Formatear valor en pesos colombianos
///
/// Parámetros:
/// - valor: Valor numérico a formatear (puede ser double o int)
///
/// Retorna: String formateado con símbolo $ y separadores de miles con punto
String formatCurrency(num valor) {
  // Redondear a entero
  final valorEntero = valor.round();

  // Convertir a string
  final valorStr = valorEntero.toString();

  // Si es negativo, guardar el signo
  final esNegativo = valorEntero < 0;
  final valorAbsoluto = esNegativo ? valorStr.substring(1) : valorStr;

  // Agregar separadores de miles
  final buffer = StringBuffer();
  var contador = 0;

  // Recorrer de derecha a izquierda
  for (var i = valorAbsoluto.length - 1; i >= 0; i--) {
    if (contador == 3) {
      buffer.write('.');
      contador = 0;
    }
    buffer.write(valorAbsoluto[i]);
    contador++;
  }

  // Invertir el string
  final valorFormateado = buffer.toString().split('').reversed.join();

  // Retornar con símbolo de pesos y signo negativo si aplica
  return esNegativo ? '-\$$valorFormateado' : '\$$valorFormateado';
}

/// 💸 Formatear valor compacto (para espacios reducidos)
///
/// Usa sufijos M (millones) y K (miles) para valores grandes
///
/// Ejemplos:
/// - formatCurrencyCompact(1500000) → "\$1.5M"
/// - formatCurrencyCompact(50000) → "\$50K"
/// - formatCurrencyCompact(999) → "\$999"
String formatCurrencyCompact(num valor) {
  final valorDouble = valor.toDouble();

  if (valorDouble >= 1000000) {
    // Millones
    final millones = (valorDouble / 1000000).toStringAsFixed(1);
    return '\$${millones}M';
  } else if (valorDouble >= 1000) {
    // Miles
    final miles = (valorDouble / 1000).round();
    return '\$${miles}K';
  }

  // Menor a 1000, usar formato normal
  return formatCurrency(valor);
}
