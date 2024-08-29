class EstadoViewModel {
  final int? estaId;
  final String? estaCodigo;
  final String? estaNombre;
  final int? paisId;
  final String? paisNombre;

  EstadoViewModel({
    this.estaId,
    this.estaCodigo,
    this.estaNombre,
    this.paisId,
    this.paisNombre,
  });

  factory EstadoViewModel.fromJson(Map<String, dynamic> json) {
    return EstadoViewModel(
      estaId: json['esta_Id'],
      estaCodigo: json['esta_Codigo'],
      estaNombre: json['esta_Nombre'],
      paisId: json['pais_Id'],
      paisNombre: json['pais_Nombre'],
    );
  }
}
