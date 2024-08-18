class ActividadPorEtapaViewModel {
  int? acetId;
  final int? proyId;
  final String? etapDescripcion ;
  final String? actiDescripcion;

  ActividadPorEtapaViewModel({
    this.acetId,
    this.proyId,
    this.etapDescripcion,
    this.actiDescripcion,
  });

  factory ActividadPorEtapaViewModel.fromJson(Map<String, dynamic> json) {
    return ActividadPorEtapaViewModel(
      acetId: json['acet_Id'],
      proyId: json['proy_Id'],
      etapDescripcion: json['etap_Descripcion'],
      actiDescripcion: json['acti_Descripcion']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'acet_Id': acetId,
      'proy_Id': proyId,
      'etap_Descripcion': etapDescripcion,
      'acti_Descripcion': actiDescripcion
    };
  }

   @override
  String toString() {
    return 'ActividadPorEtapaViewModel(acet: $acetId,proy $proyId, etapdes: $etapDescripcion, actides: $actiDescripcion)';
  }
}
