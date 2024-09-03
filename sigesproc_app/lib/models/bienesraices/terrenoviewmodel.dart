class TerrenosViewModel {
  int? terrId;
  String? terrDescripcion;
  String? terrArea;
  bool? terrEstado;
  String? terrPecioCompra;
  String? terrPrecioVenta;
  int? usuaCreacion;
  DateTime? terrFechaCreacion;
  int? usuaModificacion;
  DateTime? terrFechaModificacion;
  String? terrLinkUbicacion;
  String? terrImagen;
  String? terrLatitud;
  String? terrLongitud;
  bool? terrIdentificador;

  TerrenosViewModel({
    this.terrId,
    this.terrDescripcion,
    this.terrArea,
    this.terrEstado,
    this.terrPecioCompra,
    this.terrPrecioVenta,
    this.usuaCreacion,
    this.terrFechaCreacion,
    this.usuaModificacion,
    this.terrFechaModificacion,
    this.terrLinkUbicacion,
    this.terrImagen,
    this.terrLatitud,
    this.terrLongitud,
    this.terrIdentificador,
  });

  factory TerrenosViewModel.fromJson(Map<String, dynamic> json) {
    return TerrenosViewModel(
      terrId: json['terr_Id'] as int?,
      terrDescripcion: json['terr_Descripcion'] as String?,
      terrArea: json['terr_Area'] as String?,
      terrEstado: json['terr_Estado'] as bool?,
      terrPecioCompra: json['terr_PecioCompra'] as String?,
      terrPrecioVenta: json['terr_PrecioVenta'] as String?,
      usuaCreacion: json['usua_Creacion'] as int?,
      terrFechaCreacion: json['terr_FechaCreacion'] != null ? DateTime.parse(json['terr_FechaCreacion']) : null,
      usuaModificacion: json['usua_Modificacion'] as int?,
      terrFechaModificacion: json['terr_FechaModificacion'] != null ? DateTime.parse(json['terr_FechaModificacion']) : null,
      terrLinkUbicacion: json['terr_LinkUbicacion'] as String?,
      terrImagen: json['terr_Imagen'] as String?,
      terrLatitud: json['terr_Latitud'] as String?,
      terrLongitud: json['terr_Longitud'] as String?,
      terrIdentificador: json['terr_Identificador'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'terr_Id': terrId,
      'terr_Descripcion': terrDescripcion,
      'terr_Area': terrArea,
      'terr_Estado': terrEstado,
      'terr_PecioCompra': terrPecioCompra,
      'terr_PrecioVenta': terrPrecioVenta,
      'usua_Creacion': usuaCreacion,
      'terr_FechaCreacion': terrFechaCreacion?.toIso8601String(),
      'usua_Modificacion': usuaModificacion,
      'terr_FechaModificacion': terrFechaModificacion?.toIso8601String(),
      'terr_LinkUbicacion': terrLinkUbicacion,
      'terr_Imagen': terrImagen,
      'terr_Latitud': terrLatitud,
      'terr_Longitud': terrLongitud,
      'terr_Identificador': terrIdentificador,
    };
  }
}
