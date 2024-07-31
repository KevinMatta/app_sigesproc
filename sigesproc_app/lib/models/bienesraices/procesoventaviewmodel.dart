class ProcesoVentaViewModel {
  String codigo;
  int btrpId;
  String? linkUbicacion;
  String? agenNombreCompleto;
  String? agenTelefono;
  String? agenDNI;
  String? descripcion;
  bool? btrpIdentificador;
  num? btrpPrecioVentaInicio;
  num? btrpPrecioVentaFinal;
  DateTime? btrpFechaPuestaVenta;
  DateTime? btrpFechaVendida;
  bool btrpTerrenoOBienRaizId;
  int? btrpBienoterrenoId;
  int? agenId;
  int? usuaCreacion;
  String? usuaaCreacion;
  DateTime? btrpFechaCreacion;
  int? usuaModificacion;
  String? usuaaModificacion;
  DateTime? btrpFechaModificacion;
  bool? btrpEstado;

  ProcesoVentaViewModel({
    required this.codigo,
    required this.btrpId,
    this.linkUbicacion,
    this.agenNombreCompleto,
    this.agenTelefono,
    this.agenDNI,
    this.descripcion,
    this.btrpIdentificador,
    this.btrpPrecioVentaInicio,
    this.btrpPrecioVentaFinal,
    this.btrpFechaPuestaVenta,
    this.btrpFechaVendida,
    required this.btrpTerrenoOBienRaizId,
    this.btrpBienoterrenoId,
    this.agenId,
    this.usuaCreacion,
    this.usuaaCreacion,
    this.btrpFechaCreacion,
    this.usuaModificacion,
    this.usuaaModificacion,
    this.btrpFechaModificacion,
    this.btrpEstado,
  });

  factory ProcesoVentaViewModel.fromJson(Map<String, dynamic> json) {
    return ProcesoVentaViewModel(
      codigo: json['codigo'],
      btrpId: json['btrp_Id'],
      linkUbicacion: json['linkUbicacion'],
      agenNombreCompleto: json['agen_NombreCompleto'],
      agenTelefono: json['agen_Telefono'],
      agenDNI: json['agen_DNI'],
      descripcion: json['descripcion'],
      btrpIdentificador: json['btrp_Identificador'],
      btrpPrecioVentaInicio: json['btrp_PrecioVenta_Inicio'],
      btrpPrecioVentaFinal: json['btrp_PrecioVenta_Final'],
      btrpFechaPuestaVenta: json['btrp_FechaPuestaVenta'] != null ? DateTime.parse(json['btrp_FechaPuestaVenta']) : null,
      btrpFechaVendida: json['btrp_FechaVendida'] != null ? DateTime.parse(json['btrp_FechaVendida']) : null,
      btrpTerrenoOBienRaizId: json['btrp_Terreno_O_BienRaizId'],
      btrpBienoterrenoId: json['btrp_BienoterrenoId'],
      agenId: json['agen_Id'],
      usuaCreacion: json['usua_Creacion'],
      usuaaCreacion: json['usuaCreacion'],
      btrpFechaCreacion: json['btrp_FechaCreacion'] != null ? DateTime.parse(json['btrp_FechaCreacion']) : null,
      usuaModificacion: json['usua_Modificacion'],
      usuaaModificacion: json['usuaModificacion'],
      btrpFechaModificacion: json['btrp_FechaModificacion'] != null ? DateTime.parse(json['btrp_FechaModificacion']) : null,
      btrpEstado: json['btrp_Estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'btrp_Id': btrpId,
      'linkUbicacion':linkUbicacion,
      'agen_NombreCompleto': agenNombreCompleto,
      'agen_Telefono': agenTelefono,
      'agen_DNI': agenDNI,
      'descripcion': descripcion,
      'btrp_Identificador': btrpIdentificador,
      'btrp_PrecioVenta_Inicio': btrpPrecioVentaInicio,
      'btrp_PrecioVenta_Final': btrpPrecioVentaFinal,
      'btrp_FechaPuestaVenta': btrpFechaPuestaVenta,
      'btrp_FechaVendida': btrpFechaVendida,
      'btrp_Terreno_O_BienRaizId': btrpTerrenoOBienRaizId,
      'btrp_BienoterrenoId': btrpBienoterrenoId,
      'agen_Id': agenId,
      'usua_Creacion': usuaCreacion,
      'usuaCreacion': usuaaCreacion,
      'btrp_FechaCreacion': btrpFechaCreacion?.toIso8601String(),
      'usua_Modificacion': usuaModificacion,
      'usuaModificacion': usuaaModificacion,
      'btrp_FechaModificacion': btrpFechaModificacion?.toIso8601String(),
      'btrp_Estado': btrpEstado,
    };
  }
}
