class FleteControlCalidadViewModel {
  final int? flccId;
  final String? flccDescripcionIncidencia;
  final DateTime? flccFechaHoraIncidencia;
  final int? flenId;
  final int? usuaCreacion;
  final DateTime? flccFechaCreacion;
  final int? usuaModificacion;
  final DateTime? flccFechaModificacion;
  final bool? flccEstado;
  final DateTime? flenFechaHoraSalida;
  final DateTime? flenFechaHoraEstablecidaDeLlegada;
  final bool? flenEstado;
  final bool? flenDestinoProyecto;

  FleteControlCalidadViewModel({
    this.flccId,
    this.flccDescripcionIncidencia,
    this.flccFechaHoraIncidencia,
    this.flenId,
    this.usuaCreacion,
    this.flccFechaCreacion,
    this.usuaModificacion,
    this.flccFechaModificacion,
    this.flccEstado,
    this.flenFechaHoraSalida,
    this.flenFechaHoraEstablecidaDeLlegada,
    this.flenEstado,
    this.flenDestinoProyecto,
  });

  factory FleteControlCalidadViewModel.fromJson(Map<String, dynamic> json) {
    return FleteControlCalidadViewModel(
      flccId: json['flcc_Id'],
      flccDescripcionIncidencia: json['flcc_DescripcionIncidencia'],
      flccFechaHoraIncidencia: json['flcc_FechaHoraIncidencia'] != null ? DateTime.parse(json['flcc_FechaHoraIncidencia']) : null,
      flenId: json['flen_Id'],
      usuaCreacion: json['usua_Creacion'],
      flccFechaCreacion: json['flcc_FechaCreacion'] != null ? DateTime.parse(json['flcc_FechaCreacion']) : null,
      usuaModificacion: json['usua_Modificacion'],
      flccFechaModificacion: json['flcc_FechaModificacion'] != null ? DateTime.parse(json['flcc_FechaModificacion']) : null,
      flccEstado: json['flcc_Estado'],
      flenFechaHoraSalida: json['flen_FechaHoraSalida'] != null ? DateTime.parse(json['flen_FechaHoraSalida']) : null,
      flenFechaHoraEstablecidaDeLlegada: json['flen_FechaHoraEstablecidaDeLlegada'] != null ? DateTime.parse(json['flen_FechaHoraEstablecidaDeLlegada']) : null,
      flenEstado: json['flen_Estado'],
      flenDestinoProyecto: json['flen_DestinoProyecto'],
    );
  }

Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = {};

  if (flccDescripcionIncidencia != null) {
    data['flcc_DescripcionIncidencia'] = flccDescripcionIncidencia;
  }
  if (flccFechaHoraIncidencia != null) {
    data['flcc_FechaHoraIncidencia'] = flccFechaHoraIncidencia?.toIso8601String();
  }
  if (flenId != null) {
    data['flen_Id'] = flenId;
  }
  if (usuaCreacion != null) {
    data['usua_Creacion'] = usuaCreacion;
  }
  if (flccFechaCreacion != null) {
    data['flcc_FechaCreacion'] = flccFechaCreacion?.toIso8601String();
  }
  if (usuaModificacion != null) {
    data['usua_Modificacion'] = usuaModificacion;
  }
  if (flccFechaModificacion != null) {
    data['flcc_FechaModificacion'] = flccFechaModificacion?.toIso8601String();
  }
  if (flccEstado != null) {
    data['flcc_Estado'] = flccEstado;
  }
  if (flenFechaHoraSalida != null) {
    data['flen_FechaHoraSalida'] = flenFechaHoraSalida?.toIso8601String();
  }
  if (flenFechaHoraEstablecidaDeLlegada != null) {
    data['flen_FechaHoraEstablecidaDeLlegada'] = flenFechaHoraEstablecidaDeLlegada?.toIso8601String();
  }
  if (flenEstado != null) {
    data['flen_Estado'] = flenEstado;
  }
  if (flenDestinoProyecto != null) {
    data['flen_DestinoProyecto'] = flenDestinoProyecto;
  }
  if (flccId != null) {
    data['flcc_Id'] = flccId;
  }

  return data;
}

    @override
  String toString() {
    return 'contolcalidadViewModel(flccid: $flccId, descripcioninci $flccDescripcionIncidencia, fechahorainci $flccFechaHoraIncidencia, flenid: $flenId, usuacreac: $usuaCreacion, usuamod: $usuaModificacion';
  }
}
