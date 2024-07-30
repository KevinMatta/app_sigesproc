class BienRaizViewModel {
  int codigo;
  int bienId;
  int? pconId;
  String? bienDescripcion;
  int? terrId;
  String? terrArea;
  String? terrLinkUbicacion;
  int? usuaCreacion;
  String? usuaaCreacion;
  DateTime? bienFechaCreacion;
  int? usuaModificacion;
  String? usuaaModificacion;
  DateTime? bienFechaModificacion;
  String? bienImagen;
  bool? bienEstado;

  BienRaizViewModel({
    required this.codigo,
    required this.bienId,
    this.pconId,
    this.bienDescripcion,
    this.terrId,
    this.terrArea,
    this.terrLinkUbicacion,
    this.usuaCreacion,
    this.usuaaCreacion,
    this.bienFechaCreacion,
    this.usuaModificacion,
    this.usuaaModificacion,
    this.bienFechaModificacion,
    this.bienImagen,
    this.bienEstado,
  });

  factory BienRaizViewModel.fromJson(Map<String, dynamic> json) {
    return BienRaizViewModel(
      codigo: json['codigo'],
      bienId: json['bien_Id'],
      pconId: json['pcon_Id'],
      bienDescripcion: json['bien_Descripcion'],
      terrId: json['terr_Id'],
      terrArea: json['terr_Area'],
      terrLinkUbicacion: json['terr_LinkUbicacion'],
      usuaCreacion: json['usua_Creacion'],
      usuaaCreacion: json['usuaCreacion'],
      bienFechaCreacion: json['bien_FechaCreacion'] != null ? DateTime.parse(json['bien_FechaCreacion']) : null,
      usuaModificacion: json['usua_Modificacion'],
      usuaaModificacion: json['usuaModificacion'],
      bienFechaModificacion: json['bien_FechaModificacion'] != null ? DateTime.parse(json['bien_FechaModificacion']) : null,
      bienImagen: json['bien_Imagen'],
      bienEstado: json['bien_Estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'bien_Id': bienId,
      'prov_Id': pconId,
      'prov_Descripcion': bienDescripcion,
      'empl_Id': terrId,
      'terrArea': terrArea,
      'bien_Impuesto': terrLinkUbicacion,
      'usua_Creacion': usuaCreacion,
      'usuaCreacion': usuaaCreacion,
      'bien_FechaCreacion': bienFechaCreacion?.toIso8601String(),
      'usua_Modificacion': usuaModificacion,
      'usuaModificacion': usuaaModificacion,
      'bien_FechaModificacion': bienFechaModificacion?.toIso8601String(),
      'bien_Imagen': bienImagen,
      'bien_Estado': bienEstado,
    };
  }
}
