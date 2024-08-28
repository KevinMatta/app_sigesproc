class PaisViewModel {
  final int? paisId;
  final String? paisNombre;
  final String? paisCodigo;
  final String? paisPrefijo;

  PaisViewModel({
    this.paisId,
    this.paisNombre,
    this.paisCodigo,
    this.paisPrefijo,
  });

  factory PaisViewModel.fromJson(Map<String, dynamic> json) {
    return PaisViewModel(
      paisId: json['pais_Id'],
      paisNombre: json['pais_Nombre'],
      paisCodigo: json['pais_Codigo'],
      paisPrefijo: json['pais_Prefijo'],
    );
  }
}
