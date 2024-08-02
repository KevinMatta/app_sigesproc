class BodegaViewModel {
  int? bodeId;
  final String? bodeDescripcion;
  final String? bodeLatitud;
  final String? bodeLongitud;
  final String? bodeLinkUbicacion;
  final int? usuaCreacion;
  final DateTime? bodeFechaCreacion;
  final int? usuaModificacion;
  final DateTime? bodeFechaModificacion;
  final bool? bodeEstado;
  final String? ciudad;
  final String? pais;

  BodegaViewModel({
    this.bodeId,
    this.bodeDescripcion,
    this.bodeLatitud,
    this.bodeLongitud,
    this.bodeLinkUbicacion,
    this.usuaCreacion,
    this.bodeFechaCreacion,
    this.usuaModificacion,
    this.bodeFechaModificacion,
    this.bodeEstado,
    this.ciudad,
    this.pais,
  });

  factory BodegaViewModel.fromJson(Map<String, dynamic> json) {
    return BodegaViewModel(
      bodeId: json['bode_Id'],
      bodeDescripcion: json['bode_Descripcion'],
      bodeLatitud: json['bode_Latitud'],
      bodeLongitud: json['bode_Longitud'],
      bodeLinkUbicacion: json['bode_LinkUbicacion'],
      usuaCreacion: json['usua_Creacion'],
      bodeFechaCreacion: json['bode_FechaCreacion'] != null
          ? DateTime.parse(json['bode_FechaCreacion'])
          : null,
      usuaModificacion: json['usua_Modificacion'],
      bodeFechaModificacion: json['bode_FechaModificiacion'] != null
          ? DateTime.parse(json['bode_FechaModificiacion'])
          : null,
      bodeEstado: json['bode_Estado'],
      ciudad: json['ciudad'],
      pais: json['pais'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bode_Id': bodeId,
      'bode_Descripcion': bodeDescripcion,
      'bode_Latitud': bodeLatitud,
      'bode_Longitud': bodeLongitud,
      'bode_LinkUbicacion': bodeLinkUbicacion,
      'usua_Creacion': usuaCreacion,
      'bode_FechaCreacion': bodeFechaCreacion?.toIso8601String(),
      'usua_Modificacion': usuaModificacion,
      'bode_FechaModificiacion': bodeFechaModificacion?.toIso8601String(),
      'bode_Estado': bodeEstado,
      'ciudad': ciudad,
      'pais': pais,
    };
  }
}
