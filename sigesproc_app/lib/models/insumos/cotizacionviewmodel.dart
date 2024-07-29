class CotizacionViewModel {
  String codigo;
  String? usuarioCreacion;
  int cotiId;
  int? provId;
  String? provDescripcion;
  DateTime? cotiFecha;
  int? emplId;
  String? empleado;
  num? cotiImpuesto;
  bool? cotiIncluido;
  num? subtotal;
  num? total;
  int? usuaCreacion;
  DateTime? cotiFechaCreacion;
  bool? cotiEstado;

  CotizacionViewModel({
    required this.codigo,
    this.usuarioCreacion,
    required this.cotiId,
    this.provId,
    this.provDescripcion,
    this.cotiFecha,
    this.emplId,
    this.empleado,
    this.cotiImpuesto,
    this.cotiIncluido,
    this.subtotal,
    this.total,
    this.usuaCreacion,
    this.cotiFechaCreacion,
    this.cotiEstado,
  });

  factory CotizacionViewModel.fromJson(Map<String, dynamic> json) {
    return CotizacionViewModel(
      codigo: json['codigo'],
      usuarioCreacion: json['usua_Usuario'],
      cotiId: json['coti_Id'],
      provId: json['prov_Id'],
      provDescripcion: json['prov_Descripcion'],
      cotiFecha: json['coti_Fecha'] != null ? DateTime.parse(json['coti_Fecha']) : null,
      emplId: json['empl_Id'],
      empleado: json['empleado'],
      cotiImpuesto: json['coti_Impuesto'],
      cotiIncluido: json['coti_Incluido'],
      subtotal: json['subtotal'],
      total: json['total'],
      usuaCreacion: json['usua_Creacion'],
      cotiFechaCreacion: json['coti_FechaCreacion'] != null ? DateTime.parse(json['coti_FechaCreacion']) : null,
      cotiEstado: json['coti_Estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'usua_Usuario': usuarioCreacion,
      'coti_Id': cotiId,
      'prov_Id': provId,
      'prov_Descripcion': provDescripcion,
      'coti_Fecha': cotiFecha?.toIso8601String(),
      'empl_Id': emplId,
      'empleado': empleado,
      'coti_Impuesto': cotiImpuesto,
      'coti_Incluido': cotiIncluido,
      'subtotal': subtotal,
      'total': total,
      'usua_Creacion': usuaCreacion,
      'coti_FechaCreacion': cotiFechaCreacion?.toIso8601String(),
      'coti_Estado': cotiEstado,
    };
  }
}
