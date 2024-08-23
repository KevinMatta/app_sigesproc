class ClienteViewModel {
  int? clieId;
  String? clieDNI;
  String? clieNombre;
  String? clieApellido;
  String? clieCorreoElectronico;
  String? clieTelefono;
  DateTime? clieFechaNacimiento;
  String? clieSexo;
  String? clieDireccionExacta;
  int? ciudId;
  int? civiId;
  int? usuaCreacion;
  DateTime? clieFechaCreacion;
  int? usuaModificacion;
  DateTime? clieFechaModificacion;
  String? clieEstado;
  String? cliente;
  String? codigo;
  String? civiDescripcion;
  String? estaId;
  String? estaNombre;
  String? paisId;
  String? paisNombre;
  String? ciudDescripcion;
  String? clieUsuaCreacion;
  String? clieUsuaModificacion;
  String? clieUsuaCreacionn;
  String? clieUsuaModificacionn;
  String? clieNombreCompleto;
  String? clieTipo;

  ClienteViewModel({
    this.clieId,
    this.clieDNI,
    this.clieNombre,
    this.clieApellido,
    this.clieCorreoElectronico,
    this.clieTelefono,
    this.clieFechaNacimiento,
    this.clieSexo,
    this.clieDireccionExacta,
    this.ciudId,
    this.civiId,
    this.usuaCreacion,
    this.clieFechaCreacion,
    this.usuaModificacion,
    this.clieFechaModificacion,
    this.clieEstado,
    this.cliente,
    this.codigo,
    this.civiDescripcion,
    this.estaId,
    this.estaNombre,
    this.paisId,
    this.paisNombre,
    this.ciudDescripcion,
    this.clieUsuaCreacion,
    this.clieUsuaModificacion,
    this.clieUsuaCreacionn,
    this.clieUsuaModificacionn,
    this.clieNombreCompleto,
    this.clieTipo,
  });

  factory ClienteViewModel.fromJson(Map<String, dynamic> json) {
    return ClienteViewModel(
      clieId: json['clie_Id'],
      clieDNI: json['clie_DNI'],
      clieNombre: json['clie_Nombre'],
      clieApellido: json['clie_Apellido'],
      clieCorreoElectronico: json['clie_CorreoElectronico'],
      clieTelefono: json['clie_Telefono'],
      clieFechaNacimiento: json['clie_FechaNacimiento'] != null ? DateTime.parse(json['clie_FechaNacimiento']) : null,
      clieSexo: json['clie_Sexo'],
      clieDireccionExacta: json['clie_DireccionExacta'],
      ciudId: json['ciud_Id'],
      civiId: json['civi_Id'],
      usuaCreacion: json['usua_Creacion'],
      clieFechaCreacion: json['clie_FechaCreacion'] != null ? DateTime.parse(json['clie_FechaCreacion']) : null,
      usuaModificacion: json['usua_Modificacion'],
      clieFechaModificacion: json['clie_FechaModificacion'] != null ? DateTime.parse(json['clie_FechaModificacion']) : null,
      clieEstado: json['clie_Estado'],
      cliente: json['cliente'],
      codigo: json['codigo'],
      civiDescripcion: json['civi_Descripcion'],
      estaId: json['esta_Id'],
      estaNombre: json['esta_Nombre'],
      paisId: json['pais_Id'],
      paisNombre: json['pais_Nombre'],
      ciudDescripcion: json['ciud_Descripcion'],
      clieUsuaCreacion: json['clie_usua_Creacion'],
      clieUsuaModificacion: json['clie_usua_Modificacion'],
      clieUsuaCreacionn: json['clie_usua_Creacionn'],
      clieUsuaModificacionn: json['clie_usua_Modificacionn'],
      clieNombreCompleto: json['clie_NombreCompleto'],
      clieTipo: json['clie_Tipo'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (clieId != null) {
      data['clie_Id'] = clieId;
    }
    if (clieDNI != null) {
      data['clie_DNI'] = clieDNI;
    }
    if (clieNombre != null) {
      data['clie_Nombre'] = clieNombre;
    }
    if (clieApellido != null) {
      data['clie_Apellido'] = clieApellido;
    }
    if (clieCorreoElectronico != null) {
      data['clie_CorreoElectronico'] = clieCorreoElectronico;
    }
    if (clieTelefono != null) {
      data['clie_Telefono'] = clieTelefono;
    }
    if (clieFechaNacimiento != null) {
      data['clie_FechaNacimiento'] = clieFechaNacimiento?.toIso8601String();
    }
    if (clieSexo != null) {
      data['clie_Sexo'] = clieSexo;
    }
    if (clieDireccionExacta != null) {
      data['clie_DireccionExacta'] = clieDireccionExacta;
    }
    if (ciudId != null) {
      data['ciud_Id'] = ciudId;
    }
    if (civiId != null) {
      data['civi_Id'] = civiId;
    }
    if (usuaCreacion != null) {
      data['usua_Creacion'] = usuaCreacion;
    }
    if (clieFechaCreacion != null) {
      data['clie_FechaCreacion'] = clieFechaCreacion?.toIso8601String();
    }
    if (usuaModificacion != null) {
      data['usua_Modificacion'] = usuaModificacion;
    }
    if (clieFechaModificacion != null) {
      data['clie_FechaModificacion'] = clieFechaModificacion?.toIso8601String();
    }
    if (clieEstado != null) {
      data['clie_Estado'] = clieEstado;
    }
    if (cliente != null) {
      data['cliente'] = cliente;
    }
    if (codigo != null) {
      data['codigo'] = codigo;
    }
    if (civiDescripcion != null) {
      data['civi_Descripcion'] = civiDescripcion;
    }
    if (estaId != null) {
      data['esta_Id'] = estaId;
    }
    if (estaNombre != null) {
      data['esta_Nombre'] = estaNombre;
    }
    if (paisId != null) {
      data['pais_Id'] = paisId;
    }
    if (paisNombre != null) {
      data['pais_Nombre'] = paisNombre;
    }
    if (ciudDescripcion != null) {
      data['ciud_Descripcion'] = ciudDescripcion;
    }
    if (clieUsuaCreacion != null) {
      data['clie_usua_Creacion'] = clieUsuaCreacion;
    }
    if (clieUsuaModificacion != null) {
      data['clie_usua_Modificacion'] = clieUsuaModificacion;
    }
    if (clieUsuaCreacionn != null) {
      data['clie_usua_Creacionn'] = clieUsuaCreacionn;
    }
    if (clieUsuaModificacionn != null) {
      data['clie_usua_Modificacionn'] = clieUsuaModificacionn;
    }
    if (clieNombreCompleto != null) {
      data['clie_NombreCompleto'] = clieNombreCompleto;
    }
    if (clieTipo != null) {
      data['clie_Tipo'] = clieTipo;
    }
    return data;
  }

  @override
  String toString() {
    return 'ClienteViewModel(clieId: $clieId, clieDNI: $clieDNI, clieNombre: $clieNombre, clieApellido: $clieApellido, clieCorreoElectronico: $clieCorreoElectronico, clieTelefono: $clieTelefono, clieFechaNacimiento: $clieFechaNacimiento, clieSexo: $clieSexo, clieDireccionExacta: $clieDireccionExacta, ciudId: $ciudId, civiId: $civiId, usuaCreacion: $usuaCreacion, clieFechaCreacion: $clieFechaCreacion, usuaModificacion: $usuaModificacion, clieFechaModificacion: $clieFechaModificacion, clieEstado: $clieEstado, cliente: $cliente, codigo: $codigo, civiDescripcion: $civiDescripcion, estaId: $estaId, estaNombre: $estaNombre, paisId: $paisId, paisNombre: $paisNombre, ciudDescripcion: $ciudDescripcion, clieUsuaCreacion: $clieUsuaCreacion, clieUsuaModificacion: $clieUsuaModificacion, clieUsuaCreacionn: $clieUsuaCreacionn, clieUsuaModificacionn: $clieUsuaModificacionn, clieNombreCompleto: $clieNombreCompleto, clieTipo: $clieTipo)';
  }
}