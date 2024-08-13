class EquipoPorProveedorViewModel {
  int eqppId;
  int? equsId;
  int? provId;
  num? eqppPreciocompra;
  int usuaCreacion;
  DateTime eqppFechaCreacion;
  int? usuaModificacion;
  DateTime? eqppFechaModificacion;
  int? codigo;
  String? equsDescripcion;
  String? equsNombre;
  String? provDescripcion;
  int? bodeId;
  String? bodeDescripcion;
  int? bopiStock;
  String? usuaCreacionNombre;
  String? usuaModificacionNombre;
  int cantidad;
  bool? fldeTipodeCarga;

  EquipoPorProveedorViewModel({
    required this.eqppId,
    this.equsId,
    this.provId,
    this.eqppPreciocompra,
    required this.usuaCreacion,
    required this.eqppFechaCreacion,
    this.usuaModificacion,
    this.eqppFechaModificacion,
    this.codigo,
    this.equsDescripcion,
    this.equsNombre,
    this.provDescripcion,
    this.bodeId,
    this.bodeDescripcion,
    this.bopiStock,
    this.usuaCreacionNombre,
    this.usuaModificacionNombre,
    required this.cantidad,
    this.fldeTipodeCarga,
  });

  factory EquipoPorProveedorViewModel.fromJson(Map<String, dynamic> json) {
    return EquipoPorProveedorViewModel(
      eqppId: json['eqpp_Id'],
      equsId: json['equs_Id'],
      provId: json['prov_Id'],
      eqppPreciocompra: json['eqpp_Preciocompra']?.toDouble(),
      usuaCreacion: json['usua_Creacion'],
      eqppFechaCreacion: DateTime.parse(json['eqpp_FechaCreacion']),
      usuaModificacion: json['usua_Modificacion'],
      eqppFechaModificacion: json['eqpp_FechaModificacion'] != null
          ? DateTime.parse(json['eqpp_FechaModificacion'])
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
      cantidad: json['cantidad'],
      fldeTipodeCarga: json['flde_TipodeCarga'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eqpp_Id': eqppId,
      'equs_Id': equsId,
      'prov_Id': provId,
      'eqpp_Preciocompra': eqppPreciocompra,
      'usua_Creacion': usuaCreacion,
      'eqpp_FechaCreacion': eqppFechaCreacion.toIso8601String(),
      'usua_Modificacion': usuaModificacion,
      'eqpp_FechaModificacion': eqppFechaModificacion?.toIso8601String(),
      'codigo': codigo,
      'equs_Descripcion': equsDescripcion,
      'equs_Nombre': equsNombre,
      'prov_Descripcion': provDescripcion,
      'bode_Id': bodeId,
      'bode_Descripcion': bodeDescripcion,
      'bopi_Stock': bopiStock,
      'usuaCreacion': usuaCreacionNombre,
      'usuaModificacion': usuaModificacionNombre,
      'cantidad': cantidad,
      'flde_TipodeCarga': fldeTipodeCarga,
    };
  }
}
