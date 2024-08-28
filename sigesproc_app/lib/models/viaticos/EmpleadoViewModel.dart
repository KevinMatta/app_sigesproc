class EmpleadoViewModel {
  int? emplId;
  String? emplDNI;
  String? emplNombre;
  String? emplApellido;
  String? emplCorreoElectronico;
  String? emplTelefono;
  String? emplSexo;
  DateTime? emplFechaNacimiento;
  double? emplSalario; // Se asume que decimal en C# se traduce a double en Dart
  int? ciudId;
  String? deduccionesIds; // NotMapped
  String? ciudad; // NotMapped
  int? estaId; // NotMapped
  String? estado; // NotMapped
  int? civiId;
  String? estadoCivil; // NotMapped
  int? cargId;
  String? cargo; // NotMapped
  int? usuaCreacion;
  DateTime? emplFechaCreacion;
  int? usuaModificacion;
  DateTime? emplFechaModificacion;
  bool? emplEstado;
  int? frecId;
  String? frecuencia; // NotMapped
  int? bancId;
  String? emplNoBancario;
  String? banco; // NotMapped
  String? emplNombreCompleto; // NotMapped
  String? emplImagen; // NotMapped

  EmpleadoViewModel({
    this.emplId,
    this.emplDNI,
    this.emplNombre,
    this.emplApellido,
    this.emplCorreoElectronico,
    this.emplTelefono,
    this.emplSexo,
    this.emplFechaNacimiento,
    this.emplSalario,
    this.ciudId,
    this.deduccionesIds,
    this.ciudad,
    this.estaId,
    this.estado,
    this.civiId,
    this.estadoCivil,
    this.cargId,
    this.cargo,
    this.usuaCreacion,
    this.emplFechaCreacion,
    this.usuaModificacion,
    this.emplFechaModificacion,
    this.emplEstado,
    this.frecId,
    this.frecuencia,
    this.bancId,
    this.emplNoBancario,
    this.banco,
    this.emplNombreCompleto,
    this.emplImagen,
  });

  factory EmpleadoViewModel.fromJson(Map<String, dynamic> json) {
    return EmpleadoViewModel(
      emplId: json['empl_Id'],
      emplDNI: json['empl_DNI'],
      emplNombre: json['empl_Nombre'],
      emplApellido: json['empl_Apellido'],
      emplCorreoElectronico: json['empl_CorreoElectronico'],
      emplTelefono: json['empl_Telefono'],
      emplSexo: json['empl_Sexo'],
      emplFechaNacimiento: json['empl_FechaNacimiento'] != null
          ? DateTime.parse(json['empl_FechaNacimiento'])
          : null,
      emplSalario: json['empl_Salario']?.toDouble(),
      ciudId: json['ciud_Id'],
      deduccionesIds: json['deducciones_Ids'],
      ciudad: json['ciudad'],
      estaId: json['esta_Id'],
      estado: json['estado'],
      civiId: json['civi_Id'],
      estadoCivil: json['estadoCivil'],
      cargId: json['carg_Id'],
      cargo: json['cargo'],
      usuaCreacion: json['usua_Creacion'],
      emplFechaCreacion: json['empl_FechaCreacion'] != null
          ? DateTime.parse(json['empl_FechaCreacion'])
          : null,
      usuaModificacion: json['usua_Modificacion'],
      emplFechaModificacion: json['empl_FechaModificacion'] != null
          ? DateTime.parse(json['empl_FechaModificacion'])
          : null,
      emplEstado: json['empl_Estado'],
      frecId: json['frec_Id'],
      frecuencia: json['frecuencia'],
      bancId: json['banc_Id'],
      emplNoBancario: json['empl_NoBancario'],
      banco: json['banco'],
      emplNombreCompleto: json['empl_NombreCompleto'],
      emplImagen: json['empl_Imagen'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'empl_Id': emplId,
      'empl_DNI': emplDNI,
      'empl_Nombre': emplNombre,
      'empl_Apellido': emplApellido,
      'empl_CorreoElectronico': emplCorreoElectronico,
      'empl_Telefono': emplTelefono,
      'empl_Sexo': emplSexo,
      'empl_FechaNacimiento': emplFechaNacimiento?.toIso8601String(),
      'empl_Salario': emplSalario,
      'ciud_Id': ciudId,
      'deducciones_Ids': deduccionesIds,
      'ciudad': ciudad,
      'esta_Id': estaId,
      'estado': estado,
      'civi_Id': civiId,
      'estadoCivil': estadoCivil,
      'carg_Id': cargId,
      'cargo': cargo,
      'usua_Creacion': usuaCreacion,
      'empl_FechaCreacion': emplFechaCreacion?.toIso8601String(),
      'usua_Modificacion': usuaModificacion,
      'empl_FechaModificacion': emplFechaModificacion?.toIso8601String(),
      'empl_Estado': emplEstado,
      'frec_Id': frecId,
      'frecuencia': frecuencia,
      'banc_Id': bancId,
      'empl_NoBancario': emplNoBancario,
      'banco': banco,
      'empl_NombreCompleto': emplNombreCompleto,
      'empl_Imagen': emplImagen,
    };
  }
}
