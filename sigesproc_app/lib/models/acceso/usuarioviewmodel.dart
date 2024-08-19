class UsuarioViewModel {
  final int? usuaId;
  final String? usuaUsuario;
  final String? clave;
  final int? empleadoId;
  final int? rolId;
  final bool? usuaEsAdministrador;
  final String? cargo;
  final String? telfono;
  final String? imagen;
  final String? correo;
  final String? nombreEmpleado;

  UsuarioViewModel({
    this.usuaId,
    this.usuaUsuario,
    this.clave,
    this.empleadoId,
    this.rolId,
    this.usuaEsAdministrador,
    this.cargo,
    this.telfono,
    this.imagen,
    this.correo,
    this.nombreEmpleado,
  });

  factory UsuarioViewModel.fromJson(Map<String, dynamic> json) {
    return UsuarioViewModel(
      usuaId: json['usua_Id'],
      usuaUsuario: json['usua_Usuario'],
      clave: json['usua_Clave'],
      empleadoId: json['empl_Id'],
      rolId: json['role_Id'],
      usuaEsAdministrador: json['usua_EsAdministrador'],
      cargo: json['carg_Descripcion'],
      telfono: json['empl_Telefono'],
      imagen: json['empl_Imagen'],
      correo: json['empl_CorreoElectronico'],
      nombreEmpleado: json['nombre_Empleado'],
    );
  }
}
