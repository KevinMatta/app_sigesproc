class viaticosViewModel{

  //viatico emcabezado
  int? usuaId;
  int? vienId;
  String? vienMontoEstimado;
  String? vienTotalGastado;
  DateTime? vienFechaEmicion;
  int? emplId;
  int? proyId;
  String? vienTotalReconocido;
  int? usuaCreacion;
  DateTime? vienFechaCreacion;
  int? usuaModificacion;
  DateTime? vienFechaModificacion;
  bool? vienEstado;
  bool? vienEstadoFacturas;

  //viatico detalle
  int? videId;
  String? videDescripcion;
  String? videImagenFactura;
  String? videMontoGastado;
  int? caviId;
  DateTime? videFechaCreacion;
  DateTime? videFechaModificacion;
  bool? videEstado;


  // NotMapped fields Emcabezado
  String? empleado;
  int? codigo;
  String? proyecto;
  String? usuarioEsAdm; 
  String? usuarioCreacion;
  String? usuarioModifica;
  String? caviDescripcion;
  // String? videDescripcion;
  // String? videImagenFactura;
  // String? videMontoGastado;
  String? videMontoReconocido;

  // NotMapped fields Detalle 
  // bool? vienEstadoFacturas;


  viaticosViewModel({

    //viaticos emcabezado
    required this.usuaId,
    required this.vienId,
    this.vienMontoEstimado,
    this.vienTotalGastado,
    this.vienFechaEmicion,
    this.emplId,
    this.proyId,
    this.vienTotalReconocido,
    this.usuaCreacion,
    this.vienFechaCreacion,
    this.usuaModificacion,
    this.vienFechaModificacion,
    this.vienEstado,
    this.vienEstadoFacturas,

    //viaticos detalles
   this.videId,
   this.videDescripcion,
   this.videImagenFactura,
   this.videMontoGastado,
   this.caviId,
   this.videFechaCreacion,
   this.videFechaModificacion,
   this.videEstado,

  // NotMapped fields emcabezado 
    this.empleado,
    this.codigo,
    this.proyecto,
    this.usuarioEsAdm,
    this.usuarioCreacion,
    this.usuarioModifica,
    this.caviDescripcion,
    // this.videDescripcion,
    // this.videImagenFactura,
    // this.videMontoGastado,
    this.videMontoReconocido,

    //Notmapped fields detalles
    // this.vienEstadoFacturas
  });

  // Metodo de fábrica para crear una instancia de JSON
  factory viaticosViewModel.fromJson(Map<String, dynamic> json) {
  return viaticosViewModel(

    //viaticos encabezado
    usuaId: json['usua_Id'],
    vienId: json['vien_Id'],
    vienMontoEstimado: json['vien_MontoEstimado'],
    vienTotalGastado: json['vien_TotalGastado'],
    vienFechaEmicion: json['vien_FechaEmicion'] != null ? DateTime.parse(json['vien_FechaEmicion']) : null,
    emplId: json['empl_Id'],
    proyId: json['proy_Id'],
    vienTotalReconocido: json['vien_TotalReconcocido'],
    usuaCreacion: json['usua_Creacion'],
    usuaModificacion: json['usua_Modificacion'],
    vienFechaCreacion: json['vien_FechaCreacion'] != null ? DateTime.parse(json['vien_FechaCreacion']) : null,
    vienFechaModificacion: json['vien_FechaModificacion'] != null ? DateTime.parse(json['vien_FechaModificacion']) : null,
    vienEstado: json['vien_Estado'] == 1 ? true : (json['vien_Estado'] == 0 ? false : null),
    vienEstadoFacturas: json['vien_EstadoFacturas'] == 1 ? true : (json['vide_Estado'] == 0 ? false : null),


    //viaticos detalle
    videId: json['vide_Id'],
    videDescripcion: json['vide_Descripcion'],
    videImagenFactura: json['vide_ImagenFactura'],
    videMontoGastado: json['vide_MontoGastado'],
    videFechaCreacion: json['vide_FechaCreacion'],
    videFechaModificacion: json['vide_FechaModificacion'],
    videEstado: json['vide_Estado'] == 1 ? true : (json['vide_Estado'] == 0 ? false : null),

    //NotMapped Fields encabbezado
    empleado: json['empleado']  ?? '',
    codigo: json['codigo']  ?? '',
    proyecto: json['proyecto']  ?? '',
    usuarioEsAdm: json['usuarioEsAdm']  ?? '',
    usuarioCreacion: json['usuarioCreacion'] ?? '',
    usuarioModifica: json['usuarioModifica'] ?? '',
    caviDescripcion: json['cavi_Descripcion'] ?? '',
    // videDescripcion: json['vide_Descripcion'] ?? '',
    // videImagenFactura: json['vide_ImagenFactura'] ?? '',
    // videMontoGastado: json['vide_MontoGastado']  ?? '',
    videMontoReconocido: json['vide_MontoReconocido'] ?? '',

    //NotMapped Fields deetalle
    // vienEstadoFacturas: json['vien_EstadoFacturas'] == 1 ? true : (json['vide_Estado'] == 0 ? false : null)


  );
}
  Map<String, dynamic> toJson() {
    return {
      //viaticos emcabezados
      'usua_Id': usuaId,
      'vien_Id' : vienId,
      'vien_MontoEstimado' : vienMontoEstimado,
      'vien_TotalGastado': vienTotalGastado,
      'vienFechaEmicion' : vienFechaEmicion?.toIso8601String(),
      'empl_Id': emplId,
      'proy_Id': proyId,
      'vien_TotalReconcocido': vienTotalReconocido,
      'usua_Creacion': usuaCreacion,
      'usua_Modificacion': usuaModificacion,
      'vien_FechaCreacion': videFechaCreacion?.toIso8601String(),
      'vien_FechaModificacion': videFechaModificacion?.toIso8601String(),
      'vien_Estado': vienEstado,
      'vien_EstadoFacturas': vienEstadoFacturas,

      //viaticos detalles
      'vide_Id': videId,
      'vide_Descripcion': videDescripcion,
      'vide_ImagenFactura': videImagenFactura,
      'vide_MontoGastado': videMontoGastado,
      'vien_Id': vienId,
      'cavi_Id': caviId,
      'usua_Creacion': usuaCreacion,
      'usua_Modificacion': usuaModificacion,
      'vide_FechaCreacion': videFechaCreacion?.toIso8601String(),
      'vide_FechaModificacion': videFechaModificacion?.toIso8601String(),
      'vide_Estado': videEstado
    };
  }
  
}