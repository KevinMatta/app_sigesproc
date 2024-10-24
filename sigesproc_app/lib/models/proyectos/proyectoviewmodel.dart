class ProyectoViewModel {
  int proyId;
  String? proyNombre;
  String? proyDescripcion;
  DateTime? proyFechaInicio;
  DateTime? proyFechaFin;
  String? proyDireccionExacta;
  String? proyLinkUbicacion;
  String? iccaImagen;
  int? esprId;
  int? clieId;
  int? ciudId;
  int? usuaCreacion;
  DateTime? proyFechaCreacion;
  int? usuaModificacion;
  DateTime? proyFechaModificacion;
  bool? proyEstado;
  String? usuaCreacionNombre;
  String? usuaModificacionNombre;
  String? estaNombre;
  String? paisNombre;
  String? ciudDescripcion;
  String? clieNombreCompleto;
  String? esprDescripcion;
  String? proyProgreso;

  ProyectoViewModel({
    required this.proyId,
    this.proyNombre,
    this.proyDescripcion,
    this.proyFechaInicio,
    this.proyFechaFin,
    this.proyDireccionExacta,
    this.proyLinkUbicacion,
    this.iccaImagen,
    this.esprId,
    this.ciudId,
    this.clieId,
    this.usuaCreacion,
    this.proyFechaCreacion,
    this.usuaModificacion,
    this.proyFechaModificacion,
    this.proyEstado,
    this.usuaCreacionNombre,
    this.usuaModificacionNombre,
    this.estaNombre,
    this.paisNombre,
    this.ciudDescripcion,
    this.clieNombreCompleto,
    this.esprDescripcion,
    this.proyProgreso,
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
      proyLinkUbicacion: json['proy_LinkUbicacion'],
      iccaImagen: json['icca_Imagen'],
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
      usuaCreacionNombre: json['usuaCreacion'],
      usuaModificacionNombre: json['usuaModificacion'],
      estaNombre: json['esta_Nombre'],
      paisNombre: json['pais_Nombre'],
      ciudDescripcion: json['ciud_Descripcion'],
      clieNombreCompleto: json['clie_NombreCompleto'],
      esprDescripcion: json['espr_Descripcion'],
      proyProgreso: json['proy_Progreso'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proy_Id': proyId,
      'proy_Nombre': proyNombre,
      'proy_Descripcion': proyDescripcion,
      'proy_FechaInicio': proyFechaInicio?.toIso8601String(),
      'proy_FechaFin': proyFechaFin?.toIso8601String(),
      'proy_DireccionExacta': proyDireccionExacta,
      'proy_LinkUbicacion': proyLinkUbicacion,
      'icca_Imagen': iccaImagen,
      'espr_Id': esprId,
      'clie_Id': clieId,
      'ciud_Id': ciudId,
      'usua_Creacion': usuaCreacion,
      'proy_FechaCreacion': proyFechaCreacion?.toIso8601String(),
      'usua_Modificacion': usuaModificacion,
      'proy_FechaModificacion': proyFechaModificacion?.toIso8601String(),
      'proy_Estado': proyEstado,
      'usuaCreacion': usuaCreacionNombre,
      'usuaModificacion': usuaModificacionNombre,
      'esta_Nombre': estaNombre,
      'pais_Nombre': paisNombre,
      'ciud_Descripcion': ciudDescripcion,
      'clie_NombreCompleto': clieNombreCompleto,
      'espr_Descripcion': esprDescripcion,
      'proy_Progreso': proyProgreso,

    };
  }
}
