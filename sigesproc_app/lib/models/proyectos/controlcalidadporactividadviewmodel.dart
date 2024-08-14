// class ControlDeCalidadesPorActividadesViewModel {
//   int? codigo;
//   int? cocaId;
//   String? cocaDescripcion;
//   DateTime cocaFecha;
//   int usuaCreacion;
//   DateTime? cocaFechaCreacion;
//   int? usuaModificacion;
//   DateTime? cocaFechaModificacion;
//   bool? cocaEstado;
//   int? acetId;
//   double? cocaMetrosTrabajados;
//   String? cocaResultado;
//   String? actiDescripcion;
//   int? acetCantidad;
//   String? usuaCreacionNombre;
//   String? usuaModificacionNombre;

//   ControlDeCalidadesPorActividadesViewModel({

//     this.codigo,
//     this.cocaId,
//     required this.cocaDescripcion,
//     required this.cocaFecha,
//     required this.usuaCreacion,
//     this.cocaFechaCreacion,
//     this.usuaModificacion,
//     this.cocaFechaModificacion,
//     this.cocaEstado,
//     this.acetId,
//     this.cocaMetrosTrabajados,
//     this.cocaResultado,
//     this.actiDescripcion,
//     this.acetCantidad,
//     this.usuaCreacionNombre,
//     this.usuaModificacionNombre,
//   });

//   factory ControlDeCalidadesPorActividadesViewModel.fromJson(Map<String, dynamic> json) {
//   return ControlDeCalidadesPorActividadesViewModel(

//     codigo: json['codigo'],
//     cocaId: json['coca_Id'],
//     cocaDescripcion: json['coca_Descripcion'] ?? '',
//     cocaFecha: DateTime.parse(json['coca_Fecha']),
//     usuaCreacion: json['usua_Creacion'],
//     cocaFechaCreacion: DateTime.parse(json['coca_FechaCreacion']),
//     usuaModificacion: json['usua_Modificacion'],
//     cocaFechaModificacion: json['coca_FechaModificacion'] != null 
//         ? DateTime.parse(json['coca_FechaModificacion']) 
//         : null,
    
//     // Manejo de cocaEstado para convertir 1/0/null a true/false
//     cocaEstado: json['coca_Estado'] == 1 ? true : (json['coca_Estado'] == 0 ? false : null),
    
//     acetId: json['acet_Id'],
//     cocaMetrosTrabajados: json['coca_MetrosTrabajados'] != null 
//         ? json['coca_MetrosTrabajados'].toDouble() 
//         : null,
    
//     // Manejo de posibles nulls para Strings
//     cocaResultado: json['coca_Resultado'] ?? '',
//     actiDescripcion: json['acti_Descripcion'] ?? '',
//     acetCantidad: json['acet_Cantidad'],
//     usuaCreacionNombre: json['usuaCreacion'] ?? '',
//     usuaModificacionNombre: json['usuaModificacion'] ?? '',
//   );
// }


//   Map<String, dynamic> toJson() {
//   return {

//     'codigo': codigo,
//     'coca_Id': cocaId,
//     'coca_Descripcion': (cocaDescripcion != null && cocaDescripcion!.isNotEmpty) ? cocaDescripcion : null,
//     'coca_Fecha': cocaFecha.toIso8601String(),
//     'usua_Creacion': usuaCreacion,
//     'coca_FechaCreacion': cocaFechaCreacion?.toIso8601String(), // Usa el operador null-aware ?. para manejar posibles null
//     'usua_Modificacion': usuaModificacion,
//     'coca_FechaModificacion': cocaFechaModificacion?.toIso8601String(), // Usa el operador null-aware ?. para manejar posibles null
    
//     // Conversión de true/false a 1/0
//     'coca_Estado': cocaEstado == true ? 1 : (cocaEstado == false ? 0 : null),
    
//     'acet_Id': acetId,
//     'coca_MetrosTrabajados': cocaMetrosTrabajados,
    
//     // Manejo de posibles nulls para Strings
//     'coca_Resultado': (cocaResultado != null && cocaResultado!.isNotEmpty) ? cocaResultado : null,
//     'acti_Descripcion': (actiDescripcion != null && actiDescripcion!.isNotEmpty) ? actiDescripcion : null,
//     'acet_Cantidad': acetCantidad,
//     'usuaCreacion': (usuaCreacionNombre != null && usuaCreacionNombre!.isNotEmpty) ? usuaCreacionNombre : null,
//     'usuaModificacion': (usuaModificacionNombre != null && usuaModificacionNombre!.isNotEmpty) ? usuaModificacionNombre : null,
//   };
// }

// }


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
  double? cocaMetrosTrabajados;

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
    this.cocaMetrosTrabajados,
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
      'coca_MetrosTrabajados': cocaMetrosTrabajados,
    };
  }
}
