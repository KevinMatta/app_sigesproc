class NotificationViewModel {
  int? notiId;
  int? napuId;
  String? notiDescripcion;
  DateTime? notiFecha;
  String? notiLeida;
  String? notiTipo;
  int usuaId;
  int usuaCreacion;
  DateTime? notiFechaCreacion;
  String? notificacionOalerta;
  String? descripcion;
  String? fecha;
  String? leida;

  NotificationViewModel({
    this.notiId,
    required this.napuId,
    this.notiDescripcion,
    this.notiFecha,
    this.notiLeida,
    this.notiTipo,
    required this.usuaId,
    required this.usuaCreacion,
    this.notiFechaCreacion,
    this.notificacionOalerta,
    this.descripcion,
    this.fecha,
    this.leida,
  });

  factory NotificationViewModel.fromJson(Map<String, dynamic> json) {
    return NotificationViewModel(
      notiId: json ['noti_Id'],
      napuId: json['napu_Id'],
      notiDescripcion: json['noti_Descripcion'],
      notiFecha: json['noti_Fecha'] != null ? DateTime.parse(json['noti_Fecha']) : null,
      notiLeida: json['noti_Leida'],
      notiTipo: json['noti_Tipo'],
      usuaId: json['usua_Id'],
      usuaCreacion: json['usua_Creacion'],
      notiFechaCreacion: json['noti_FechaCreacion'] != null ? DateTime.parse(json['noti_FechaCreacion']) : null,
      notificacionOalerta: json['notificacionOalerta'],
      descripcion: json['descripcion'],
      fecha: json['fecha'],
      leida: json['leida'],
    );
  }
}
