class ProveedorViewModel {
  int codigo;
  int provId;
  String? provDescripcion;
  String? provCorreo;
  String? provTelefono;
  String? provSegundoTelefono;
  int? ciudId;
  String? ciudDescripcion;
  String? estaNombre;
  String? paisNombre;
  int? usuaCreacion;
  DateTime? provFechaCreacion;
  bool? provEstado;

  ProveedorViewModel({
    required this.codigo,
    required this.provId,
    this.provDescripcion,
    this.provCorreo,
    this.provTelefono,
    this.provSegundoTelefono,
    this.ciudId,
    this.ciudDescripcion,
    this.estaNombre,
    this.paisNombre,
    this.usuaCreacion,
    this.provFechaCreacion,
    this.provEstado,
  });

  factory ProveedorViewModel.fromJson(Map<String, dynamic> json) {
    return ProveedorViewModel(
      codigo: json['codigo'],
      provId: json['prov_Id'],
      provDescripcion: json['prov_Descripcion'],
      provCorreo: json['prov_Correo'],
      provTelefono: json['prov_Telefono'],
      provSegundoTelefono: json['prov_SegundoTelefono'],
      ciudId: json['ciud_Id'],
      ciudDescripcion: json['ciud_Descripcion'],
      estaNombre: json['esta_Nombre'],
      paisNombre: json['pais_Nombre'],
      usuaCreacion: json['usua_Creacion'],
      provFechaCreacion: json['prov_FechaCreacion'] != null ? DateTime.parse(json['prov_FechaCreacion']) : null,
      provEstado: json['prov_Estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'prov_Id': provId,
      'prov_Descripcion': provDescripcion,
      'prov_Correo': provCorreo,
      'prov_Telefono': provTelefono,
      'prov_SegundoTelefono': provSegundoTelefono,
      'ciud_Id': ciudId,
      'ciud_Descripcion': ciudDescripcion,
      'esta_Nombre': estaNombre,
      'pais_Nombre': paisNombre,
      'usua_Creacion': usuaCreacion,
      'prov_FechaCreacion': provFechaCreacion?.toIso8601String(),
      'prov_Estado': provEstado,
    };
  }
}
