class BodegaViewModel {
  final int bodeId;
  final String bodeDescripcion;
  final int? usuaCreacion;
  final DateTime? bodeFechaCreacion;
  final int? usuaModificacion;
  final DateTime? bodeFechaModificiacion;
  final bool? bodeEstado;
  final String? bodeLatitud;
  final String? bodeLongitud;
  final String? bodeLinkUbicacion;
  final String? ciudDescripcion;

  BodegaViewModel({
    required this.bodeId,
    required this.bodeDescripcion,
    this.usuaCreacion,
    this.bodeFechaCreacion,
    this.usuaModificacion,
    this.bodeFechaModificiacion,
    this.bodeEstado,
    this.bodeLatitud,
    this.bodeLongitud,
    this.bodeLinkUbicacion,
    this.ciudDescripcion,
  });

  factory BodegaViewModel.fromJson(Map<String, dynamic> json) {
    return BodegaViewModel(
      bodeId: json['bode_Id'],
      bodeDescripcion: json['bode_Descripcion'],
      usuaCreacion: json['usua_Creacion'],
      bodeFechaCreacion: json['bode_FechaCreacion'] != null
          ? DateTime.parse(json['bode_FechaCreacion'])
          : null,
      usuaModificacion: json['usua_Modificacion'],
      bodeFechaModificiacion: json['bode_FechaModificiacion'] != null
          ? DateTime.parse(json['bode_FechaModificiacion'])
          : null,
      bodeEstado: json['bode_Estado'],
      bodeLatitud: json['bode_Latitud'],
      bodeLongitud: json['bode_Longitud'],
      bodeLinkUbicacion: json['bode_LinkUbicacion'],
      ciudDescripcion: json['ciud_Descripcion'],
    );
  }
}
