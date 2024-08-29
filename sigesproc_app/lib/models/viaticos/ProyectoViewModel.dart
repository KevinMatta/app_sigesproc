class ProyectoViewModel {
  int? proyId;
  int? tiprId;
  String? proyNombre;
  String? proyDescripcion;
  DateTime? proyFechaInicio;
  DateTime? proyFechaFin;
  String? proyDireccionExacta;
  int? esprId;
  int? clieId;
  int? ciudId;
  int? usuaCreacion;
  DateTime? proyFechaCreacion;
  int? usuaModificacion;
  DateTime? proyFechaModificacion;
  bool? proyEstado;

  // NotMapped fields
  String? proyecto;
  String? usuaCreacionNombre;
  String? usuaModificacionNombre;
  String? estaNombre;
  String? paisNombre;
  String? ciudDescripcion;
  String? clieNombreCompleto;
  String? esprDescripcion;
  int? row;
  String? tiprDescripcion;

  ProyectoViewModel({
    this.proyId,
    this.tiprId,
    this.proyNombre,
    this.proyDescripcion,
    this.proyFechaInicio,
    this.proyFechaFin,
    this.proyDireccionExacta,
    this.esprId,
    this.clieId,
    this.ciudId,
    this.usuaCreacion,
    this.proyFechaCreacion,
    this.usuaModificacion,
    this.proyFechaModificacion,
    this.proyEstado,
    this.proyecto,
    this.usuaCreacionNombre,
    this.usuaModificacionNombre,
    this.estaNombre,
    this.paisNombre,
    this.ciudDescripcion,
    this.clieNombreCompleto,
    this.esprDescripcion,
    this.row,
    this.tiprDescripcion,
  });

  factory ProyectoViewModel.fromJson(Map<String, dynamic> json) {
    return ProyectoViewModel(
      proyId: json['proy_Id'],
      tiprId: json['tipr_Id'],
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
      proyecto: json['proyecto'],
      usuaCreacionNombre: json['usuaCreacion'],
      usuaModificacionNombre: json['usuaModificacion'],
      estaNombre: json['esta_Nombre'],
      paisNombre: json['pais_Nombre'],
      ciudDescripcion: json['ciud_Descripcion'],
      clieNombreCompleto: json['clie_NombreCompleto'],
      esprDescripcion: json['espr_Descripcion'],
      row: json['row'],
      tiprDescripcion: json['tipr_Descripcion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proy_Id': proyId,
      'tipr_Id': tiprId,
      'proy_Nombre': proyNombre,
      'proy_Descripcion': proyDescripcion,
      'proy_FechaInicio': proyFechaInicio?.toIso8601String(),
      'proy_FechaFin': proyFechaFin?.toIso8601String(),
      'proy_DireccionExacta': proyDireccionExacta,
      'espr_Id': esprId,
      'clie_Id': clieId,
      'ciud_Id': ciudId,
      'usua_Creacion': usuaCreacion,
      'proy_FechaCreacion': proyFechaCreacion?.toIso8601String(),
      'usua_Modificacion': usuaModificacion,
      'proy_FechaModificacion': proyFechaModificacion?.toIso8601String(),
      'proy_Estado': proyEstado,
      'proyecto': proyecto,
      'usuaCreacion': usuaCreacionNombre,
      'usuaModificacion': usuaModificacionNombre,
      'esta_Nombre': estaNombre,
      'pais_Nombre': paisNombre,
      'ciud_Descripcion': ciudDescripcion,
      'clie_NombreCompleto': clieNombreCompleto,
      'espr_Descripcion': esprDescripcion,
      'row': row,
      'tipr_Descripcion': tiprDescripcion,
    };
  }
}
