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
  int? numeroAcreditaciones;

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
      numeroAcreditaciones: json['numeroAcreditaciones'] as int?,
      totalGastado: json['totalGastado'] as double?,
      montoEstimado: json['montoEstimado'] as double?,
      cantidadViaticos: json['cantidadViaticos'] as int?,
      dia: json['dia'] as int?,
      totalPrestamos: json['totalPrestamos'] as int?,
      totalMontoPrestado: json['totalMontoPrestado'] as double?,
      totalSaldoRestante: json['totalSaldoRestante'] as double?,
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
    };
  }
}
