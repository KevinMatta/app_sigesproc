class EstadoCivilViewModel {
  final int? civiId;
  final String? civiDescripcion;

  EstadoCivilViewModel({
    this.civiId,
    this.civiDescripcion,
  });

  factory EstadoCivilViewModel.fromJson(Map<String, dynamic> json) {
    return EstadoCivilViewModel(
      civiId: json['civi_Id'],
      civiDescripcion: json['civi_Descripcion'],
    );
  }
}
