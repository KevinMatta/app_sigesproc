class ActividadPorEtapaViewModel {
  int? acetId;
  final int? proyId;
  final String? actividadetapa;

  ActividadPorEtapaViewModel({
    this.acetId,
    this.proyId,
    this.actividadetapa,
  });

  factory ActividadPorEtapaViewModel.fromJson(Map<String, dynamic> json) {
    return ActividadPorEtapaViewModel(
      acetId: json['acet_Id'],
      proyId: json['proy_Id'],
      actividadetapa: json['actividadetapa']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'acet_Id': acetId,
      'proy_Id': proyId,
      'actividadetapa': actividadetapa
    };
  }
}
