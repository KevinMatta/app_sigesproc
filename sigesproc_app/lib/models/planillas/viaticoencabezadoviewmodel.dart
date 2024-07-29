class ViaticoEncabezadoViewModel {
  String codigo;
  String? usuarioCreacion;
  String? usuarioModifica;
  int vienId;
  bool? vienSaberProyeto;
  num? vienMontoEstimado;
  num? vienTotalGastado;
  DateTime? vienFechaEmicion;
  int? emplId;
  String? empleado;
  int? proyId;
  String? proyecto;
  int? usuaCreacion;
  int? usuaModificacion;
  DateTime? vienFechaCreacion;
  DateTime? vienFechaModificacion;
  num? vienTotalReconocido;
  bool? vienEstadoFacturas;

  ViaticoEncabezadoViewModel({
    required this.codigo,
    this.usuarioCreacion,
    this.usuarioModifica,
    required this.vienId,
    this.vienSaberProyeto,
    this.vienMontoEstimado,
    this.vienTotalGastado,
    this.vienFechaEmicion,
    this.emplId,
    this.empleado,
    this.proyId,
    this.proyecto,
    this.usuaCreacion,
    this.usuaModificacion,
    this.vienFechaCreacion,
    this.vienFechaModificacion,
    this.vienTotalReconocido,
    this.vienEstadoFacturas,
  });

  factory ViaticoEncabezadoViewModel.fromJson(Map<String, dynamic> json) {
    return ViaticoEncabezadoViewModel(
      codigo: json['codigo'],
      usuarioCreacion: json['usuarioCreacion'],
      usuarioModifica: json['usuarioModifica'],
      vienId: json['vien_Id'],
      vienSaberProyeto: json['vien_SaberProyeto'],
      vienMontoEstimado: json['vien_MontoEstimado'],
      vienTotalGastado: json['vien_TotalGastado'],
      vienFechaEmicion: json['vien_FechaEmicion'] != null ? DateTime.parse(json['vien_FechaEmicion']) : null,
      emplId: json['empl_Id'],
      empleado: json['empleado'],
      proyId: json['proy_Id'],
      proyecto: json['proyecto'],
      usuaCreacion: json['usua_Creacion'],
      usuaModificacion: json['usua_Modificacion'],
      vienFechaCreacion: json['vien_FechaCreacion'] != null ? DateTime.parse(json['vien_FechaCreacion']) : null,
      vienFechaModificacion: json['vien_FechaModificacion'] != null ? DateTime.parse(json['vien_FechaModificacion']) : null,
      vienTotalReconocido: json['vien_TotalReconocido'],
      vienEstadoFacturas: json['vien_EstadoFacturas'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'usuarioCreacion': usuarioCreacion,
      'usuarioModifica': usuarioModifica,
      'vien_Id': vienId,
      'vien_SaberProyeto': vienSaberProyeto,
      'vien_MontoEstimado': vienMontoEstimado,
      'vien_TotalGastado': vienTotalGastado,
      'vien_FechaEmicion': vienFechaEmicion?.toIso8601String(),
      'empl_Id': emplId,
      'empleado': empleado,
      'proy_Id': proyId,
      'proyecto': proyecto,
      'usua_Creacion': usuaCreacion,
      'usua_Modificacion': usuaModificacion,
      'vien_FechaCreacion': vienFechaCreacion?.toIso8601String(),
      'vien_FechaModificacion': vienFechaModificacion?.toIso8601String(),
      'vien_TotalReconocido': vienTotalReconocido,
      'vien_EstadoFacturas': vienEstadoFacturas,
    };
  }
}
