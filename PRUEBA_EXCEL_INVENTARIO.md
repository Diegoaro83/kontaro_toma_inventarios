# Archivo Excel de Prueba para Importar Inventario

## Estructura Requerida

### Columnas Mínimas (Obligatorias):
1. **codigo interno** - Código interno del producto (ej: "PROD-001")
2. **COD_REF** - Código de referencia (ej: "REF-001")
3. **NOM_REF** - Nombre del producto (ej: "Camisa Polo Azul")
4. **TOTAL** - Cantidad inicial (ej: 25)

### Columnas Adicionales (Opcionales):
5. **Marca** - Marca del producto
6. **INTERPRETE** - Intérprete/artista relacionado
7. **Valorizado** - Valor total del inventario
8. **VAL_Mayor** - Precio mayorista
9. **VAL_VENT** - Precio venta
10. **VAL_VENT META** - Precio meta
11. **FEC_CREA** - Fecha de creación
12. **contenedor** - Ubicación física
13. **IND_IVA** - Indica si tiene IVA (true/false, sí/no, 1/0)
14. **campo libre 1** - Campo personalizable 1
15. **campo libre 2** - Campo personalizable 2
16. **campo libre 3** - Campo personalizable 3
17. **Código de barras** - Código de barras del producto

## Ejemplo de Excel Válido

| codigo interno | COD_REF | NOM_REF | TOTAL | Marca | INTERPRETE | Valorizado | VAL_Mayor | VAL_VENT | VAL_VENT META | FEC_CREA | contenedor | IND_IVA | campo libre 1 | campo libre 2 | campo libre 3 | Código de barras |
|----------------|---------|---------|-------|-------|------------|------------|-----------|----------|---------------|----------|------------|---------|---------------|---------------|---------------|------------------|
| PROD-001 | REF-001 | Camisa Polo Azul | 25 | Lacoste | | 750000 | 25000 | 30000 | 35000 | 2024-01-15 | Estante A1 | sí | Temporada Verano | | | 7891234567890 |
| PROD-002 | REF-002 | Pantalón Jean Negro | 15 | Levi's | | 450000 | 28000 | 35000 | 40000 | 2024-01-16 | Estante B2 | true | Temporada Otoño | Talla 32 | | 7891234567891 |
| PROD-003 | REF-003 | Zapatos Deportivos | 10 | Nike | | 800000 | 75000 | 90000 | 95000 | 2024-01-17 | Estante C3 | 1 | | Talla 42 | Color Blanco | 7891234567892 |

## Notas Importantes

1. **Validación de Columnas**: El sistema verifica que existan las 4 columnas obligatorias (case-insensitive)
2. **Mínimo de Filas**: Debe haber al menos 1 fila de datos (además del header)
3. **Formato de Fechas**: ISO 8601 (YYYY-MM-DD) o formato Excel estándar
4. **IND_IVA**: Acepta múltiples formatos: "true", "sí", "si", "1" (case-insensitive)
5. **Valores Numéricos**: int o double según el campo
6. **Valores Opcionales**: Celdas vacías se guardan como NULL en la BD

## Proceso de Importación

1. Usuario abre diálogo "Crear Nueva Sesión"
2. Ingresa nombre de sesión (ej: "Inventario Diciembre 2025")
3. Click en "Seleccionar Archivo" → Elige Excel (.xlsx o .xls)
4. Sistema valida:
   - Archivo no vacío
   - Tiene al menos 2 filas (header + 1 dato)
   - Contiene las 4 columnas obligatorias
5. Si válido:
   - Muestra "✅ Excel validado: X referencias encontradas"
   - Botón cambia a "Crear con Excel (X refs)" (verde)
6. Click en "Crear con Excel":
   - Genera ID sesión autoincremental (sesion-001, sesion-002...)
   - Re-lee Excel y mapea todas las columnas
   - Crea sesión en BD con totalReferencias = X
   - Inserta referencias en batch (ReferenciasCompanion)
   - Cierra diálogo con "✅ Sesión creada: X referencias importadas"

## Testing Checklist

- [ ] Crear Excel con solo columnas obligatorias
- [ ] Crear Excel con todas las columnas
- [ ] Validar error si falta columna obligatoria
- [ ] Validar error si Excel está vacío
- [ ] Validar error si solo tiene header sin datos
- [ ] Probar con nombres de columnas en mayúsculas/minúsculas mezcladas
- [ ] Verificar que IND_IVA acepta "true", "sí", "si", "1"
- [ ] Verificar que valores numéricos se parsean correctamente
- [ ] Verificar que fechas se parsean correctamente
- [ ] Verificar overlay de loading se muestra durante importación
- [ ] Verificar que sesión aparece en lista después de crear
- [ ] Consultar BD para ver referencias insertadas
