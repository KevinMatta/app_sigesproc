class PantallaViewModel {
  final int? pantId;
  final String? pantDescripcion;
  final String? pantDireccionURL;
  final int? usuaCreacion;
  final DateTime? pantFechaCreacion;
  final int? usuaModificacion;
  final DateTime? pantFechaModificacion;
  final bool? pantEstado;

  final String? usuaCreacionNombre;
  final String? usuaModificacionNombre;
  final String? roleDescripcion;
  final int? roleId;

  PantallaViewModel({
    this.pantId,
    this.pantDescripcion,
    this.pantDireccionURL,
    this.usuaCreacion,
    this.pantFechaCreacion,
    this.usuaModificacion,
    this.pantFechaModificacion,
    this.pantEstado,
    this.usuaCreacionNombre,
    this.usuaModificacionNombre,
    this.roleDescripcion,
    this.roleId,
  });

  factory PantallaViewModel.fromJson(Map<String, dynamic> json) {
    return PantallaViewModel(
      pantId: json['pant_Id'] as int?,
      pantDescripcion: json['pant_Descripcion'] as String?,
      pantDireccionURL: json['pant_direccionURL'] as String?,
      usuaCreacion: json['usua_Creacion'] as int?,
      pantFechaCreacion: json['pant_FechaCreacion'] != null ? DateTime.parse(json['pant_FechaCreacion']) : null,
      usuaModificacion: json['usua_Modificacion'] as int?,
      pantFechaModificacion: json['pant_FechaModificacion'] != null ? DateTime.parse(json['pant_FechaModificacion']) : null,
      pantEstado: json['pant_Estado'] as bool?,
      usuaCreacionNombre: json['usuaCreacion'] as String?,
      usuaModificacionNombre: json['usuaModificacion'] as String?,
      roleDescripcion: json['role_Descripcion'] as String?,
      roleId: json['role_Id'] as int?,
    );
  }
}

