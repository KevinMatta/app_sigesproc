class CiudadViewModel {
  final int? ciudId;
  final String? ciudCodigo;
  final String? ciudDescripcion;
  final int? estaId;

  CiudadViewModel({
    this.ciudId,
    this.ciudCodigo,
    this.ciudDescripcion,
    this.estaId,
  });

  factory CiudadViewModel.fromJson(Map<String, dynamic> json) {
    return CiudadViewModel(
      ciudId: json['ciud_Id'],
      ciudCodigo: json['ciud_Codigo'],
      ciudDescripcion: json['ciud_Descripcion'],
      estaId: json['esta_Id'],
    );
  }
}
