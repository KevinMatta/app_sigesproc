class DashboardViewModel {
  String? articulo;
  double? totalCompra;
  String? tipoArticulo;

  // Campos adicionales para las compras mensuales
  int? anhio;
  int? mes;
  double? totalCompraMes;
  int? numeroCompras;

  // Campos para el top 5 de proveedores más cotizados
  int? provId;
  String? provDescripcion;
  int? numeroDeCotizaciones;

  DashboardViewModel({
    this.articulo,
    this.totalCompra,
    this.tipoArticulo,
    this.anhio,
    this.mes,
    this.totalCompraMes,
    this.numeroCompras,
    this.provId,
    this.provDescripcion,
    this.numeroDeCotizaciones,
  });

  // Método para transformar el número del mes en el nombre del mes
  String getNombreMes() {
    List<String> meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return meses[mes != null ? mes! - 1 : 0]; // Ajuste para que el índice coincida con el número de mes
  }

  factory DashboardViewModel.fromJson(Map<String, dynamic> json) {
    return DashboardViewModel(
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

      // Campos para proveedores
      provId: json['prov_Id'] as int?,
      provDescripcion: json['prov_Descripcion'] as String?,
      numeroDeCotizaciones: json['numeroDeCotizaciones'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'articulo': articulo,
      'totalCompra': totalCompra,
      'tipoArticulo': tipoArticulo,
      'anhio': anhio,
      'mes': mes,
      'totalCompraMes': totalCompraMes,
      'numeroCompras': numeroCompras,
      'prov_Id': provId,
      'prov_Descripcion': provDescripcion,
      'numeroDeCotizaciones': numeroDeCotizaciones,
    };
  }
}
