class DashboardViewModel {
  String? prov_Descripcion;
  double? numeroDeCotizaciones;
  int? prov_Id;

  String? articulo; // Nombre del artículo (String)
  double? totalCompra; // Total de la compra (double)
  String? tipoArticulo;
  //FLETES
  //top 5 bodegas
  String? destino; // Total de la compra (double)
  int? numeroFletes; // Total de la compra (double)

  //top 5 proyectos
  int? proy_Id;
  String? proy_Nombre; // Changed to String
  double? presupuestoTotal; // Changed to double
  double? totalFletesDestinoProyecto; // Changed to double

  // Freight Incidences (New)
  int? incidenciasTotales;
  int? mes;
  int? numeroFletesMensuales;

  //
  int? incidenciasMensuales;
  int? costoIncidenciaMensuales;

  //top 5 proyectos con mayor presupuesto
  DashboardViewModel({
    this.prov_Descripcion,
    this.numeroDeCotizaciones,
    this.prov_Id,
    this.articulo,
    this.totalCompra,
    this.tipoArticulo,

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
  });

  factory DashboardViewModel.fromJson(Map<String, dynamic> json) {
    return DashboardViewModel(
      prov_Descripcion:
          json['prov_Descripcion'] ?? '', // Use empty string if null
      numeroDeCotizaciones: json['numeroDeCotizaciones']?.toDouble() ??
          0.0, // Default to 0.0 if null
      prov_Id: json['prov_Id'] ?? 0, // Default to 0 if null
      articulo: json['articulo'] ?? '', // Use empty string if null
      totalCompra: json['totalCompra'] != null
          ? (json['totalCompra'] as num).toDouble()
          : 0.0, // Default to 0.0
      tipoArticulo: json['tipoArticulo'] ?? '', // Use empty string if null
      destino: json['destino'] ?? '', // Use empty string if null
      numeroFletes: json['numeroFletes'] ?? 0, // Default to 0 if null
      proy_Id: json['proy_Id'] ?? 0,
      proy_Nombre: json['proy_Nombre'] ?? '',
      presupuestoTotal: json['presupuestoTotal']?.toDouble() ?? 0.0,
      totalFletesDestinoProyecto:
          json['totalFletesDestinoProyecto']?.toDouble() ?? 0.0,
      incidenciasTotales: json['incidenciasTotales'] ?? 0,
      mes: json['mes'] ?? 0,
      numeroFletesMensuales: json['numeroFletesMensuales'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'prov_Descripcion': prov_Descripcion,
      'numeroDeCotizaciones': numeroDeCotizaciones,
      'prov_Id': prov_Id,
      'articulo': articulo.toString(),
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
    };

    return data;
  }
}
