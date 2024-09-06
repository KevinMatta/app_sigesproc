class UsuarioViewModel {
  final int? usuaId;
  final String? usuaUsuario;
  final String? clave;
  final bool? usuaEsAdministrador;
  final int? empleadoId;
  final int? rolId;
  final int? usuaCreacion;
  final DateTime? usuaFechaCreacion;
  final int? usuaModificacion;
  final DateTime? usuaFechaModificacion;
  final bool? usuaEstado;

  final String? rolDescripcion;
  final String? empleado;
  final String? codigo;
  final String? usuaCreacionNombre;
  final String? usuaModificacionNombre;
  final String? nombreEmpleado;
  final String? correoEmpleado;
  final String? telefonoEmpleado;
  final String? imagenEmpleado;
  final String? cargoDescripcion;
  final DateTime? fechaNacimientoEmpleado;

  UsuarioViewModel({
    this.usuaId,
    this.usuaUsuario,
    this.clave,
    this.usuaEsAdministrador,
    this.empleadoId,
    this.rolId,
    this.usuaCreacion,
    this.usuaFechaCreacion,
    this.usuaModificacion,
    this.usuaFechaModificacion,
    this.usuaEstado,
    this.rolDescripcion,
    this.empleado,
    this.codigo,
    this.usuaCreacionNombre,
    this.usuaModificacionNombre,
    this.nombreEmpleado,
    this.correoEmpleado,
    this.telefonoEmpleado,
    this.imagenEmpleado,
    this.cargoDescripcion,
    this.fechaNacimientoEmpleado,
  });

  factory UsuarioViewModel.fromJson(Map<String, dynamic> json) {
    return UsuarioViewModel(
      usuaId: json['usua_Id'] as int?,
      usuaUsuario: json['usua_Usuario'] as String?,
      clave: json['usua_Clave'] as String?,
      usuaEsAdministrador: json['usua_EsAdministrador'] as bool?,
      empleadoId: json['empl_Id'] as int?,
      rolId: json['role_Id'] as int?,
      usuaCreacion: json['usua_Creacion'] as int?,
      usuaFechaCreacion: json['usua_FechaCreacion'] != null ? DateTime.parse(json['usua_FechaCreacion']) : null,
      usuaModificacion: json['usua_Modificacion'] as int?,
      usuaFechaModificacion: json['usua_FechaModificacion'] != null ? DateTime.parse(json['usua_FechaModificacion']) : null,
      usuaEstado: json['usua_Estado'] as bool?,
      rolDescripcion: json['role_Descripcion'] as String?,
      empleado: json['empleado'] as String?,
      codigo: json['codigo'] as String?,
      usuaCreacionNombre: json['usuaCreacion'] as String?,
      usuaModificacionNombre: json['usuaModificacion'] as String?,
      nombreEmpleado: json['nombre_Empleado'] as String?,
      correoEmpleado: json['empl_CorreoElectronico'] as String?,
      telefonoEmpleado: json['empl_Telefono'] as String?,
      imagenEmpleado: json['empl_Imagen'] as String?,
      cargoDescripcion: json['carg_Descripcion'] as String?,
      fechaNacimientoEmpleado: json['empl_FechaNacimiento'] != null ? DateTime.parse(json['empl_FechaNacimiento']) : null,
    );
  }

  Map<String, dynamic> toJson() {
  return {
    'usua_Id': usuaId,
    'usua_Usuario': usuaUsuario,
    'usua_Clave': clave,
    'usua_EsAdministrador': usuaEsAdministrador,
    'empl_Id': empleadoId,
    'role_Id': rolId,
    'usua_Creacion': usuaCreacion,
    'usua_FechaCreacion': usuaFechaCreacion?.toIso8601String(),
    'usua_Modificacion': usuaModificacion,
    'usua_FechaModificacion': usuaFechaModificacion?.toIso8601String(),
    'usua_Estado': usuaEstado,
    'role_Descripcion': rolDescripcion,
    'empleado': empleado,
    'codigo': codigo,
    'usuaCreacion': usuaCreacionNombre,
    'usuaModificacion': usuaModificacionNombre,
    'nombre_Empleado': nombreEmpleado,
    'empl_CorreoElectronico': correoEmpleado,
    'empl_Telefono': telefonoEmpleado,
    'empl_Imagen': imagenEmpleado,
    'carg_Descripcion': cargoDescripcion,
    'empl_FechaNacimiento': fechaNacimientoEmpleado?.toIso8601String(),
  };
}

}



class UsuarioReestablecerViewModel {
  final int? usuaId;
  final String? usuaUsuario;
  final String? clave;
  final bool? usuaEsAdministrador;
  final int? empleadoId;
  final int? rolId;
  final int? usuaCreacion;
  final int? usuaModificacion;

  UsuarioReestablecerViewModel({
    this.usuaId,
    this.usuaUsuario,
    this.clave,
    this.usuaEsAdministrador,
    this.empleadoId,
    this.rolId,
    this.usuaCreacion,
    this.usuaModificacion,
  });

  factory UsuarioReestablecerViewModel.fromJson(Map<String, dynamic> json) {
    return UsuarioReestablecerViewModel(
      usuaId: json['usua_Id'] as int?,
      usuaUsuario: json['usua_Usuario'] as String?,
      clave: json['usua_Clave'] as String?,
      usuaEsAdministrador: json['usua_EsAdministrador'] as bool?,
      empleadoId: json['empl_Id'] as int?,
      rolId: json['role_Id'] as int?,
      usuaCreacion: json['usua_Creacion'] as int?,
      usuaModificacion: json['usua_Modificacion'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
  return {
    'usua_Id': usuaId,
    'usua_Usuario': usuaUsuario,
    'usua_Clave': clave,
    'usua_EsAdministrador': usuaEsAdministrador,
    'empl_Id': empleadoId,
    'role_Id': rolId,
    'usua_Creacion': usuaCreacion,
    'usua_Modificacion': usuaModificacion,
  };
}

}
