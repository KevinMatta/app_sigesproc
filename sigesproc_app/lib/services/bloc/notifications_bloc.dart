import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sigesproc_app/preferences/pref_usuarios.dart';
import 'package:sigesproc_app/services/acceso/notificacionservice.dart';
import 'package:sigesproc_app/services/localNotification/local_notification.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

// Para manejar notificaciones en segundo plano
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  var mensaje = message.data;
  var title = mensaje['title'];
  var body = mensaje['body'];
  Random random = Random();
  var id = random.nextInt(100000);
  LocalNotification.showLocalNotification(
    id: id,
    title: title,
    body: body,
  );
}

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final int userId;
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationsBloc({required this.userId}) : super(NotificationsInitial()) {
    on<InitializeNotificationsEvent>(_onInitializeNotifications);
    _onForegroundMessage();
  }

  void _onInitializeNotifications(InitializeNotificationsEvent event, Emitter<NotificationsState> emit) {
    requestPermision();
  }

  void requestPermision() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
    } else {
    }

    await LocalNotification.requestPermissionLocalNotifications();
    _getToken();
  }

  void _getToken() async {
    final setting = await messaging.getNotificationSettings();
    if (setting.authorizationStatus != AuthorizationStatus.authorized) return;
    final token = await messaging.getToken();
    if (token != null) {
      final prefs = PreferenciasUsuario();
      prefs.token = token;
    } else {
    }
  }

  void _onForegroundMessage() {
    FirebaseMessaging.onMessage.listen(handleRemoteMessage);
  }

  void handleRemoteMessage(RemoteMessage message) {
  // Asegúrate de que el mensaje contiene los datos correctos
  var title = message.data['title'];
  var body = message.data['body'];


  if (title != null && body != null) {
    Random random = Random();
    var id = random.nextInt(100000);

    LocalNotification.showLocalNotification(
      id: id,
      title: title,
      body: body,
    );
  } else {
  }

}

}
