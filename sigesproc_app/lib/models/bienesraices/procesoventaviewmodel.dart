class ProcesoVentaViewModel {
  String? codigo;
  int btrpId;
  int? imprId;
  String? imprImagen;
  String? linkUbicacion;
  String? agenNombreCompleto;
  String? agenTelefono;
  String? agenDNI;
  int? clieId;
  String? clieDNI;
  String? clieTelefono;
  String? clieNombreCompleto;
  String? descripcion;
  String? area;
  bool? btrpIdentificador;
  num? btrpPrecioVentaInicio;
  num? btrpPrecioVentaFinal;
  DateTime? btrpFechaPuestaVenta;
  DateTime? btrpFechaVendida;
  bool? btrpTerrenoOBienRaizId;
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
    this.codigo,
    required this.btrpId,
    this.imprId,
    this.imprImagen,
    this.linkUbicacion,
    this.agenNombreCompleto,
    this.agenTelefono,
    this.agenDNI,
    this.clieId,
    this.clieDNI,
    this.clieTelefono,
    this.clieNombreCompleto,
    this.descripcion,
    this.area,
    this.btrpIdentificador,
    this.btrpPrecioVentaInicio,
    this.btrpPrecioVentaFinal,
    this.btrpFechaPuestaVenta,
    this.btrpFechaVendida,
    this.btrpTerrenoOBienRaizId,
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
      codigo: json['codigo'] ?? '',
      btrpId: json['btrp_Id'] ?? 0,
      imprId: json['impr_Id'] ?? 0,
      imprImagen: json['impr_Imagen'],
      linkUbicacion: json['linkUbicacion'],
      agenNombreCompleto: json['agen_NombreCompleto'],
      agenTelefono: json['agen_Telefono'],
      agenDNI: json['agen_DNI'],
      clieId: json['clie_Id'],
      clieDNI: json['clie_DNI'],
      clieTelefono: json['clie_Telefono'],
      clieNombreCompleto: json['clie_NombreCompleto'],
      descripcion: json['descripcion'],
      area: json['area'],
      btrpIdentificador: json['btrp_Identificador'],
      btrpPrecioVentaInicio: json['btrp_PrecioVenta_Inicio'],
      btrpPrecioVentaFinal: json['btrp_PrecioVenta_Final'],
      btrpFechaPuestaVenta: json['btrp_FechaPuestaVenta'] != null ? DateTime.parse(json['btrp_FechaPuestaVenta']) : null,
      btrpFechaVendida: json['btrp_FechaVendida'] != null ? DateTime.parse(json['btrp_FechaVendida']) : null,
      btrpTerrenoOBienRaizId: json['btrp_Terreno_O_BienRaizId'] ?? false,
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
      'impr_Id': imprId,
      'impr_Imagen': imprImagen,
      'linkUbicacion': linkUbicacion,
      'agen_NombreCompleto': agenNombreCompleto,
      'agen_Telefono': agenTelefono,
      'agen_DNI': agenDNI,
      'clie_Id': clieId,
      'descripcion': descripcion,
      'area': area,
      'btrp_Identificador': btrpIdentificador,
      'btrp_PrecioVenta_Inicio': btrpPrecioVentaInicio,
      'btrp_PrecioVenta_Final': btrpPrecioVentaFinal,
      'btrp_FechaPuestaVenta': btrpFechaPuestaVenta?.toIso8601String(),
      'btrp_FechaVendida': btrpFechaVendida?.toIso8601String(),
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

  @override
  String toString() {
    return 'procesoventa(btrpId: $btrpId, precioventafinal: $btrpPrecioVentaFinal, clieId: $clieId, fechavendida: $btrpFechaVendida';
  }
}
