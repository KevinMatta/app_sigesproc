class DashboardViewModel {
  String? prov_Descripcion;
  double? numeroDeCotizaciones;
  int? prov_Id;

 String? articulo;      // Nombre del artículo (String)
  double? totalCompra;   // Total de la compra (double)
  String? tipoArticulo; 

  DashboardViewModel({
    this.prov_Descripcion,
    this.numeroDeCotizaciones,
    this.prov_Id,
  this.articulo,
    this.totalCompra,
    this.tipoArticulo,
  });

  factory DashboardViewModel.fromJson(Map<String, dynamic> json) {
    return DashboardViewModel(
      prov_Descripcion: json['prov_Descripcion'],
      numeroDeCotizaciones: json['numeroDeCotizaciones'],
      prov_Id: json['prov_Id'],
     articulo: json['articulo'] as String,
      totalCompra: json['totalCompra'] != null ? (json['totalCompra'] as num).toDouble() : 0.0,
      tipoArticulo: json['tipoArticulo'] as String?,
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
    };

    return data;
  }
}
