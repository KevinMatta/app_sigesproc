class ControlDeCalidadesPorActividadesViewModel {
  int? coacId;
  int? codigo;
  int cocaId;
  String cocaDescripcion;
  DateTime cocaFecha;
  int usuaCreacion;
  DateTime cocaFechaCreacion;
  int? usuaModificacion;
  DateTime? cocaFechaModificacion;
  bool? cocaEstado;
  int? acetId;
  double? cocaMetrosTrabajados;
  String cocaResultado;
  String? actiDescripcion;
  int? acetCantidad;
  String? usuaCreacionNombre;
  String? usuaModificacionNombre;

  ControlDeCalidadesPorActividadesViewModel({
    this.coacId,
    this.codigo,
    required this.cocaId,
    required this.cocaDescripcion,
    required this.cocaFecha,
    required this.usuaCreacion,
    required this.cocaFechaCreacion,
    this.usuaModificacion,
    this.cocaFechaModificacion,
    this.cocaEstado,
    this.acetId,
    this.cocaMetrosTrabajados,
    required this.cocaResultado,
    this.actiDescripcion,
    this.acetCantidad,
    this.usuaCreacionNombre,
    this.usuaModificacionNombre,
  });

  factory ControlDeCalidadesPorActividadesViewModel.fromJson(Map<String, dynamic> json) {
    return ControlDeCalidadesPorActividadesViewModel(
      coacId: json['coac_Id'],
      codigo: json['codigo'],
      cocaId: json['coca_Id'],
      cocaDescripcion: json['coca_Descripcion'],
      cocaFecha: DateTime.parse(json['coca_Fecha']),
      usuaCreacion: json['usua_Creacion'],
      cocaFechaCreacion: DateTime.parse(json['coca_FechaCreacion']),
      usuaModificacion: json['usua_Modificacion'],
      cocaFechaModificacion: json['coca_FechaModificacion'] != null 
          ? DateTime.parse(json['coca_FechaModificacion']) 
          : null,
      cocaEstado: json['coca_Estado'],
      acetId: json['acet_Id'],
      cocaMetrosTrabajados: json['coca_MetrosTrabajados'] != null 
          ? json['coca_MetrosTrabajados'].toDouble() 
          : null,
      cocaResultado: json['coca_Resultado'],
      actiDescripcion: json['acti_Descripcion'],
      acetCantidad: json['acet_Cantidad'],
      usuaCreacionNombre: json['usuaCreacion'],
      usuaModificacionNombre: json['usuaModificacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coac_Id': coacId,
      'codigo': codigo,
      'coca_Id': cocaId,
      'coca_Descripcion': cocaDescripcion,
      'coca_Fecha': cocaFecha.toIso8601String(),
      'usua_Creacion': usuaCreacion,
      'coca_FechaCreacion': cocaFechaCreacion.toIso8601String(),
      'usua_Modificacion': usuaModificacion,
      'coca_FechaModificacion': cocaFechaModificacion?.toIso8601String(),
      'coca_Estado': cocaEstado,
      'acet_Id': acetId,
      'coca_MetrosTrabajados': cocaMetrosTrabajados,
      'coca_Resultado': cocaResultado,
      'acti_Descripcion': actiDescripcion,
      'acet_Cantidad': acetCantidad,
      'usuaCreacion': usuaCreacionNombre,
      'usuaModificacion': usuaModificacionNombre,
    };
  }
}
