class FleteEncabezadoViewModel {
  String? codigo;
  String? usuarioCreacion;
  String? usuarioModificacion;
  String? encargado;
  String? supervisorLlegada;
  String? supervisorSalida;
  String? destino;
  String? estado;
  String? salida;
  String? boatDescripcion;
  int? flenId;
  DateTime? flenFechaHoraSalida;
  DateTime? flenFechaHoraEstablecidaDeLlegada;
  DateTime? flenFechaHoraLlegada;
  String? flenComprobanteLLegada;
  bool? flenEstado;
  bool? flenDestinoProyecto;
  bool? flenSalidaProyecto;
  int? proyIdSalida;
  int? proyIdLlegada;
  int? boasId;
  int? boatId;
  int? proyId;
  int? proyIdSalidaa;
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
    this.codigo,
    this.usuarioCreacion,
    this.usuarioModificacion,
    this.encargado,
    this.supervisorLlegada,
    this.supervisorSalida,
    this.destino,
    this.estado,
    this.salida,
    this.boatDescripcion,
    this.flenId,
    this.flenFechaHoraSalida,
    this.flenFechaHoraEstablecidaDeLlegada,
    this.flenFechaHoraLlegada,
    this.flenComprobanteLLegada,
    this.flenEstado,
    this.flenDestinoProyecto,
    this.flenSalidaProyecto,
    this.proyIdSalida,
    this.proyIdLlegada,
    this.boasId,
    this.boatId,
    this.proyId,
    this.proyIdSalidaa,
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
      boatDescripcion: json['boat_Descripcion'],
      destino: json['destino'],
      estado: json['estado'],
      salida: json['salida'],
      flenId: json['flen_Id'],
      flenFechaHoraSalida: json['flen_FechaHoraSalida'] != null
          ? DateTime.parse(json['flen_FechaHoraSalida'])
          : null,
      flenFechaHoraEstablecidaDeLlegada:
          json['flen_FechaHoraEstablecidaDeLlegada'] != null
              ? DateTime.parse(json['flen_FechaHoraEstablecidaDeLlegada'])
              : null,
      flenFechaHoraLlegada: json['flen_FechaHoraLlegada'] != null
          ? DateTime.parse(json['flen_FechaHoraLlegada'])
          : null,
      flenComprobanteLLegada: json['flen_ComprobanteLLegada'],
      flenEstado: json['flen_Estado'],
      flenDestinoProyecto: json['flen_DestinoProyecto'],
      flenSalidaProyecto: json['flen_SalidaProyecto'],
      boasId: json['boas_Id'],
      boatId: json['boat_Id'],
      proyId: json['proy_Id'],
      proyIdSalidaa: json['proy_IdSalida'],
      emtrId: json['emtr_Id'],
      emssId: json['emss_Id'],
      emslId: json['emsl_Id'],
      usuaCreacion: json['usua_Creacion'],
      flenFechaCreacion: json['flen_FechaCreacion'] != null
          ? DateTime.parse(json['flen_FechaCreacion'])
          : null,
      usuaModificacion: json['usua_Modificacion'],
      flenFechaModificacion: json['flen_FechaModificacion'] != null
          ? DateTime.parse(json['flen_FechaModificacion'])
          : null,
      flenEstadoFlete: json['flen_EstadoFlete'],
      inppObservacion: json['inpp_Observacion'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'codigo': codigo,
      'usuarioCreacion': usuarioCreacion,
      'usuarioModificacion': usuarioModificacion,
      'encargado': encargado,
      'supervisorLlegada': supervisorLlegada,
      'supervisorSalida': supervisorSalida,
      'destino': destino,
      'estado': estado,
      'salida': salida,
      'boat_Descripcion': boatDescripcion,
      'flen_FechaHoraSalida': flenFechaHoraSalida?.toIso8601String(),
      'flen_FechaHoraEstablecidaDeLlegada':
          flenFechaHoraEstablecidaDeLlegada?.toIso8601String(),
      'flen_Estado': flenEstado,
      'flen_DestinoProyecto': flenDestinoProyecto,
      'flen_SalidaProyecto': flenSalidaProyecto,
      'boas_Id': boasId,
      'boat_Id': boatId,
      'emtr_Id': emtrId,
      'emss_Id': emssId,
      'emsl_Id': emslId,
      'usua_Creacion': usuaCreacion,
      'usua_Modificacion': usuaModificacion,
      'flen_EstadoFlete': flenEstadoFlete,
      'inpp_Observacion': inppObservacion,
    };

    if (flenId != null) {
      data['flen_Id'] = flenId;
    }
    if (flenComprobanteLLegada != null) {
      data['flen_ComprobanteLLegada'] = flenComprobanteLLegada;
    }

    if (flenFechaHoraLlegada != null) {
      data['flen_FechaHoraLlegada'] = flenFechaHoraLlegada?.toIso8601String();
    }

    if (flenFechaCreacion != null) {
      data['flen_FechaCreacion'] = flenFechaCreacion?.toIso8601String();
    }

    if (flenFechaModificacion != null) {
      data['flen_FechaModificacion'] = flenFechaModificacion?.toIso8601String();
    }

    return data;
  }

  @override
  String toString() {
    return 'FleteEncabezadoViewModel(cdifo:$codigo, flenId: $flenId, flenestadofelte: $flenEstadoFlete, flenFechaHoraSalida: $flenFechaHoraSalida, flenFechaHoraLlegada: $flenFechaHoraLlegada, flenFechaHoraEstablecidaDeLlegada: $flenFechaHoraEstablecidaDeLlegada, flencomprobantellegada: $flenComprobanteLLegada, emtrId: $emtrId, emssId: $emssId, emslId: $emslId, boasId: $boasId, boatId: $boatId, boatdescripcion: $boatDescripcion, flenEstado: $flenEstado, flenDestinoProyecto: $flenDestinoProyecto, flensalidaproyecto: $flenSalidaProyecto, usuaCreacion: $usuaCreacion, flenFechaCreacion: $flenFechaCreacion, usuaModificacion: $usuaModificacion, flenFechaModificacion: $flenFechaModificacion';
  }
}
