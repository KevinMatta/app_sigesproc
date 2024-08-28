class ViaticoEncViewModel {
  int? codigo;
  String? empleado;
  String? proyecto;
  bool? vienEstadoFacturas;

  int? vienId;
  bool? vienSaberProyeto;
  double? vienMontoEstimado;
  double? vienTotalGastado;
  DateTime? vienFechaEmicion;
  int? emplId;
  int? proyId;
  int? usuaCreacion;
  DateTime? vienFechaCreacion;
  int? usuaModificacion;
  DateTime? vienFechaModificacion;
  bool? usuarioEsAdm; // NotMapped
  double? vienTotalReconocido; // NotMapped

  ViaticoEncViewModel({
    this.codigo,
    this.empleado,
    this.proyecto,
    this.vienId,
    this.vienSaberProyeto,
    this.vienMontoEstimado,
    this.vienTotalGastado,
    this.vienFechaEmicion,
    this.emplId,
    this.proyId,
    this.usuaCreacion,
    this.vienFechaCreacion,
    this.usuaModificacion,
    this.vienFechaModificacion,
    this.usuarioEsAdm,
    this.vienTotalReconocido,
    this.vienEstadoFacturas,
  });

  factory ViaticoEncViewModel.fromJson(Map<String, dynamic> json) {
    return ViaticoEncViewModel(
      codigo: json['codigo'],
      empleado: json['Empleado'],
      proyecto: json['proyecto'],
      vienId: json['vien_Id'],
      vienSaberProyeto: json['vien_SaberProyeto'],
      vienMontoEstimado: json['vien_MontoEstimado']?.toDouble(),
      vienTotalGastado: json['vien_TotalGastado']?.toDouble(),
      vienFechaEmicion: json['vien_FechaEmicion'] != null
          ? DateTime.parse(json['vien_FechaEmicion'])
          : null,
      emplId: json['empl_Id'],
      proyId: json['proy_Id'],
      usuaCreacion: json['usua_Creacion'],
      vienFechaCreacion: json['vien_FechaCreacion'] != null
          ? DateTime.parse(json['vien_FechaCreacion'])
          : null,
      usuaModificacion: json['usua_Modificacion'],
      vienFechaModificacion: json['vien_FechaModificacion'] != null
          ? DateTime.parse(json['vien_FechaModificacion'])
          : null,
      usuarioEsAdm: json['usuarioEsAdm'] ?? false,
      vienEstadoFacturas: json['vien_EstadoFacturas'] ?? false,
      vienTotalReconocido: json['vien_TotalReconocido']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'vien_MontoEstimado': vienMontoEstimado,
      'vien_FechaEmicion': vienFechaEmicion?.toIso8601String(),
      'empl_Id': emplId,
      'Proy_Id': proyId,
      'usua_Creacion': usuaCreacion,
      'vien_FechaCreacion': vienFechaCreacion?.toIso8601String(),
      // Incluyendo 'vienId' si no es nulo
      if (vienId != null) 'vien_Id': vienId,
      // Agregando otros campos opcionales si no son nulos
      if (vienEstadoFacturas != null) 'vien_EstadoFacturas': vienEstadoFacturas,
      if (codigo != null) 'codigo': codigo,
      if (vienTotalGastado != null) 'vien_TotalGastado': vienTotalGastado,
      if (vienSaberProyeto != null) 'vien_SaberProyeto': vienSaberProyeto,
      if (vienTotalReconocido != null)
        'vien_TotalReconocido': vienTotalReconocido,
    };
    return data;
  }
}
