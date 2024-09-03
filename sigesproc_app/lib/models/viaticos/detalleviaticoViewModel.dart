class Detalleviaticoviewmodel {
  int? codigo;
  String? empleado;
  String? proyecto;

  int? vienId;
  bool? vienSaberProyeto;
  double? vienMontoEstimado;
  double? vienTotalGastado;
  DateTime? vienFechaEmicion;
  int? emplId;
  int? proyId;
  int? usuaCreacion;
  DateTime? vienFechaCreacion;
  int? usuaModificacion;
  DateTime? vienFechaModificacion;
  double? vienTotalReconocido;
  int? videId;
  String? videDescripcion;
  String? caviDescripcion;
  String? videImagenFactura;
  String? videMontoGastado;
  int? caviId;
  DateTime? videFechaCreacion;
  DateTime? videFechaModificacion;
  double? videMontoReconocido;

  Detalleviaticoviewmodel({
    this.codigo,
    this.empleado,
    this.proyecto,
    this.vienId,
    this.vienSaberProyeto,
    this.vienMontoEstimado,
    this.vienTotalGastado,
    this.vienFechaEmicion,
    this.emplId,
    this.proyId,
    this.usuaCreacion,
    this.vienFechaCreacion,
    this.usuaModificacion,
    this.vienFechaModificacion,
    this.vienTotalReconocido,
    this.videId,
    this.videDescripcion,
    this.caviDescripcion,
    this.videImagenFactura,
    this.videMontoGastado,
    this.caviId,
    this.videFechaCreacion,
    this.videFechaModificacion,
    this.videMontoReconocido,
  });

  factory Detalleviaticoviewmodel.fromJson(Map<String, dynamic> json) {
    return Detalleviaticoviewmodel(
      codigo: json['codigo'],
      empleado: json['empleado'],
      proyecto: json['proyecto'],
      vienId: json['vien_Id'],
      vienSaberProyeto: json['vien_SaberProyeto'],
      vienMontoEstimado: json['vien_MontoEstimado']?.toDouble(),
      vienTotalGastado: json['vien_TotalGastado']?.toDouble(),
      vienFechaEmicion: json['vien_FechaEmicion'] != null
          ? DateTime.parse(json['vien_FechaEmicion'])
          : null,
      emplId: json['empl_Id'],
      proyId: json['Proy_Id'],
      usuaCreacion: json['usua_Creacion'],
      vienFechaCreacion: json['vien_FechaCreacion'] != null
          ? DateTime.parse(json['vien_FechaCreacion'])
          : null,
      usuaModificacion: json['usua_Modificacion'],
      vienFechaModificacion: json['vien_FechaModificacion'] != null
          ? DateTime.parse(json['vien_FechaModificacion'])
          : null,
      vienTotalReconocido: json['vien_TotalReconocido']?.toDouble(),
      videId: json['vide_Id'],
      videDescripcion: json['vide_Descripcion'],
      caviDescripcion: json['cavi_Descripcion'],
      videImagenFactura: json['vide_ImagenFactura'],
      videMontoGastado: json['vide_MontoGastado'],
      caviId: json['cavi_Id'],
      videFechaCreacion: json['vide_FechaCreacion'] != null
          ? DateTime.parse(json['vide_FechaCreacion'])
          : null,
      videFechaModificacion: json['vide_FechaModificacion'] != null
          ? DateTime.parse(json['vide_FechaModificacion'])
          : null,
      videMontoReconocido: json['vide_MontoReconocido']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'Empleado': empleado,
      'Proyecto': proyecto,
      'vien_Id': vienId,
      'vien_SaberProyeto': vienSaberProyeto,
      'vien_MontoEstimado': vienMontoEstimado,
      'vien_TotalGastado': vienTotalGastado,
      'vien_FechaEmicion': vienFechaEmicion?.toIso8601String(),
      'empl_Id': emplId,
      'Proy_Id': proyId,
      'usua_Creacion': usuaCreacion,
      'vien_FechaCreacion': vienFechaCreacion?.toIso8601String(),
      'usua_Modificacion': usuaModificacion,
      'vien_FechaModificacion': vienFechaModificacion?.toIso8601String(),
      'vien_TotalReconocido': vienTotalReconocido,
      'vide_Id': videId,
      'vide_Descripcion': videDescripcion,
      'cavi_Descripcion': caviDescripcion,
      'vide_ImagenFactura': videImagenFactura,
      'vide_MontoGastado': videMontoGastado,
      'cavi_Id': caviId,
      'vide_FechaCreacion': videFechaCreacion?.toIso8601String(),
      'vide_FechaModificacion': videFechaModificacion?.toIso8601String(),
      'vide_MontoReconocido': videMontoReconocido,
    };
  }
}
