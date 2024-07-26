class InsumoViewModel {
  final int insuId;
  final int? sucaId;
  final String? insuDescripcion;
  final String? insuObservacion;
  final int? mateId;
  final int? usuaCreacion;
  final DateTime? insuFechaCreacion;
  final int? usuaModificacion;
  final DateTime? insuFechaModificacion;
  final bool? insuEstado;
  final int? insuUltimoPrecioUnitario;
  final String? usuaCreacionNombre;
  final String? usuaModificacionNombre;

  InsumoViewModel({
    required this.insuId,
    this.sucaId,
    this.insuDescripcion,
    this.insuObservacion,
    this.mateId,
    this.usuaCreacion,
    this.insuFechaCreacion,
    this.usuaModificacion,
    this.insuFechaModificacion,
    this.insuEstado,
    this.insuUltimoPrecioUnitario,
    this.usuaCreacionNombre,
    this.usuaModificacionNombre,
  });

  factory InsumoViewModel.fromJson(Map<String, dynamic> json) {
    return InsumoViewModel(
      insuId: json['insu_Id'],
      sucaId: json['suca_Id'],
      insuDescripcion: json['insu_Descripcion'],
      insuObservacion: json['insu_Observacion'],
      mateId: json['mate_Id'],
      usuaCreacion: json['usua_Creacion'],
      insuFechaCreacion: json['insu_FechaCreacion'] != null
          ? DateTime.parse(json['insu_FechaCreacion'])
          : null,
      usuaModificacion: json['usua_Modificacion'],
      insuFechaModificacion: json['insu_FechaModificacion'] != null
          ? DateTime.parse(json['insu_FechaModificacion'])
          : null,
      insuEstado: json['insu_Estado'],
      insuUltimoPrecioUnitario: json['insu_UltimoPrecioUnitario'],
      usuaCreacionNombre: json['usuaCreacion'],
      usuaModificacionNombre: json['usuaModificacion'],
    );
  }
}
