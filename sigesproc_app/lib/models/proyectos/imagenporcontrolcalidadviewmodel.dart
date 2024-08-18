class ImagenPorControlCalidadViewModel {
  // int? iccaId;
  String iccaImagen;
  int usuaCreacion;
  DateTime iccaFechaCreacion;
  int? usuaModificacion;
  DateTime? iccaFechaModificacion;
  bool? iccaEstado;
  int cocaId;

  ImagenPorControlCalidadViewModel({
    // this.iccaId,
    required this.iccaImagen,
    required this.usuaCreacion,
    required this.iccaFechaCreacion,
    this.usuaModificacion,
    this.iccaFechaModificacion,
    this.iccaEstado,
    required this.cocaId,
  });

  Map<String, dynamic> toJson() {
    return {
      // 'icca_Id': iccaId,
      'icca_Imagen': iccaImagen,
      'usua_Creacion': usuaCreacion,
      'icca_FechaCreacion': iccaFechaCreacion.toIso8601String(),
      'usua_Modificacion': usuaModificacion,
      'icca_FechaModificacion': iccaFechaModificacion?.toIso8601String(),
      'icca_Estado': iccaEstado == true ? 1 : (iccaEstado == false ? 0 : null),
      'coca_Id': cocaId,
    };
  }

  factory ImagenPorControlCalidadViewModel.fromJson(Map<String, dynamic> json) {
    return ImagenPorControlCalidadViewModel(
      // iccaId: json['icca_Id'],
      iccaImagen: json['icca_Imagen'] ?? '',  // Manejo de nulo con valor por defecto
      usuaCreacion: json['usua_Creacion'],
      iccaFechaCreacion: DateTime.parse(json['icca_FechaCreacion']),
      usuaModificacion: json['usua_Modificacion'],
      iccaFechaModificacion: json['icca_FechaModificacion'] != null
          ? DateTime.parse(json['icca_FechaModificacion'])
          : null,
      iccaEstado: json['icca_Estado'] == 1 ? true : (json['icca_Estado'] == 0 ? false : null),
      cocaId: json['coca_Id'],
    );
  }
}
