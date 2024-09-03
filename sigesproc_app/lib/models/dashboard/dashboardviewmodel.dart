class DashboardViewModel {
  String? prov_Descripcion;
  int? numeroDeCotizaciones;
  int? prov_Id;

  DashboardViewModel({
    this.prov_Descripcion,
    this.numeroDeCotizaciones,
    this.prov_Id,
  });

  factory DashboardViewModel.fromJson(Map<String, dynamic> json) {
    return DashboardViewModel(
      prov_Descripcion: json['prov_Descripcion'],
      numeroDeCotizaciones: json['numeroDeCotizaciones'],
      prov_Id: json['prov_Id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'prov_Descripcion': prov_Descripcion,
      'numeroDeCotizaciones': numeroDeCotizaciones,
      'prov_Id': prov_Id,
    };

    return data;
  }
}
