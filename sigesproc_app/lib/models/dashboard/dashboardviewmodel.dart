class DashboardViewModel {
  String? articulo;
  double? totalCompra;
  String? tipoArticulo;
  int? prov_Id;
  int? anio;
  String? prov_Descripcion;

  //FLETES
  //top 5 bodegas
  String? destino; // Total de la compra (double)
  int? numeroFletes; // Total de la compra (double)
  // Campos adicionales para las compras mensuales
  int? anhio;
  int? mes;
  double? totalCompraMes;
  int? numeroCompras;

  //Bienes Raices
  double? totalVentasMes;
    int? cantidadVendidosMes;
   int? agen_Id ;
    int? cantidadVendida ;
    String? agen_NombreCompleto ;


  // Campos para el top 5 de proveedores más cotizados
  int? provId;
  String? provDescripcion;
  int? numeroDeCotizaciones;

  //top 5 proyectos
  int? proy_Id;
  String? proy_Nombre; // Changed to String
  double? presupuestoTotal; // Changed to double
  double? totalFletesDestinoProyecto; // Changed to double

  // Freight Incidences (New)
  int? incidenciasTotales;

  int? numeroFletesMensuales;

  //
  int? incidenciasMensuales;
  int? costoIncidenciaMensuales;

  //top 5 proyectos con mayor presupuesto

  //Planilla

  //Top 5 bancos
  String? banco;
  double? numeroAcreditaciones;

  //Prestamo viatico
  double? totalGastado;
  double? montoEstimado;
  int? cantidadViaticos;

  //Prestamo Mes Dia
  int? dia;
  int? totalPrestamos;
  double? totalMontoPrestado;
  double? totalSaldoRestante;

  //proyectos por departamento
  int? cantidad_Proyectos;
  String? esta_Nombre;

  DashboardViewModel({
    this.esta_Nombre,
    this.cantidad_Proyectos,
    this.articulo,
    this.totalCompra,
    this.tipoArticulo,
    this.prov_Id,
    this.prov_Descripcion,
    //BIENES RAICES
    required this.agen_NombreCompleto,
    this.cantidadVendida,
    this.agen_Id,
    this.totalVentasMes,
    this.cantidadVendidosMes,

    //FLETES
    this.destino,
    this.numeroFletes,
    this.proy_Id,
    this.proy_Nombre,
    this.presupuestoTotal,
    this.totalFletesDestinoProyecto,
    this.incidenciasTotales,
    this.mes,
    this.numeroFletesMensuales,
    this.anhio,
    this.totalCompraMes,
    this.numeroCompras,
    this.provId,
    this.provDescripcion,
    this.numeroDeCotizaciones,
    this.banco,
    this.numeroAcreditaciones,
    this.totalGastado,
    this.montoEstimado,
    this.cantidadViaticos,
    this.dia,
    this.totalPrestamos,
    this.totalMontoPrestado,
    this.totalSaldoRestante,
    this.anio,
  });

  // Método para transformar el número del mes en el nombre del mes
  String getNombreMes() {
    List<String> meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return meses[mes != null
        ? mes! - 1
        : 0]; // Ajuste para que el índice coincida con el número de mes
  }

  factory DashboardViewModel.fromJson(Map<String, dynamic> json) {
    return DashboardViewModel(
      prov_Descripcion:
          json['prov_Descripcion'] ?? '', // Use empty string if null

      prov_Id: json['prov_Id'] ?? 0, // Default to 0 if null
      cantidad_Proyectos:
          json['cantidad_Proyectos'] ?? 0, // Default to 0 if null

      destino: json['destino'] ?? '', // Use empty string if null
      esta_Nombre: json['esta_Nombre'] ?? '', // Use empty string if null
      numeroFletes: json['numeroFletes'] ?? 0, // Default to 0 if null
      proy_Id: json['proy_Id'] ?? 0,
      proy_Nombre: json['proy_Nombre'] ?? '',
      presupuestoTotal: json['presupuestoTotal']?.toDouble() ?? 0.0,
      totalFletesDestinoProyecto:
          json['totalFletesDestinoProyecto']?.toDouble() ?? 0.0,
      incidenciasTotales: json['incidenciasTotales'] ?? 0,

      numeroFletesMensuales: json['numeroFletesMensuales'] ?? 0,
      articulo: json['articulo'] as String?,
      totalCompra: json['totalCompra'] != null
          ? double.tryParse(json['totalCompra'].toString()) ?? 0.0
          : 0.0,
      tipoArticulo: json['tipoArticulo'] as String?,
      anhio: json['anhio'] as int?,
      mes: json['mes'] as int?,
      totalCompraMes: json['totalCompraMes'] != null
          ? double.tryParse(json['totalCompraMes'].toString()) ?? 0.0
          : 0.0,
      numeroCompras: json['numeroCompras'] as int?,
      anio: json['anio'] as int?,
      // Campos para proveedores
      provId: json['prov_Id'] as int?,
      provDescripcion: json['prov_Descripcion'] as String?,
      numeroDeCotizaciones: json['numeroDeCotizaciones'] as int?,
      banco: json['banco'] as String?,
      numeroAcreditaciones: json['numeroAcreditaciones'] != null
          ? (json['numeroAcreditaciones'] as num).toDouble()
          : 0.00, 
      totalGastado: json['totalGastado'] as double?,
      montoEstimado: json['montoEstimado'] as double?,
      cantidadViaticos: json['cantidadViaticos'] as int?,
      dia: json['dia'] as int?,
      totalPrestamos: json['totalPrestamos'] as int?,
      totalMontoPrestado: json['totalMontoPrestado'] as double?,
      totalSaldoRestante: json['totalSaldoRestante'] as double?,


//BIENES RAICES
//ventas mensuales
    totalVentasMes: json['totalVentasMes'] != null? double.tryParse(json['totalVentasMes'].toString()) ?? 0.0: 0.0,
      cantidadVendidosMes: json['cantidadVendidosMes'] as int?,
      //agentes
               agen_Id: json['agen_Id'] as int?,

         cantidadVendida: json['cantidadVendida'] as int?,
      agen_NombreCompleto: json['agen_NombreCompleto'] as String?
    );

  }

  Map<String, dynamic> toJson() {
    return {
      'articulo': articulo,
      'esta_Nombre': esta_Nombre,
      'totalCompra': totalCompra,
      'tipoArticulo': tipoArticulo,
      'destino': destino,
      'numeroFletes': numeroFletes,
      'proy_Id': proy_Id,
      'proy_Nombre': proy_Nombre,
      'presupuestoTotal': presupuestoTotal,
      'totalFletesDestinoProyecto': totalFletesDestinoProyecto,
      'incidenciasTotales': incidenciasTotales,
      'mes': mes,
      'numeroFletesMensuales': numeroFletesMensuales,
      'anhio': anhio,
      'totalCompraMes': totalCompraMes,
      'numeroCompras': numeroCompras,
      'prov_Id': provId,
      'prov_Descripcion': provDescripcion,
      'numeroDeCotizaciones': numeroDeCotizaciones,
      'banco': banco,
      'numeroAcreditaciones': numeroAcreditaciones,
      'totalGastado': totalGastado,
      'montoEstimado': montoEstimado,
      'cantidad_Proyectos': cantidad_Proyectos,
      'cantidadViaticos': cantidadViaticos,
      'dia': dia,
      'totalPrestamos': totalPrestamos,
      'totalMontoPrestado': totalMontoPrestado,
      'totalSaldoRestante': totalSaldoRestante,
      'anio': anio,
            'agen_Id': agen_Id,

      'cantidadVendida': cantidadVendida,

      'agen_NombreCompleto': agen_NombreCompleto,

      'cantidadVendidosMes': cantidadVendidosMes,

      'totalVentasMes': totalVentasMes,

    };
  }
}

class TopProyectosRelacionadosViewModel {
  String? proy_Nombre; // Nombre del proyecto
  double? totalFletesDestinoProyecto; // Total de fletes recibidos por el proyecto

  TopProyectosRelacionadosViewModel({
    this.proy_Nombre,
    this.totalFletesDestinoProyecto,
  });

  factory TopProyectosRelacionadosViewModel.fromJson(Map<String, dynamic> json) {
    return TopProyectosRelacionadosViewModel(
      proy_Nombre: json['proy_Nombre'] ?? '', // Asigna el nombre del proyecto
      totalFletesDestinoProyecto: json['totalFletesDestinoProyecto'] != null
          ? double.tryParse(json['totalFletesDestinoProyecto'].toString()) ?? 0.0
          : 0.0, // Asigna el total de fletes
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proy_Nombre': proy_Nombre,
      'totalFletesDestinoProyecto': totalFletesDestinoProyecto,
    };
  }
}

class TopNumeroDestinosFletesViewModel {
  String? destino; // Nombre de la bodega
  int? numeroFletes; // Número de fletes

  TopNumeroDestinosFletesViewModel({
    this.destino,
    this.numeroFletes,
  });

  factory TopNumeroDestinosFletesViewModel.fromJson(Map<String, dynamic> json) {
    return TopNumeroDestinosFletesViewModel(
      destino: json['destino'] ?? '', // Asigna el nombre de la bodega
      numeroFletes: json['numeroFletes'] ?? 0, // Asigna el número de fletes
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'destino': destino,
      'numeroFletes': numeroFletes,
    };
  }
}

class ComprasMesViewModel {
  int? mes;
  double? totalCompraMes;
  int? numeroCompras;

  ComprasMesViewModel({
    this.mes,
    this.totalCompraMes,
    this.numeroCompras,
  });

  // Método para transformar el número del mes en el nombre del mes
  String getNombreMes() {
    List<String> meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return meses[mes != null ? mes! - 1 : 0]; // Ajuste para que el índice coincida con el número de mes
  }

  factory ComprasMesViewModel.fromJson(Map<String, dynamic> json) {
    return ComprasMesViewModel(
      mes: json['mes'] as int?,
      totalCompraMes: json['totalCompraMes'] != null
          ? double.tryParse(json['totalCompraMes'].toString()) ?? 0.0
          : 0.0,
      numeroCompras: json['numeroCompras'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mes': mes,
      'totalCompraMes': totalCompraMes,
      'numeroCompras': numeroCompras,
    };
  }
}

class DashboardArticulosViewModel {
  String? articulo; // Nombre del artículo
  int? numeroCompras; // Número de veces que se ha comprado el artículo

  DashboardArticulosViewModel({
    this.articulo,
    this.numeroCompras,
  });

  // Método para transformar el modelo desde JSON
  factory DashboardArticulosViewModel.fromJson(Map<String, dynamic> json) {
    return DashboardArticulosViewModel(
      articulo: json['articulo'] ?? '', // Nombre del artículo, valor por defecto si es nulo
      numeroCompras: json['numeroCompras'] ?? 0, // Número de compras, valor por defecto si es nulo
    );
  }

  // Método para transformar el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'articulo': articulo,
      'numeroCompras': numeroCompras,
    };
  }
}

class DashboardPrestamoDiasMesViewModel {
  int? dia;
  int? mes;
  int? anio;
  double? totalMontoPrestado;

  DashboardPrestamoDiasMesViewModel({
    this.dia,
    this.mes,
    this.anio,
    this.totalMontoPrestado,
  });

  factory DashboardPrestamoDiasMesViewModel.fromJson(Map<String, dynamic> json) {
    return DashboardPrestamoDiasMesViewModel(
      dia: json['dia'] ?? 0, // Asegurarse de que siempre haya un valor
      mes: json['mes'] ?? 0,
      anio: json['anio'] ?? 0,
      totalMontoPrestado: json['totalMontoPrestado'] != null
          ? double.tryParse(json['totalMontoPrestado'].toString()) ?? 0.0
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dia': dia,
      'mes': mes,
      'anio': anio,
      'totalMontoPrestado': totalMontoPrestado,
    };
  }
}

class DepartamentoViewModel {
  String? esta_Nombre;
  int? cantidad_Proyectos;

  DepartamentoViewModel({
    this.esta_Nombre,
    this.cantidad_Proyectos,
  });

  factory DepartamentoViewModel.fromJson(Map<String, dynamic> json) {
    return DepartamentoViewModel(
      esta_Nombre: json['esta_Nombre'] ?? '', // Nombre del estado o departamento
      cantidad_Proyectos: json['cantidad_Proyectos'] ?? 0, // Cantidad de proyectos
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'esta_Nombre': esta_Nombre,
      'cantidad_Proyectos': cantidad_Proyectos,
    };
  }
}

class ProveedorViewModel {
  String? provDescripcion;
  int? numeroDeCotizaciones;

  ProveedorViewModel({
    this.provDescripcion,
    this.numeroDeCotizaciones,
  });

  factory ProveedorViewModel.fromJson(Map<String, dynamic> json) {
    return ProveedorViewModel(
      provDescripcion: json['prov_Descripcion'] ?? '', 
      numeroDeCotizaciones: json['numeroDeCotizaciones'] ?? 0, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provDescripcion': provDescripcion,
      'numeroDeCotizaciones': numeroDeCotizaciones,
    };
  }
}

class DashboardProyectoViewModel {
  String? proy_Nombre;
  double? presupuestoTotal;

  DashboardProyectoViewModel({
    this.proy_Nombre,
    this.presupuestoTotal,
  });

  // Método para crear un objeto a partir de JSON
  factory DashboardProyectoViewModel.fromJson(Map<String, dynamic> json) {
    return DashboardProyectoViewModel(
      proy_Nombre: json['proy_Nombre'] ?? '',
      presupuestoTotal: json['presupuestoTotal']?.toDouble() ?? 0.0,
    );
  }

  // Método para transformar el objeto en JSON
  Map<String, dynamic> toJson() {
    return {
      'proy_Nombre': proy_Nombre,
      'presupuestoTotal': presupuestoTotal,
    };
  }
}

class DashboardBienRaizViewModel {
  double? totalVentasMes;
  int? cantidadVendidosMes;

  DashboardBienRaizViewModel({
    this.totalVentasMes,
    this.cantidadVendidosMes,
  });

  // Método para transformar un JSON a un objeto de DashboardBienRaizViewModel
  factory DashboardBienRaizViewModel.fromJson(Map<String, dynamic> json) {
    return DashboardBienRaizViewModel(
      totalVentasMes: json['totalVentasMes'] != null
          ? double.tryParse(json['totalVentasMes'].toString()) ?? 0.0
          : 0.0,
      cantidadVendidosMes: json['cantidadVendidosMes'] as int?,
    );
  }

  // Método para transformar el objeto a un Map (para serializar a JSON)
  Map<String, dynamic> toJson() {
    return {
      'totalVentasMes': totalVentasMes,
      'cantidadVendidosMes': cantidadVendidosMes,
    };
  }
}

class VentasPorAgenteViewModel {
  int? agen_Id;
  String? agen_NombreCompleto;
  int? cantidadVendida;

  VentasPorAgenteViewModel({
    this.agen_Id,
    this.agen_NombreCompleto,
    this.cantidadVendida,
  });

  // Método para convertir un JSON a un objeto VentasPorAgenteViewModel
  factory VentasPorAgenteViewModel.fromJson(Map<String, dynamic> json) {
    return VentasPorAgenteViewModel(
      agen_Id: json['agen_Id'] as int?,
      agen_NombreCompleto: json['agen_NombreCompleto'] as String?,
      cantidadVendida: json['cantidadVendida'] as int?,
    );
  }

  // Método para convertir el objeto a un Map (para serializar a JSON)
  Map<String, dynamic> toJson() {
    return {
      'agen_Id': agen_Id,
      'agen_NombreCompleto': agen_NombreCompleto,
      'cantidadVendida': cantidadVendida,
    };
  }
}

class VentaTerrenoViewModel {
  int? cantidadVendidosMes;
  double? totalVentasMes;

  VentaTerrenoViewModel({
    this.cantidadVendidosMes,
    this.totalVentasMes,
  });

  // Método para convertir un JSON a un objeto VentaTerrenoViewModel
  factory VentaTerrenoViewModel.fromJson(Map<String, dynamic> json) {
    return VentaTerrenoViewModel(
      cantidadVendidosMes: json['cantidadVendidosMes'] as int?,
      totalVentasMes: json['totalVentasMes'] != null
          ? double.tryParse(json['totalVentasMes'].toString()) ?? 0.0
          : 0.0,
    );
  }

  // Método para convertir el objeto a un Map (para serializar a JSON)
  Map<String, dynamic> toJson() {
    return {
      'cantidadVendidosMes': cantidadVendidosMes,
      'totalVentasMes': totalVentasMes,
    };
  }
}

class ViaticosMesActualViewModel {
  double? totalGastado;
  double? montoEstimado;
  int? cantidadViaticos;
  int? mes;

  ViaticosMesActualViewModel({
    this.totalGastado,
    this.montoEstimado,
    this.cantidadViaticos,
    this.mes,
  });

  // Método para convertir un JSON a un objeto ViaticosMesActualViewModel
  factory ViaticosMesActualViewModel.fromJson(Map<String, dynamic> json) {
    return ViaticosMesActualViewModel(
      totalGastado: json['totalGastado'] != null
          ? double.tryParse(json['totalGastado'].toString()) ?? 0.0
          : 0.0,
      montoEstimado: json['montoEstimado'] != null
          ? double.tryParse(json['montoEstimado'].toString()) ?? 0.0
          : 0.0,
      cantidadViaticos: json['cantidadViaticos'] as int?,
      mes: json['mes'] as int?,
    );
  }

  // Método para convertir el objeto a un Map (para serializar a JSON)
  Map<String, dynamic> toJson() {
    return {
      'totalGastado': totalGastado,
      'montoEstimado': montoEstimado,
      'cantidadViaticos': cantidadViaticos,
      'mes': mes,
    };
  }
}

class BancoAcreditacionesViewModel {

  String? banco;
  int? numeroAcreditaciones; // Mantener como int

  BancoAcreditacionesViewModel({
    this.banco,
    this.numeroAcreditaciones,
  });

  // Convertir el JSON a un objeto BancoAcreditacionesViewModel
  factory BancoAcreditacionesViewModel.fromJson(Map<String, dynamic> json) {
    return BancoAcreditacionesViewModel(
      banco: json['banco'] as String?,
      numeroAcreditaciones: json['numeroAcreditaciones'] != null
          ? json['numeroAcreditaciones'] as int
          : 0, // Si es null, usar 0 por defecto
    );
  }

  // Convertir el objeto a un Map (para serializar a JSON)
  Map<String, dynamic> toJson() {
    return {
      'banco': banco,
      'numeroAcreditaciones': numeroAcreditaciones,
    };
  }
}