class FleteDetalleViewModel {
  int? codigo;
  int? fldeId;
  int fldeCantidad;
  int flenId;
  int usuaCreacion;
  DateTime fldeFechaCreacion;
  int? usuaModificacion;
  DateTime? fldeFechaModificacion;
  String? bodeDescripcion;
  int? bodeId;
  int? bopiStock;
  int inppId;
  String? provDescripcion;
  String? insuDescripcion;
  String? usuaCreacionNombre;
  String? usuaModificacionNombre;
  int? insuId;
  int? provId;
  num? inppPreciocompra;
  String? mateDescripcion;
  String? unmeNombre;
  int? unmeId;
  String? unmeNomenclatura;
  bool? verificado;
  bool? fldeLlegada;

  FleteDetalleViewModel({
    this.codigo,
    this.fldeId,
    required this.fldeCantidad,
    required this.flenId,
    required this.usuaCreacion,
    required this.fldeFechaCreacion,
    this.usuaModificacion,
    this.fldeFechaModificacion,
    this.bodeDescripcion,
    this.bodeId,
    this.bopiStock,
    required this.inppId,
    this.provDescripcion,
    this.insuDescripcion,
    this.usuaCreacionNombre,
    this.usuaModificacionNombre,
    this.insuId,
    this.provId,
    this.inppPreciocompra,
    this.mateDescripcion,
    this.unmeNombre,
    this.unmeId,
    this.unmeNomenclatura,
    this.verificado,
    this.fldeLlegada,
  });

  factory FleteDetalleViewModel.fromJson(Map<String, dynamic> json) {
    return FleteDetalleViewModel(
      codigo: json['codigo'],
      fldeId: json['flde_Id'],
      fldeCantidad: json['flde_Cantidad'],
      flenId: json['flen_Id'],
      usuaCreacion: json['usua_Creacion'],
      fldeFechaCreacion: DateTime.parse(json['flde_FechaCreacion']),
      usuaModificacion: json['usua_Modificacion'],
      fldeFechaModificacion: json['flde_FechaModificacion'] != null ? DateTime.parse(json['flde_FechaModificacion']) : null,
      bodeDescripcion: json['bode_Descripcion'],
      bodeId: json['bode_Id'],
      bopiStock: json['bopi_Stock'],
      inppId: json['inpp_Id'],
      provDescripcion: json['prov_Descripcion'],
      insuDescripcion: json['insu_Descripcion'],
      usuaCreacionNombre: json['usuaCreacion'],
      usuaModificacionNombre: json['usuaModificacion'],
      insuId: json['insu_Id'],
      provId: json['prov_Id'],
      inppPreciocompra: json['inpp_Preciocompra']?.toDouble(),
      mateDescripcion: json['mate_Descripcion'],
      unmeNombre: json['unme_Nombre'],
      unmeId: json['unme_Id'],
      unmeNomenclatura: json['unme_Nomenclatura'],
      verificado: json['verificado'],
      fldeLlegada: json['flde_llegada'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'flde_Id': fldeId,
      'flde_Cantidad': fldeCantidad,
      'flen_Id': flenId,
      'usua_Creacion': usuaCreacion,
      'flde_FechaCreacion': fldeFechaCreacion.toIso8601String(),
      'usua_Modificacion': usuaModificacion,
      'flde_FechaModificacion': fldeFechaModificacion?.toIso8601String(),
      'bode_Descripcion': bodeDescripcion,
      'bode_Id': bodeId,
      'bopi_Stock': bopiStock,
      'inpp_Id': inppId,
      'prov_Descripcion': provDescripcion,
      'insu_Descripcion': insuDescripcion,
      'usuaCreacion': usuaCreacionNombre,
      'usuaModificacion': usuaModificacionNombre,
      'insu_Id': insuId,
      'prov_Id': provId,
      'inpp_Preciocompra': inppPreciocompra,
      'mate_Descripcion': mateDescripcion,
      'unme_Nombre': unmeNombre,
      'unme_Id': unmeId,
      'unme_Nomenclatura': unmeNomenclatura,
      'verificado': verificado,
      'flde_llegada': fldeLlegada,
    };
  }
}
