import 'package:sigesproc_app/models/proyectos/controlcalidadporactividadviewmodel.dart';

class ActividadesPorEtapaViewModel {
  int acetId;
  String? acetObservacion;
  int? acetCantidad;
  int? esprId;
  int? emplId;
  DateTime? acetFechaInicio;
  DateTime? acetFechaFin;
  double? acetPrecioManoObraEstimado;
  double? acetPrecioManoObraFinal;
  int? actiId;
  int? unmeId;
  int? etprId;
  int? usuaCreacion;
  DateTime? acetFechaCreacion;
  int? usuaModificacion;
  DateTime? acetFechaModificacion;
  bool? acetEstado;
  List<ListarControlDeCalidadesPorActividadesViewModel>? controlesCalidad;

  // NotMapped fields
  String? esprDescripcion;
  int? proyId;
  String? proyDescripcion;
  String? proyNombre;
  String? emplNombreCompleto;
  String? etapDescripcion;
  String? actiDescripcion;
  String? unmeNombre;
  String? unmeNomenclatura;

  ActividadesPorEtapaViewModel({
    required this.acetId,
    required this.acetObservacion,
    this.acetCantidad,
    this.esprId,
    this.emplId,
    this.acetFechaInicio,
    this.acetFechaFin,
    this.acetPrecioManoObraEstimado,
    this.acetPrecioManoObraFinal,
    this.actiId,
    this.unmeId,
    this.etprId,
    this.usuaCreacion,
    this.acetFechaCreacion,
    this.usuaModificacion,
    this.acetFechaModificacion,
    this.acetEstado,
    this.esprDescripcion,
    this.proyId,
    this.proyDescripcion,
    this.proyNombre,
    this.emplNombreCompleto,
    this.etapDescripcion,
    this.actiDescripcion,
    this.unmeNombre,
    this.unmeNomenclatura,
  });

  // Metodo de fábrica para crear una instancia de JSON
  factory ActividadesPorEtapaViewModel.fromJson(Map<String, dynamic> json) {
  return ActividadesPorEtapaViewModel(
    acetId: json['acet_Id'],
    acetObservacion: json['acet_Observacion'] ?? '',
    acetCantidad: json['acet_Cantidad'],
    esprId: json['espr_Id'],
    emplId: json['empl_Id'],
    acetFechaInicio: json['acet_FechaInicio'] != null ? DateTime.parse(json['acet_FechaInicio']) : null,
    acetFechaFin: json['acet_FechaFin'] != null ? DateTime.parse(json['acet_FechaFin']) : null,
    acetPrecioManoObraEstimado: json['acet_PrecioManoObraEstimado']?.toDouble(),
    acetPrecioManoObraFinal: json['acet_PrecioManoObraFinal']?.toDouble(),
    actiId: json['acti_Id'],
    unmeId: json['unme_Id'],
    etprId: json['etpr_Id'],
    usuaCreacion: json['usua_Creacion'],
    acetFechaCreacion: json['acet_FechaCreacion'] != null ? DateTime.parse(json['acet_FechaCreacion']) : null,
    usuaModificacion: json['usua_Modificacion'],
    acetFechaModificacion: json['acet_FechaModificacion'] != null ? DateTime.parse(json['acet_FechaModificacion']) : null,
    
    // Manejo de acetEstado para convertir 1/0/null a true/false
    acetEstado: json['acet_Estado'] == 1 ? true : (json['acet_Estado'] == 0 ? false : null),
    
    // Manejo de posibles nulls para Strings
    esprDescripcion: json['espr_Descripcion'] ?? '',
    proyId: json['proy_Id'],
    proyDescripcion: json['proy_Descripcion'] ?? '',
    proyNombre: json['proy_Nombre'] ?? '',
    emplNombreCompleto: json['empl_NombreCompleto'] ?? '',
    etapDescripcion: json['etap_Descripcion'] ?? '',
    actiDescripcion: json['acti_Descripcion'] ?? '',
    unmeNombre: json['unme_Nombre'] ?? '',
    unmeNomenclatura: json['unme_Nomenclatura'] ?? '',
  );
}

  Map<String, dynamic> toJson() {
    return {
      'acet_Id': acetId,
      'acet_Observacion': acetObservacion,
      'acet_Cantidad': acetCantidad,
      'espr_Id': esprId,
      'empl_Id': emplId,
      'acet_FechaInicio': acetFechaInicio?.toIso8601String(),
      'acet_FechaFin': acetFechaFin?.toIso8601String(),
      'acet_PrecioManoObraEstimado': acetPrecioManoObraEstimado,
      'acet_PrecioManoObraFinal': acetPrecioManoObraFinal,
      'acti_Id': actiId,
      'unme_Id': unmeId,
      'etpr_Id': etprId,
      'usua_Creacion': usuaCreacion,
      'acet_FechaCreacion': acetFechaCreacion?.toIso8601String(),
      'usua_Modificacion': usuaModificacion,
      'acet_FechaModificacion': acetFechaModificacion?.toIso8601String(),
      'acet_Estado': acetEstado,
      'espr_Descripcion': esprDescripcion,
      'proy_Id': proyId,
      'proy_Descripcion': proyDescripcion,
      'proy_Nombre': proyNombre,
      'empl_NombreCompleto': emplNombreCompleto,
      'etap_Descripcion': etapDescripcion,
      'acti_Descripcion': actiDescripcion,
      'unme_Nombre': unmeNombre,
      'unme_Nomenclatura': unmeNomenclatura,
    };
  }
}
