class EquipoPorProveedorViewModel {
  int? eqppId;
  int? equsId;
  int? provId;
  num? eqppPreciocompra;
  int? usuaCreacion;
  DateTime? equsFechaCreacion;
  int? usuaModificacion;
  DateTime? equsFechaModificacion;
  int? codigo;
  String? equsDescripcion;
  String? equsNombre;
  String? provDescripcion;
  int? bodeId;
  String? bodeDescripcion;
  int? bopiStock;
  String? usuaCreacionNombre;
  String? usuaModificacionNombre;
  num? cantidadRecibida;

  EquipoPorProveedorViewModel({
    this.eqppId,
    this.equsId,
    this.provId,
    this.eqppPreciocompra,
    this.usuaCreacion,
    this.equsFechaCreacion,
    this.usuaModificacion,
    this.equsFechaModificacion,
    this.codigo,
    this.equsDescripcion,
    this.equsNombre,
    this.provDescripcion,
    this.bodeId,
    this.bodeDescripcion,
    this.bopiStock,
    this.usuaCreacionNombre,
    this.usuaModificacionNombre,
    this.cantidadRecibida,
  });

  factory EquipoPorProveedorViewModel.fromJson(Map<String, dynamic> json) {
    return EquipoPorProveedorViewModel(
      eqppId: json['eqpp_Id'],
      equsId: json['equs_Id'],
      provId: json['prov_Id'],
      eqppPreciocompra: json['eqpp_Preciocompra']?.toDouble(),
      usuaCreacion: json['usua_Creacion'],
      equsFechaCreacion: json['equs_FechaCreacion'] != null
          ? DateTime.parse(json['equs_FechaCreacion'])
          : null,
      usuaModificacion: json['usua_Modificacion'],
      equsFechaModificacion: json['equs_FechaModificacion'] != null
          ? DateTime.parse(json['equs_FechaModificacion'])
          : null,
      codigo: json['codigo'],
      equsDescripcion: json['equs_Descripcion'],
      equsNombre: json['equs_Nombre'],
      provDescripcion: json['prov_Descripcion'],
      bodeId: json['bode_Id'],
      bodeDescripcion: json['bode_Descripcion'],
      bopiStock: json['bopi_Stock'],
      usuaCreacionNombre: json['usuaCreacion'],
      usuaModificacionNombre: json['usuaModificacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eqpp_Id': eqppId,
      'equs_Id': equsId,
      'prov_Id': provId,
      'eqpp_Preciocompra': eqppPreciocompra,
      'usua_Creacion': usuaCreacion,
      'eqpp_FechaCreacion': equsFechaCreacion?.toIso8601String(),
      'usua_Modificacion': usuaModificacion,
      'eqpp_FechaModificacion': equsFechaModificacion?.toIso8601String(),
      'codigo': codigo,
      'equs_Descripcion': equsDescripcion,
      'equs_Nombre': equsNombre,
      'prov_Descripcion': provDescripcion,
      'bode_Id': bodeId,
      'bode_Descripcion': bodeDescripcion,
      'bopi_Stock': bopiStock,
      'usuaCreacion': usuaCreacionNombre,
      'usuaModificacion': usuaModificacionNombre,
    };
  }

  @override
  String toString() {
    return 'equipoporprov(eqppId: $eqppId, equsId $equsId, usuacrea $usuaCreacion, nombre: $equsNombre, desc: $equsDescripcion, bodeid: $bodeId, equsdescripcion $equsDescripcion, bodedes: $bodeDescripcion, fechachreacion $equsFechaCreacion';
  }
}
