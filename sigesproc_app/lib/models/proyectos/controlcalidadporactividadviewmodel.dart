class ListarControlDeCalidadesPorActividadesViewModel {
  int? codigo;
  int? cocaId;
  String? cocaDescripcion;
  DateTime? cocaFecha;
  int? usuaCreacion;
  DateTime? cocaFechaCreacion;
  int? usuaModificacion;
  DateTime? cocaFechaModificacion;
  bool? cocaEstado;
  int? acetId;
  double? cocaCantidadtrabajada;
  String? cocaResultado;
  String? actiDescripcion;
  double? acetCantidad;
  String? usuaCreacionNombre;
  String? usuaModificacionNombre;
  bool? cocaAprobado;

  ListarControlDeCalidadesPorActividadesViewModel({
    this.codigo,
    this.cocaId,
    required this.cocaDescripcion,
    required this.cocaFecha,
    required this.usuaCreacion,
    this.cocaFechaCreacion,
    this.usuaModificacion,
    this.cocaFechaModificacion,
    this.cocaEstado,
    this.acetId,
    this.cocaCantidadtrabajada,
    this.cocaResultado,
    this.actiDescripcion,
    this.acetCantidad,
    this.usuaCreacionNombre,
    this.usuaModificacionNombre,
    this.cocaAprobado,
  });

  factory ListarControlDeCalidadesPorActividadesViewModel.fromJson(Map<String, dynamic> json) {
    return ListarControlDeCalidadesPorActividadesViewModel(
      codigo: json['codigo'],
      cocaId: json['coca_Id'],
      cocaDescripcion: json['coca_Descripcion'] ?? '',
      cocaFecha: _parseDateTime(json['coca_Fecha']),
      usuaCreacion: json['usua_Creacion'],
      cocaFechaCreacion: _parseDateTime(json['coca_FechaCreacion']),
      usuaModificacion: json['usua_Modificacion'],
      cocaFechaModificacion: json['coca_FechaModificacion'] != null 
          ? _parseDateTime(json['coca_FechaModificacion']) 
          : null,
      cocaEstado: json['coca_Estado'] == 1 ? true : (json['coca_Estado'] == 0 ? false : null),
      acetId: json['acet_Id'],
      cocaCantidadtrabajada: _parseDouble(json['coca_CantidadTrabajada']),
      cocaResultado: json['coca_Resultado'] ?? '',
      actiDescripcion: json['acti_Descripcion'] ?? '',
      acetCantidad: _parseDouble(json['acet_Cantidad']),
      usuaCreacionNombre: json['usuaCreacion'] ?? '',
      usuaModificacionNombre: json['usuaModificacion'] ?? '',
      cocaAprobado: json['coca_Aprobado'],
    );
  }

Map<String, dynamic> toJson() {
  return {
    'codigo': codigo,
    'coca_Id': cocaId,
    'coca_Descripcion': (cocaDescripcion != null && cocaDescripcion!.isNotEmpty) ? cocaDescripcion : null,
    'coca_Fecha': cocaFecha?.toIso8601String(),
    'usua_Creacion': usuaCreacion,
    'coca_FechaCreacion': cocaFechaCreacion?.toIso8601String(), // Usa el operador null-aware ?. para manejar posibles null
    'usua_Modificacion': usuaModificacion,
    'coca_FechaModificacion': cocaFechaModificacion?.toIso8601String(), // Usa el operador null-aware ?. para manejar posibles null
    'coca_Estado': cocaEstado == true ? 1 : (cocaEstado == false ? 0 : null),
    'acet_Id': acetId,
    'coca_CantidadTrabajada': cocaCantidadtrabajada,
    'coca_Resultado': (cocaResultado != null && cocaResultado!.isNotEmpty) ? cocaResultado : null,
    'acti_Descripcion': (actiDescripcion != null && actiDescripcion!.isNotEmpty) ? actiDescripcion : null,
    'acet_Cantidad': acetCantidad,
    'usuaCreacion': (usuaCreacionNombre != null && usuaCreacionNombre!.isNotEmpty) ? usuaCreacionNombre : null,
    'usuaModificacion': (usuaModificacionNombre != null && usuaModificacionNombre!.isNotEmpty) ? usuaModificacionNombre : null,
    'coca_Aprobado': cocaAprobado,
  };
}

  // Helper methods for parsing
  static DateTime? _parseDateTime(dynamic value) {
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print("Error parsing DateTime: $e, value: $value");
        return null;
      }
    }
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else if (value != null) {
      try {
        return double.parse(value.toString());
      } catch (e) {
        print("Error parsing double: $e, value: $value");
        return null;
      }
    }
    return null;
  }
}



class ControlDeCalidadesPorActividadesViewModel {
  // int? cocaId;
  String cocaDescripcion;
  DateTime cocaFecha;
  // String? cocaResultado;
  int usuaCreacion;
  // DateTime? cocaFechaCreacion;
  // int? usuaModificacion;
  // DateTime? cocaFechaModificacion;
  // bool? cocaEstado;
  int? acetId;
  double? cocaCantidadtrabajada;

  ControlDeCalidadesPorActividadesViewModel({
    // this.cocaId,
    required this.cocaDescripcion,
    required this.cocaFecha,
    // this.cocaResultado,
    required this.usuaCreacion,
    // this.cocaFechaCreacion,
    // this.usuaModificacion,
    // this.cocaFechaModificacion,
    // this.cocaEstado,
    this.acetId,
    this.cocaCantidadtrabajada,
  });

  Map<String, dynamic> toJson() {
    return {
      // 'coca_Id': cocaId,
      'coca_Descripcion': cocaDescripcion,
      'coca_Fecha': cocaFecha.toIso8601String(),
      // 'coca_Resultado': cocaResultado ?? '',
      'usua_Creacion': usuaCreacion,
      // 'coca_FechaCreacion': cocaFechaCreacion?.toIso8601String(),
      // 'usua_Modificacion': usuaModificacion,
      // 'coca_FechaModificacion': cocaFechaModificacion?.toIso8601String(),
      // 'coca_Estado': cocaEstado,
      'acet_Id': acetId,
      'coca_Cantidadtrabajada': cocaCantidadtrabajada,
    };
  }
}
