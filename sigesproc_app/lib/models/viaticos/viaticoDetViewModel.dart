class ViaticoDetViewModel {
  int? codigo;
  int? videId;
  String? videDescripcion;
  String? videImagenFactura;
  String? videMontoGastado;
  int? vienId;
  int? caviId;
  int? usuaCreacion;
  DateTime? videFechaCreacion;
  int? usuaModificacion;
  DateTime? videFechaModificacion;
  double? videMontoReconocido; // NotMapped

  ViaticoDetViewModel({
    this.codigo,
    this.videId,
    this.videDescripcion,
    this.videImagenFactura,
    this.videMontoGastado,
    this.vienId,
    this.caviId,
    this.usuaCreacion,
    this.videFechaCreacion,
    this.usuaModificacion,
    this.videFechaModificacion,
    this.videMontoReconocido,
  });

  factory ViaticoDetViewModel.fromJson(Map<String, dynamic> json) {
    return ViaticoDetViewModel(
      codigo: json['codigo'],
      videId: json['vide_Id'],
      videDescripcion: json['vide_Descripcion'],
      videImagenFactura: json['vide_ImagenFactura'],
      videMontoGastado: json['vide_MontoGastado'],
      vienId: json['vien_Id'],
      caviId: json['cavi_Id'],
      usuaCreacion: json['usua_Creacion'],
      videFechaCreacion: json['vide_FechaCreacion'] != null
          ? DateTime.parse(json['vide_FechaCreacion'])
          : null,
      usuaModificacion: json['usua_Modificacion'],
      videFechaModificacion: json['vide_FechaModificacion'] != null
          ? DateTime.parse(json['vide_FechaModificacion'])
          : null,
      videMontoReconocido: json['vide_MontoReconocido']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'codigo': codigo,
      'vide_Id': videId,
      'vide_Descripcion': videDescripcion,
      'vide_ImagenFactura': videImagenFactura,
      'vide_MontoGastado': videMontoGastado,
      'vien_Id': vienId,
      'cavi_Id': caviId,
      'usua_Creacion': usuaCreacion,
      'vide_FechaCreacion': videFechaCreacion?.toIso8601String(),
      'usua_Modificacion': usuaModificacion,
      'vide_FechaModificacion': videFechaModificacion?.toIso8601String(),
      'vide_MontoReconocido': videMontoReconocido,
    };

    return data;
  }

  @override
  String toString() {
    return 'ViaticoDetViewModel(codigo: $codigo, videId: $videId, videDescripcion: $videDescripcion, '
        'videImagenFactura: $videImagenFactura, videMontoGastado: $videMontoGastado, vienId: $vienId, '
        'caviId: $caviId, usuaCreacion: $usuaCreacion, videFechaCreacion: $videFechaCreacion, '
        'usuaModificacion: $usuaModificacion, videFechaModificacion: $videFechaModificacion, '
        'videMontoReconocido: $videMontoReconocido)';
  }
}
