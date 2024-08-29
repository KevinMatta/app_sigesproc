class CategoriaVaticoViewModel {
  int? caviId;
  String? caviDescripcion;
  int? usuaCreacion;
  DateTime? caviFechaCreacion;
  int? usuaModificacion;
  DateTime? caviFechaModificacion;
  bool? caviEstado;

  // NotMapped fields
  String? usuarioCreacion;
  String? usuarioModificacion;
  String? codigo;

  CategoriaVaticoViewModel({
    this.caviId,
    this.caviDescripcion,
    this.usuaCreacion,
    this.caviFechaCreacion,
    this.usuaModificacion,
    this.caviFechaModificacion,
    this.caviEstado,
    this.usuarioCreacion,
    this.usuarioModificacion,
    this.codigo,
  });

  factory CategoriaVaticoViewModel.fromJson(Map<String, dynamic> json) {
    return CategoriaVaticoViewModel(
      caviId: json['cavi_Id'],
      caviDescripcion: json['cavi_Descripcion'],
      usuaCreacion: json['usua_Creacion'],
      caviFechaCreacion: json['cavi_FechaCreacion'] != null
          ? DateTime.parse(json['cavi_FechaCreacion'])
          : null,
      usuaModificacion: json['usua_Modificacion'],
      caviFechaModificacion: json['cavi_FechaModificacion'] != null
          ? DateTime.parse(json['cavi_FechaModificacion'])
          : null,
      caviEstado: json['cavi_Estado'],
      usuarioCreacion: json['usuarioCreacion'],
      usuarioModificacion: json['usuarioModificacion'],
      codigo: json['codigo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cavi_Id': caviId,
      'cavi_Descripcion': caviDescripcion,
      'usua_Creacion': usuaCreacion,
      'cavi_FechaCreacion': caviFechaCreacion?.toIso8601String(),
      'usua_Modificacion': usuaModificacion,
      'cavi_FechaModificacion': caviFechaModificacion?.toIso8601String(),
      'cavi_Estado': caviEstado,
      'usuarioCreacion': usuarioCreacion,
      'usuarioModificacion': usuarioModificacion,
      'codigo': codigo,
    };
  }
}
