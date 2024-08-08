class ArticuloViewModel {
  int cotiId;
  int? provId;
  DateTime? cotiFecha;
  int? emplId;
  int? usuaCreacion;
  DateTime? cotiFechaCreacion;
  int? usuaModificacion;
  DateTime? cotiFechaModificacion;
  bool? cotiEstado;
  num cotiImpuesto;
  bool cotiIncluido;
  int codeRenta;
  String? nombreCompleto;
  String? provDescripcion;
  String? fecha;
  String? impuPorcentaje;
  String? empleado;
  String? imp;
  int codigo;
  int id;
  int idP;
  String articulo;
  String precio;
  String fechaCreacion;
  String categoria;
  String cantidad;
  String total;
  String subtotal;
  String impuesto;
  int unmeId;
  String medida;
  int unidad;
  int codeId;
  bool agregadoACotizacion;

  ArticuloViewModel({
    required this.cotiId,
    this.provId,
    this.cotiFecha,
    this.emplId,
    this.usuaCreacion,
    this.cotiFechaCreacion,
    this.usuaModificacion,
    this.cotiFechaModificacion,
    this.cotiEstado,
    required this.cotiImpuesto,
    required this.cotiIncluido,
    required this.codeRenta,
    this.nombreCompleto,
    this.provDescripcion,
    this.fecha,
    this.impuPorcentaje,
    this.empleado,
    this.imp,
    required this.codigo,
    required this.id,
    required this.idP,
    required this.articulo,
    required this.precio,
    required this.fechaCreacion,
    required this.categoria,
    required this.cantidad,
    required this.total,
    required this.subtotal,
    required this.impuesto,
    required this.unmeId,
    required this.medida,
    required this.unidad,
    required this.codeId,
    required this.agregadoACotizacion,
  });

  factory ArticuloViewModel.fromJson(Map<String, dynamic> json) {
    return ArticuloViewModel(
      cotiId: json['coti_Id'],
      provId: json['prov_Id'],
      cotiFecha: json['coti_Fecha'] != null ? DateTime.parse(json['coti_Fecha']) : null,
      emplId: json['empl_Id'],
      usuaCreacion: json['usua_Creacion'],
      cotiFechaCreacion: json['coti_FechaCreacion'] != null ? DateTime.parse(json['coti_FechaCreacion']) : null,
      usuaModificacion: json['usua_Modificacion'],
      cotiFechaModificacion: json['coti_FechaModificacion'] != null ? DateTime.parse(json['coti_FechaModificacion']) : null,
      cotiEstado: json['coti_Estado'],
      cotiImpuesto: json['coti_Impuesto'],
      cotiIncluido: json['coti_Incluido'],
      codeRenta: json['code_Renta'],
      nombreCompleto: json['nombreCompleto'],
      provDescripcion: json['prov_Descripcion'],
      fecha: json['fecha'],
      impuPorcentaje: json['impu_Porcentaje'],
      empleado: json['empleado'],
      imp: json['imp'],
      codigo: json['codigo'],
      id: json['id'],
      idP: json['idP'],
      articulo: json['articulo'],
      precio: json['precio'],
      fechaCreacion: json['fechaCreacion'],
      categoria: json['categoria'],
      cantidad: json['cantidad'],
      total: json['total'],
      subtotal: json['subtotal'],
      impuesto: json['impuesto'],
      unmeId: json['unme_Id'],
      medida: json['medida'],
      unidad: json['unidad'],
      codeId: json['code_Id'],
      agregadoACotizacion: json['agregadoACotizacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coti_Id': cotiId,
      'prov_Id': provId,
      'coti_Fecha': cotiFecha?.toIso8601String(),
      'empl_Id': emplId,
      'usua_Creacion': usuaCreacion,
      'coti_FechaCreacion': cotiFechaCreacion?.toIso8601String(),
      'usua_Modificacion': usuaModificacion,
      'coti_FechaModificacion': cotiFechaModificacion?.toIso8601String(),
      'coti_Estado': cotiEstado,
      'coti_Impuesto': cotiImpuesto,
      'coti_Incluido': cotiIncluido,
      'code_Renta': codeRenta,
      'nombreCompleto': nombreCompleto,
      'prov_Descripcion': provDescripcion,
      'fecha': fecha,
      'impu_Porcentaje': impuPorcentaje,
      'empleado': empleado,
      'imp': imp,
      'codigo': codigo,
      'id': id,
      'idP': idP,
      'articulo': articulo,
      'precio': precio,
      'fechaCreacion': fechaCreacion,
      'categoria': categoria,
      'cantidad': cantidad,
      'total': total,
      'subtotal': subtotal,
      'impuesto': impuesto,
      'unme_Id': unmeId,
      'medida': medida,
      'unidad': unidad,
      'code_Id': codeId,
      'agregadoACotizacion': agregadoACotizacion,
    };
  }
}
