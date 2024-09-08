class InsumoActividadEtapaViewModel {
  int? inppId;
  int? insuId;
  int? provId;
  num? inppPreciocompra;
  int? usuaCreacion;
  DateTime? inppFechaCreacion;
  int? usuaModificacion;
  DateTime? inppFechaModificacion;
  int? codigo;
  String? mateDescripcion;
  String? insuDescripcion;
  String? provDescripcion;
  String? unmeNombre;
  int? unmeId;
  String? unmeNomenclatura;
  String? usuaCreacionNombre;
  String? usuaModificacionNombre;
  int? bodeId;
  String? bodeDescripcion;
  int? bopiStock;
  // String? inppObservacion;
  int? fldeLlegada;
  int? cantidad;
  String? cantidadError;
  int? stockRestante;

  InsumoActividadEtapaViewModel({
    this.inppId,
    this.insuId,
    this.provId,
    this.inppPreciocompra,
    this.usuaCreacion,
    this.inppFechaCreacion,
    this.usuaModificacion,
    this.inppFechaModificacion,
    this.codigo,
    this.mateDescripcion,
    this.insuDescripcion,
    this.provDescripcion,
    this.unmeNombre,
    this.unmeId,
    this.unmeNomenclatura,
    this.usuaCreacionNombre,
    this.usuaModificacionNombre,
    this.bodeId,
    this.bodeDescripcion,
    this.bopiStock,
    // this.inppObservacion,
    this.fldeLlegada,
    this.cantidad,
    this.cantidadError,
    this.stockRestante,
  });

  factory InsumoActividadEtapaViewModel.fromJson(Map<String, dynamic> json) {
    return InsumoActividadEtapaViewModel(
      inppId: json['inpp_Id'],
      insuId: json['insu_Id'],
      provId: json['prov_Id'],
      inppPreciocompra: json['inpp_Preciocompra']?.toDouble(),
      usuaCreacion: json['usua_Creacion'],
      inppFechaCreacion: DateTime.parse(json['inpp_FechaCreacion']),
      usuaModificacion: json['usua_Modificacion'],
      inppFechaModificacion: json['inpp_FechaModificacion'] != null
          ? DateTime.parse(json['inpp_FechaModificacion'])
          : null,
      codigo: json['codigo'],
      mateDescripcion: json['mate_Descripcion'],
      insuDescripcion: json['insu_Descripcion'],
      provDescripcion: json['prov_Descripcion'],
      unmeNombre: json['unme_Nombre'],
      unmeId: json['unme_Id'],
      unmeNomenclatura: json['unme_Nomenclatura'],
      usuaCreacionNombre: json['usuaCreacion'],
      usuaModificacionNombre: json['usuaModificacion'],
      bodeId: json['bode_Id'],
      bodeDescripcion: json['bode_Descripcion'],
      bopiStock: json['bopi_Stock'],
      // inppObservacion: json['inpp_Observacion'],
      fldeLlegada: json['flde_llegada'],
      cantidad: json['cantidad'],
      cantidadError: json['cantidadError'],
      stockRestante: json['stockRestante'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inpp_Id': inppId,
      'insu_Id': insuId,
      'prov_Id': provId,
      'inpp_Preciocompra': inppPreciocompra,
      'usua_Creacion': usuaCreacion,
      'inpp_FechaCreacion': inppFechaCreacion?.toIso8601String(),
      'usua_Modificacion': usuaModificacion,
      'inpp_FechaModificacion': inppFechaModificacion?.toIso8601String(),
      'codigo': codigo,
      'mate_Descripcion': mateDescripcion,
      'insu_Descripcion': insuDescripcion,
      'prov_Descripcion': provDescripcion,
      'unme_Nombre': unmeNombre,
      'unme_Id': unmeId,
      'unme_Nomenclatura': unmeNomenclatura,
      'usuaCreacion': usuaCreacionNombre,
      'usuaModificacion': usuaModificacionNombre,
      'bode_Id': bodeId,
      'bode_Descripcion': bodeDescripcion,
      'bopi_Stock': bopiStock,
      // 'inpp_Observacion': inppObservacion,
      'flde_llegada': fldeLlegada,
      'cantidad': cantidad,
      'cantidadError': cantidadError,
      'stockRestante': stockRestante,
    };
  }

  @override
  String toString() {
    return 'insumoporporveedorvie(inppid: $inppId, insudes: $insuDescripcion, matedesc: $mateDescripcion stock $bopiStock, cantida $cantidad';
  }
}
