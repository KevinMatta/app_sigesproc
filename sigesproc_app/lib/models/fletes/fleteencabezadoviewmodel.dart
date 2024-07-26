class FleteEncabezadoViewModel {
  final String codigo;
  final String? usuarioCreacion;
  final String? usuarioModificacion;
  final String? encargado;
  final String? supervisorLlegada;
  final String? supervisorSalida;
  final String? destino;
  final String? estado;
  final String? salida;
  final int? flenId;
  final DateTime? flenFechaHoraSalida;
  final DateTime? flenFechaHoraEstablecidaDeLlegada;
  final DateTime? flenFechaHoraLlegada;
  final bool? flenEstado;
  final bool? flenDestinoProyecto;
  final int? bollId;
  final int? boprId;
  final int? emtrId;
  final int? emssId;
  final int? emslId;
  final int? usuaCreacion;
  final DateTime? flenFechaCreacion;
  final int? usuaModificacion;
  final DateTime? flenFechaModificacion;
  final bool? flenEstadoFlete;

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
    );
  }
}
