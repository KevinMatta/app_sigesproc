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
  double? videMontoReconocido;

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

Map<String, dynamic> toJson({bool isEditing = false}) {
  final Map<String, dynamic> data = {
    'vide_Id': videId ?? 0,  // Asegúrate de incluir el vide_Id
    'vide_Descripcion': videDescripcion ?? '',
    'vide_ImagenFactura': videImagenFactura ?? '',  // Incluir vide_ImagenFactura
    'vide_MontoGastado': videMontoGastado ?? '',
    'vien_Id': vienId ?? 0,
    'cavi_Id': caviId ?? 0,
    'usua_Creacion': usuaCreacion ?? 0,
    'vide_FechaCreacion': videFechaCreacion?.toIso8601String(),
    'vide_MontoReconocido': videMontoReconocido ?? 0.0,
  };

  // Si estamos en modo edición, añadimos los campos de modificación
  if (isEditing) {
    data['usua_Modificacion'] = usuaModificacion ?? 0;
    data['vide_FechaModificacion'] = videFechaModificacion?.toIso8601String() ?? DateTime.now().toIso8601String();
  }

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
