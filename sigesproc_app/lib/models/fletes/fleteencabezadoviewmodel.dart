class FleteEncabezadoViewModel {
  String codigo;
  String? usuarioCreacion;
  String? usuarioModificacion;
  String? encargado;
  String? supervisorLlegada;
  String? supervisorSalida;
  String? destino;
  String? estado;
  String? salida;
  int? flenId;
  DateTime? flenFechaHoraSalida;
  DateTime? flenFechaHoraEstablecidaDeLlegada;
  DateTime? flenFechaHoraLlegada;
  bool? flenEstado;
  bool? flenDestinoProyecto;
  int? bollId;
  int? boprId;
  int? emtrId;
  int? emssId;
  int? emslId;
  int? usuaCreacion;
  DateTime? flenFechaCreacion;
  int? usuaModificacion;
  DateTime? flenFechaModificacion;
  int? flenEstadoFlete;
  String? inppObservacion;

  FleteEncabezadoViewModel({
    required this.codigo,
    this.usuarioCreacion,
    this.usuarioModificacion,
    this.encargado,
    this.supervisorLlegada,
    this.supervisorSalida,
    this.destino,
    this.estado,
    this.salida,
    this.flenId,
    this.flenFechaHoraSalida,
    this.flenFechaHoraEstablecidaDeLlegada,
    this.flenFechaHoraLlegada,
    this.flenEstado,
    this.flenDestinoProyecto,
    this.bollId,
    this.boprId,
    this.emtrId,
    this.emssId,
    this.emslId,
    this.usuaCreacion,
    this.flenFechaCreacion,
    this.usuaModificacion,
    this.flenFechaModificacion,
    this.flenEstadoFlete,
    this.inppObservacion,
  });

  factory FleteEncabezadoViewModel.fromJson(Map<String, dynamic> json) {
    return FleteEncabezadoViewModel(
      codigo: json['codigo'],
      usuarioCreacion: json['usuarioCreacion'],
      usuarioModificacion: json['usuarioModificacion'],
      encargado: json['encargado'],
      supervisorLlegada: json['supervisorllegada'],
      supervisorSalida: json['supervisorsalida'],
      destino: json['destino'],
      estado: json['estado'],
      salida: json['salida'],
      flenId: json['flen_Id'],
      flenFechaHoraSalida: json['flen_FechaHoraSalida'] != null ? DateTime.parse(json['flen_FechaHoraSalida']) : null,
      flenFechaHoraEstablecidaDeLlegada: json['flen_FechaHoraEstablecidaDeLlegada'] != null ? DateTime.parse(json['flen_FechaHoraEstablecidaDeLlegada']) : null,
      flenFechaHoraLlegada: json['flen_FechaHoraLlegada'] != null ? DateTime.parse(json['flen_FechaHoraLlegada']) : null,
      flenEstado: json['flen_Estado'],
      flenDestinoProyecto: json['flen_DestinoProyecto'],
      bollId: json['boll_Id'],
      boprId: json['bopr_Id'],
      emtrId: json['emtr_Id'],
      emssId: json['emss_Id'],
      emslId: json['emsl_Id'],
      usuaCreacion: json['usua_Creacion'],
      flenFechaCreacion: json['flen_FechaCreacion'] != null ? DateTime.parse(json['flen_FechaCreacion']) : null,
      usuaModificacion: json['usua_Modificacion'],
      flenFechaModificacion: json['flen_FechaModificacion'] != null ? DateTime.parse(json['flen_FechaModificacion']) : null,
      flenEstadoFlete: json['flen_EstadoFlete'],
      inppObservacion: json['inpp_Observacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'usuarioCreacion': usuarioCreacion,
      'usuarioModificacion': usuarioModificacion,
      'encargado': encargado,
      'supervisorLlegada': supervisorLlegada,
      'supervisorSalida': supervisorSalida,
      'destino': destino,
      'estado': estado,
      'salida': salida,
      'flen_Id': flenId,
      'flen_FechaHoraSalida': flenFechaHoraSalida?.toIso8601String(),
      'flen_FechaHoraEstablecidaDeLlegada': flenFechaHoraEstablecidaDeLlegada?.toIso8601String(),
      'flen_FechaHoraLlegada': flenFechaHoraLlegada?.toIso8601String(),
      'flen_Estado': flenEstado,
      'flen_DestinoProyecto': flenDestinoProyecto,
      'boll_Id': bollId,
      'bopr_Id': boprId,
      'emtr_Id': emtrId,
      'emss_Id': emssId,
      'emsl_Id': emslId,
      'usua_Creacion': usuaCreacion,
      'flen_FechaCreacion': flenFechaCreacion?.toIso8601String(),
      'usua_Modificacion': usuaModificacion,
      'flen_FechaModificacion': flenFechaModificacion?.toIso8601String(),
      'flen_EstadoFlete': flenEstadoFlete,
      'inpp_Observacion': inppObservacion,
    };
  }
}
