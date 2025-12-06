/// 📦 MODELO DE REFERENCIA MAESTRA
/// Estructura igual a la tabla Drift y al Excel.
import '../database/drift_database.dart';

class ReferenciaMaestra {
  final String codRef;
  final String nomRef;
  final String codTip;
  final String codPrv;
  final double valRef;
  final String codEmp;
  final String nomRef1;
  final String nomRef2;
  final String refPrv;
  final double valRef1;
  final String codMar;
  final double vrunc;
  final String cos001;
  final String? codBarra;
  final int salRef;
  final String tallaDisp;
  final String conRec;
  final double valLista1;
  final double valLista2;
  final double valLista3;
  final bool activo;

  ReferenciaMaestra({
    required this.codRef,
    required this.nomRef,
    required this.codTip,
    required this.codPrv,
    required this.valRef,
    required this.codEmp,
    required this.nomRef1,
    required this.nomRef2,
    required this.refPrv,
    required this.valRef1,
    required this.codMar,
    required this.vrunc,
    required this.cos001,
    this.codBarra,
    required this.salRef,
    required this.tallaDisp,
    required this.conRec,
    required this.valLista1,
    required this.valLista2,
    required this.valLista3,
    required this.activo,
  });

  /// 🔄 Convertir a JSON para exportar o guardar
  Map<String, dynamic> toJson() => {
    'COD_REF': codRef,
    'NOM_REF': nomRef,
    'COD_TIP': codTip,
    'COD_PRV': codPrv,
    'VAL_REF': valRef,
    'COD_EMP': codEmp,
    'NOM_REF1': nomRef1,
    'NOM_REF2': nomRef2,
    'REF_PRV': refPrv,
    'VAL_REF1': valRef1,
    'COD_MAR': codMar,
    'VRUNC': vrunc,
    'COS_001': cos001,
    'COD_BARRA': codBarra,
    'SAL_REF': salRef,
    'TALLA_DISP': tallaDisp,
    'CON_REC': conRec,
    'VAL_LISTA1': valLista1,
    'VAL_LISTA2': valLista2,
    'VAL_LISTA3': valLista3,
    'ACTIVO': activo,
  };

  /// 🔄 Crear desde JSON (importar o leer de BD)
  factory ReferenciaMaestra.fromJson(Map<String, dynamic> json) =>
      ReferenciaMaestra(
        codRef: json['COD_REF'] ?? '',
        nomRef: json['NOM_REF'] ?? '',
        codTip: json['COD_TIP'] ?? '',
        codPrv: json['COD_PRV'] ?? '',
        valRef: (json['VAL_REF'] ?? 0).toDouble(),
        codEmp: json['COD_EMP'] ?? '',
        nomRef1: json['NOM_REF1'] ?? '',
        nomRef2: json['NOM_REF2'] ?? '',
        refPrv: json['REF_PRV'] ?? '',
        valRef1: (json['VAL_REF1'] ?? 0).toDouble(),
        codMar: json['COD_MAR'] ?? '',
        vrunc: (json['VRUNC'] ?? 0).toDouble(),
        cos001: json['COS_001'] ?? '',
        codBarra: json['COD_BARRA'],
        salRef: json['SAL_REF'] ?? 0,
        tallaDisp: json['TALLA_DISP'] ?? '',
        conRec: json['CON_REC'] ?? '',
        valLista1: (json['VAL_LISTA1'] ?? 0).toDouble(),
        valLista2: (json['VAL_LISTA2'] ?? 0).toDouble(),
        valLista3: (json['VAL_LISTA3'] ?? 0).toDouble(),
        activo: json['ACTIVO'] ?? true,
      );

  /// 🔄 CONVERTIR DESDE DRIFT
  /// Crea una instancia de ReferenciaMaestra a partir de una fila Drift (ReferenciasMaestra).
  factory ReferenciaMaestra.fromDrift(ReferenciasMaestra row) {
    return ReferenciaMaestra(
      codRef: row.codRef,
      nomRef: row.nomRef,
      codTip: row.codTip,
      codPrv: row.codPrv,
      valRef: row.valRef.toDouble(),
      codEmp: row.codEmp,
      nomRef1: row.nomRef1,
      nomRef2: row.nomRef2,
      refPrv: row.refPrv,
      valRef1: row.valRef1.toDouble(),
      codMar: row.codMar,
      vrunc: row.vrunc.toDouble(),
      cos001: row.cos001,
      codBarra: row.codBarra,
      salRef: row.salRef,
      tallaDisp: row.tallaDisp,
      conRec: row.conRec,
      valLista1: row.valLista1.toDouble(),
      valLista2: row.valLista2.toDouble(),
      valLista3: row.valLista3.toDouble(),
      activo: row.activo,
    );
  }
}
