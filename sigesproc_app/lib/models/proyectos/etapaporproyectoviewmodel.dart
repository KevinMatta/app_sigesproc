import 'package:intl/intl.dart';

class EtapaPorProyectoViewModel {
  int etprId;
  int etapId;
  int proyId;
  int? usuaCreacion;
  DateTime? etprFechaCreacion;
  int? usuaModificacion;
  DateTime? etprFechaModificacion;
  bool? etprEstado;
  DateTime? etprFechaInicio;
  DateTime? etprFechaFin;

  // NotMapped fields
  String? usuaModificacionNombre;
  String? usuaCreacionNombre;
  int? codigo;
  String? etapDescripcion;
  String? proyNombre;
  String? actiDescripcion;

  EtapaPorProyectoViewModel({
    required this.etprId,
    required this.etapId,
    required this.proyId,
    this.usuaCreacion,
    this.etprFechaCreacion,
    this.usuaModificacion,
    this.etprFechaModificacion,
    this.etprEstado,
    this.etprFechaInicio,
    this.etprFechaFin,
    this.usuaModificacionNombre,
    this.usuaCreacionNombre,
    this.codigo,
    this.etapDescripcion,
    this.proyNombre,
    this.actiDescripcion,
  });

  factory EtapaPorProyectoViewModel.fromJson(Map<String, dynamic> json) {
    final dateFormat = DateFormat("MM/dd/yyyy HH:mm:ss");

    DateTime? parseDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return null;
      return dateFormat.parse(dateStr);
    }

    return EtapaPorProyectoViewModel(
      etprId: json['etpr_Id'],
      etapId: json['etap_Id'],
      proyId: json['proy_Id'],
      etprEstado: json['etpr_Estado'],
      usuaCreacion: json['usua_Creacion'],
      etprFechaCreacion: parseDate(json['etpr_FechaCreacion']),
      usuaModificacion: json['usua_Modificacion'],
      etprFechaModificacion: parseDate(json['etpr_FechaModificacion']),
      etprFechaInicio: parseDate(json['etpr_FechaInicio']),
      etprFechaFin: parseDate(json['etpr_FechaFin']),
      usuaModificacionNombre: json['UsuaModificacion'],
      usuaCreacionNombre: json['UsuaCreacion'],
      codigo: json['codigo'],
      etapDescripcion: json['etap_Descripcion'],
      proyNombre: json['proy_Nombre'],
      actiDescripcion: json['acti_Descripcion'],
    );
  }

  // Método para convertir una instancia a JSON
  Map<String, dynamic> toJson() {
    return {
      'etpr_Id': etprId,
      'etap_Id': etapId,
      'proy_Id': proyId,
      'etpr_Estado': etprEstado,
      'usua_Creacion': usuaCreacion,
      'etpr_FechaCreacion': etprFechaCreacion?.toIso8601String(),
      'usua_Modificacion': usuaModificacion,
      'etpr_FechaModificacion': etprFechaModificacion?.toIso8601String(),
      'etpr_FechaInicio': etprFechaInicio?.toIso8601String(),
      'etpr_FechaFin': etprFechaFin?.toIso8601String(),
      'UsuaModificacion': usuaModificacionNombre,
      'UsuaCreacion': usuaCreacionNombre,
      'codigo': codigo,
      'etap_Descripcion': etapDescripcion,
      'proy_Nombre': proyNombre,
      'acti_Descripcion': actiDescripcion,
    };
  }
}
