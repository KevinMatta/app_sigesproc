class EmpleadoViewModel {
  final int? emplId;
  final String? emplDNI;
  final String? emplNombre;
  final String? emplApellido;
  final String? emplCorreoElectronico;
  final String? emplTelefono;
  final String? emplSexo;
  final DateTime? emplFechaNacimiento;
  final num? emplSalario;
  final int? ciudId;
  final int? civiId;
  final int? cargId;
  final int? usuaCreacion;
  final DateTime? emplFechaCreacion;
  final int? usuaModificacion;
  final DateTime? emplFechaModificacion;
  final bool? emplEstado;
  final int? frecId;
  final String? emplNoBancario;
  final int? bancId;
  final String? banco;
  final String? frecuencia;
  final String? usuaCreacionNombre;
  final String? usuaModificacionNombre;
  final String? cargo;
  final String? estadoCivil;
  final String? ciudad;
  final int? estaId;
  final String? estado;
  final int? codigo;
  final String? empleado;

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
    this.civiId,
    this.cargId,
    this.usuaCreacion,
    this.emplFechaCreacion,
    this.usuaModificacion,
    this.emplFechaModificacion,
    this.emplEstado,
    this.frecId,
    this.emplNoBancario,
    this.bancId,
    this.banco,
    this.frecuencia,
    this.usuaCreacionNombre,
    this.usuaModificacionNombre,
    this.cargo,
    this.estadoCivil,
    this.ciudad,
    this.estaId,
    this.estado,
    this.codigo,
    this.empleado,
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
      emplFechaNacimiento: json['empl_FechaNacimiento'] != null ? DateTime.parse(json['empl_FechaNacimiento']) : null,
      emplSalario: json['empl_Salario'] != null ? (json['empl_Salario'] as num).toDouble() : null,
      ciudId: json['ciud_Id'],
      civiId: json['civi_Id'],
      cargId: json['carg_Id'],
      usuaCreacion: json['usua_Creacion'],
      emplFechaCreacion: json['empl_FechaCreacion'] != null ? DateTime.parse(json['empl_FechaCreacion']) : null,
      usuaModificacion: json['usua_Modificacion'],
      emplFechaModificacion: json['empl_FechaModificacion'] != null ? DateTime.parse(json['empl_FechaModificacion']) : null,
      emplEstado: json['empl_Estado'],
      frecId: json['frec_Id'],
      emplNoBancario: json['empl_NoBancario'],
      bancId: json['banc_Id'],
      banco: json['banco'],
      frecuencia: json['frecuencia'],
      usuaCreacionNombre: json['usuaCreacion'],
      usuaModificacionNombre: json['usuaModificacion'],
      cargo: json['cargo'],
      estadoCivil: json['estadoCivil'],
      ciudad: json['ciudad'],
      estaId: json['esta_Id'],
      estado: json['estado'],
      codigo: json['codigo'],
      empleado: json['empleado'],
    );
  }
}
