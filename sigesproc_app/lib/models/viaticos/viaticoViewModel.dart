
class ViaticoEncViewModel {
  int? codigo;
  String? empleado;
  String? proyecto;

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
  });

  factory ViaticoEncViewModel.fromJson(Map<String, dynamic> json) {
    return ViaticoEncViewModel(
      codigo: json['codigo'],
      empleado: json['Empleado'],
      proyecto: json['Proyecto'],
      vienId: json['vien_Id'],
      vienSaberProyeto: json['vien_SaberProyeto'],
      vienMontoEstimado: json['vien_MontoEstimado']?.toDouble(),
      vienTotalGastado: json['vien_TotalGastado']?.toDouble(),
      vienFechaEmicion: json['vien_FechaEmicion'] != null
          ? DateTime.parse(json['vien_FechaEmicion'])
          : null,
      emplId: json['empl_Id'],
      proyId: json['Proy_Id'],
      usuaCreacion: json['usua_Creacion'],
      vienFechaCreacion: json['vien_FechaCreacion'] != null
          ? DateTime.parse(json['vien_FechaCreacion'])
          : null,
      usuaModificacion: json['usua_Modificacion'],
      vienFechaModificacion: json['vien_FechaModificacion'] != null
          ? DateTime.parse(json['vien_FechaModificacion'])
          : null,
      usuarioEsAdm: json['usuarioEsAdm'] ?? 0,
      vienTotalReconocido: json['vien_TotalReconocido']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'codigo': codigo,
      'Empleado': empleado,
      'Proyecto': proyecto,
      'vien_Id': vienId,
      'vien_SaberProyeto': vienSaberProyeto,
      'vien_MontoEstimado': vienMontoEstimado,
      'vien_TotalGastado': vienTotalGastado,
      'vien_FechaEmicion': vienFechaEmicion?.toIso8601String(),
      'empl_Id': emplId,
      'Proy_Id': proyId,
      'usua_Creacion': usuaCreacion,
      'vien_FechaCreacion': vienFechaCreacion?.toIso8601String(),
      'usua_Modificacion': usuaModificacion,
      'vien_FechaModificacion': vienFechaModificacion?.toIso8601String(),
      'usuarioEsAdm': usuarioEsAdm,
      'vien_TotalReconocido': vienTotalReconocido,
    };

    return data;
  }

  @override
  String toString() {
    return 'ViaticoEncViewModel(codigo: $codigo, empleado: $empleado, proyecto: $proyecto, '
        'vienId: $vienId, vienSaberProyeto: $vienSaberProyeto, vienMontoEstimado: $vienMontoEstimado, '
        'vienTotalGastado: $vienTotalGastado, vienFechaEmicion: $vienFechaEmicion, emplId: $emplId, '
        'proyId: $proyId, usuaCreacion: $usuaCreacion, vienFechaCreacion: $vienFechaCreacion, '
        'usuaModificacion: $usuaModificacion, vienFechaModificacion: $vienFechaModificacion, '
        'usuarioEsAdm: $usuarioEsAdm, vienTotalReconocido: $vienTotalReconocido)';
  }
}
