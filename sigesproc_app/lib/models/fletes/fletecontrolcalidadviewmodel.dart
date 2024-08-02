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
  final String? flenEstado;
  final String? flenDestinoProyecto;

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
    return {
      'flcc_Id': flccId,
      'flcc_DescripcionIncidencia': flccDescripcionIncidencia,
      'flcc_FechaHoraIncidencia': flccFechaHoraIncidencia?.toIso8601String(),
      'flen_Id': flenId,
      'usua_Creacion': usuaCreacion,
      'flcc_FechaCreacion': flccFechaCreacion?.toIso8601String(),
      'usua_Modificacion': usuaModificacion,
      'flcc_FechaModificacion': flccFechaModificacion?.toIso8601String(),
      'flcc_Estado': flccEstado,
      'flen_FechaHoraSalida': flenFechaHoraSalida?.toIso8601String(),
      'flen_FechaHoraEstablecidaDeLlegada': flenFechaHoraEstablecidaDeLlegada?.toIso8601String(),
      'flen_Estado': flenEstado,
      'flen_DestinoProyecto': flenDestinoProyecto,
    };
  }
}
