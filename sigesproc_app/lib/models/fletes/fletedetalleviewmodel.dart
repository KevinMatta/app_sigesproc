class FleteDetalleViewModel {
  int? codigo;
  int? fldeId;
  int? fldeCantidad;
  int? cantidadRecibida;
  bool? fldeTipodeCarga;
  int? flenId;
  int? usuaCreacion;
  DateTime? fldeFechaCreacion;
  int? usuaModificacion;
  DateTime? fldeFechaModificacion;
  String? bodeDescripcion;
  int? bodeId;
  int? bopiStock;
  int? inppId;
  String? provDescripcion;
  String? insuDescripcion;
  String? equsNombre;
  String? equsDescripcion;
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
    this.fldeCantidad,
    this.cantidadRecibida,
    this.fldeTipodeCarga,
    this.flenId,
    this.usuaCreacion,
    this.fldeFechaCreacion,
    this.usuaModificacion,
    this.fldeFechaModificacion,
    this.bodeDescripcion,
    this.bodeId,
    this.bopiStock,
    this.inppId,
    this.provDescripcion,
    this.insuDescripcion,
    this.equsNombre,
    this.equsDescripcion,
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
      fldeTipodeCarga: json['flde_TipodeCarga'],
      flenId: json['flen_Id'],
      usuaCreacion: json['usua_Creacion'],
      fldeFechaCreacion: json['flde_FechaCreacion'] != null ? DateTime.parse(json['flde_FechaCreacion']) : null,
      usuaModificacion: json['usua_Modificacion'],
      fldeFechaModificacion: json['flde_FechaModificacion'] != null ? DateTime.parse(json['flde_FechaModificacion']) : null,
      bodeDescripcion: json['bode_Descripcion'],
      bodeId: json['bode_Id'],
      bopiStock: json['bopi_Stock'],
      inppId: json['inpp_Id'],
      provDescripcion: json['prov_Descripcion'],
      insuDescripcion: json['insu_Descripcion'],
      equsNombre: json['equs_Nombre'],
      equsDescripcion: json['equs_Descripcion'],
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
    final Map<String, dynamic> data = {};

    if (codigo != null) {
      data['codigo'] = codigo;
    }
    if (fldeId != null) {
      data['flde_Id'] = fldeId;
    }
    if (fldeCantidad != null) {
      data['flde_Cantidad'] = fldeCantidad;
    }
    if (fldeTipodeCarga != null) {
      data['flde_TipodeCarga'] = fldeTipodeCarga;
    }
    if (flenId != null) {
      data['flen_Id'] = flenId;
    }
    if (usuaCreacion != null) {
      data['usua_Creacion'] = usuaCreacion;
    }
    if (fldeFechaCreacion != null) {
      data['flde_FechaCreacion'] = fldeFechaCreacion?.toIso8601String();
    }
    if (usuaModificacion != null) {
      data['usua_Modificacion'] = usuaModificacion;
    }
    if (fldeFechaModificacion != null) {
      data['flde_FechaModificacion'] = fldeFechaModificacion?.toIso8601String();
    }
    if (bodeDescripcion != null) {
      data['bode_Descripcion'] = bodeDescripcion;
    }
    if (bodeId != null) {
      data['bode_Id'] = bodeId;
    }
    if (bopiStock != null) {
      data['bopi_Stock'] = bopiStock;
    }
    data['inpp_Id'] = inppId;
    if (provDescripcion != null) {
      data['prov_Descripcion'] = provDescripcion;
    }
    if (insuDescripcion != null) {
      data['insu_Descripcion'] = insuDescripcion;
    }
    if (equsNombre != null) {
      data['equs_Nombre'] = equsNombre;
    }
    if (equsDescripcion != null) {
      data['equs_Descripcion'] = equsDescripcion;
    }
    if (usuaCreacionNombre != null) {
      data['usuaCreacion'] = usuaCreacionNombre;
    }
    if (usuaModificacionNombre != null) {
      data['usuaModificacion'] = usuaModificacionNombre;
    }
    if (insuId != null) {
      data['insu_Id'] = insuId;
    }
    if (provId != null) {
      data['prov_Id'] = provId;
    }
    if (inppPreciocompra != null) {
      data['inpp_Preciocompra'] = inppPreciocompra;
    }
    if (mateDescripcion != null) {
      data['mate_Descripcion'] = mateDescripcion;
    }
    if (unmeNombre != null) {
      data['unme_Nombre'] = unmeNombre;
    }
    if (unmeId != null) {
      data['unme_Id'] = unmeId;
    }
    if (unmeNomenclatura != null) {
      data['unme_Nomenclatura'] = unmeNomenclatura;
    }
    if (verificado != null) {
      data['verificado'] = verificado;
    }
    if (fldeLlegada != null) {
      data['flde_llegada'] = fldeLlegada;
    }
    return data;
  }

   @override
  String toString() {
    return 'FleteDetalleViewModel(flenId: $flenId, fldeId $fldeId, inpp $inppId, cantidad: $fldeCantidad, insudescripcion: $insuDescripcion, equsnombre: $equsNombre, equsdescripcion $equsDescripcion, fldeLlegada: $fldeLlegada, fldeTipodeCarga: $fldeTipodeCarga, usuacreacion $usuaCreacion, fechachreacion $fldeFechaCreacion';
  }
}
