class ProyectoViewModel {
  final int proyId;
  final String proyNombre;
  final String proyDescripcion;
  final DateTime? proyFechaInicio;
  final DateTime? proyFechaFin;
  final String? proyDireccionExacta;
  final int? esprId;
  final int? clieId;
  final int? ciudId;
  final int? usuaCreacion;
  final DateTime? proyFechaCreacion;
  final int? usuaModificacion;
  final DateTime? proyFechaModificacion;
  final bool? proyEstado;

  ProyectoViewModel({
    required this.proyId,
    required this.proyNombre,
    required this.proyDescripcion,
    this.proyFechaInicio,
    this.proyFechaFin,
    this.proyDireccionExacta,
    this.esprId,
    this.ciudId,
    this.clieId,
    this.usuaCreacion,
    this.proyFechaCreacion,
    this.usuaModificacion,
    this.proyFechaModificacion,
    this.proyEstado,
  });

  factory ProyectoViewModel.fromJson(Map<String, dynamic> json) {
    return ProyectoViewModel(
      proyId: json['proy_Id'],
      proyNombre: json['proy_Nombre'],
      proyDescripcion: json['proy_Descripcion'],
      proyFechaInicio: json['proy_FechaInicio'] != null
          ? DateTime.parse(json['proy_FechaInicio'])
          : null,
      proyFechaFin: json['proy_FechaFin'] != null
          ? DateTime.parse(json['proy_FechaFin'])
          : null,
      proyDireccionExacta: json['proy_DireccionExacta'],
      esprId: json['espr_Id'],
      clieId: json['clie_Id'],
      ciudId: json['ciud_Id'],
      usuaCreacion: json['usua_Creacion'],
      proyFechaCreacion: json['proy_FechaCreacion'] != null
          ? DateTime.parse(json['proy_FechaCreacion'])
          : null,
      usuaModificacion: json['usua_Modificacion'],
      proyFechaModificacion: json['proy_FechaModificacion'] != null
          ? DateTime.parse(json['proy_FechaModificacion'])
          : null,
      proyEstado: json['proy_Estado'],
    );
  }
}
