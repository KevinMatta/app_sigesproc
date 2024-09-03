class DashboardViewModel {
  String? prov_Descripcion;
  int? numeroDeCotizaciones;
  int? prov_Id;

  String? articulo;
  double? totalCompra;
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
      articulo: json['articulo'],
      totalCompra: (json['totalCompra'] as num?)?.toDouble(),
      tipoArticulo: json['tipoArticulo'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'prov_Descripcion': prov_Descripcion,
      'numeroDeCotizaciones': numeroDeCotizaciones,
      'prov_Id': prov_Id,
      'articulo': articulo,
      'totalCompra': totalCompra,
      'tipoArticulo': tipoArticulo,
    };

    return data;
  }
}
