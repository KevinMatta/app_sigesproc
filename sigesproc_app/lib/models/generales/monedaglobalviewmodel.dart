class MonedaGlobalViewModel {
  final int? moneId;
  final String? moneNombre;
  final int? paisId;
  final int? usuaCreacion;
  final DateTime? moneFechaCreacion;
  final int? usuaModificacion;
  final DateTime? moneFechaModificacion;
  final bool? moneEstado;
  final String? moneAbreviatura;

  // NotMapped properties
  final String? codigo;
  final String? usuaCreacionNombre;
  final String? usuaModificacionNombre;
  final String? paisNombre;

  MonedaGlobalViewModel({
    this.moneId,
    this.moneNombre,
    this.paisId,
    this.usuaCreacion,
    this.moneFechaCreacion,
    this.usuaModificacion,
    this.moneFechaModificacion,
    this.moneEstado,
    this.moneAbreviatura,
    this.codigo,
    this.usuaCreacionNombre,
    this.usuaModificacionNombre,
    this.paisNombre,
  });

  factory MonedaGlobalViewModel.fromJson(Map<String, dynamic> json) {
    return MonedaGlobalViewModel(
      moneId: json['mone_Id'] as int?,
      moneNombre: json['mone_Nombre'] as String?,
      paisId: json['pais_Id'] as int?,
      usuaCreacion: json['usua_Creacion'] as int?,
      moneFechaCreacion: json['mone_FechaCreacion'] != null ? DateTime.parse(json['mone_FechaCreacion']) : null,
      usuaModificacion: json['usua_Modificacion'] as int?,
      moneFechaModificacion: json['mone_FechaModificacion'] != null ? DateTime.parse(json['mone_FechaModificacion']) : null,
      moneEstado: json['mone_Estado'] as bool?,
      moneAbreviatura: json['mone_Abreviatura'] as String?,
      codigo: json['codigo'] as String?,
      usuaCreacionNombre: json['usuaCreacion'] as String?,
      usuaModificacionNombre: json['usuaModificacion'] as String?,
      paisNombre: json['pais_Nombre'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mone_Id': moneId,
      'mone_Nombre': moneNombre,
      'pais_Id': paisId,
      'usua_Creacion': usuaCreacion,
      'mone_FechaCreacion': moneFechaCreacion?.toIso8601String(),
      'usua_Modificacion': usuaModificacion,
      'mone_FechaModificacion': moneFechaModificacion?.toIso8601String(),
      'mone_Estado': moneEstado,
      'mone_Abreviatura': moneAbreviatura,
      'codigo': codigo,
      'usuaCreacion': usuaCreacionNombre,
      'usuaModificacion': usuaModificacionNombre,
      'pais_Nombre': paisNombre,
    };
  }
}
