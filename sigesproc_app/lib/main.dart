import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigesproc_app/auth/login.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sigesproc_app/firebase_options.dart';
import 'package:sigesproc_app/preferences/pref_usuarios.dart';
import 'package:sigesproc_app/services/bloc/notifications_bloc.dart';
import 'package:sigesproc_app/services/localNotification/local_notification.dart';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Manejar mensajes en segundo plano
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Inicializar preferencias del usuario
  await PreferenciasUsuario.init();

  // Inicializar notificaciones locales
  await LocalNotification.initializeLocalNotifications();

  // Solicitar permisos para notificaciones locales
  await LocalNotification.requestPermissionLocalNotifications();

  // Deshabilitar completamente la presentación automática de notificaciones en primer plano
  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: false,  // No mostrar notificaciones automáticamente
    badge: true,
    sound: true,
  );

  // Configurar el manejo de notificaciones
  setupFirebaseMessaging();

  // Inicializar el Bloc para las notificaciones
  const int userId = 5;

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => NotificationsBloc(userId: userId)),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIGESPROC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFFFF0C6)),
        useMaterial3: true,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('es', 'ES'), // Español
      ],
      home: Login(),
    );
  }
}

// Configuración de Firebase Messaging para manejar notificaciones
void setupFirebaseMessaging() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Mensaje recibido en primer plano: ${message.messageId}');

    // Manejamos todas las notificaciones manualmente en primer plano
    if (message.notification != null) {
      var title = message.notification?.title ?? 'Título predeterminado';
      var body = message.notification?.body ?? 'Mensaje predeterminado';

      print('Título recibido: $title');
      print('Cuerpo recibido: $body');

      // Mostrar notificación localmente con flutter_local_notifications
      Random random = Random();
      var id = random.nextInt(100000);
      LocalNotification.showLocalNotification(
        id: id,
        title: title,
        body: body,
      );
    } else if (message.data.isNotEmpty) {
      // Manejar solo data si no hay notification
      var title = message.data['title'] ?? 'Título predeterminado';
      var body = message.data['body'] ?? 'Mensaje predeterminado';

      print('Título de data recibido: $title');
      print('Cuerpo de data recibido: $body');

      // Mostrar notificación localmente con flutter_local_notifications
      Random random = Random();
      var id = random.nextInt(100000);
      LocalNotification.showLocalNotification(
        id: id,
        title: title,
        body: body,
      );
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('App abierta desde la notificación: ${message.messageId}');
    // Maneja la lógica cuando la app se abre desde una notificación
  });
}

// Función para manejar mensajes en segundo plano
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Mensaje recibido en segundo plano: ${message.messageId}');

  if (message.notification != null) {
    // Firebase ya maneja la notificación automáticamente en segundo plano
    print('Notificación manejada automáticamente por Firebase.');
  } else if (message.data.isNotEmpty) {
    // Si solo se envía data sin notification, manejamos manualmente la notificación
    var title = message.data['title'] ?? 'Título predeterminado';
    var body = message.data['body'] ?? 'Mensaje predeterminado';

    print('Título de data recibido (background): $title');
    print('Cuerpo de data recibido (background): $body');

    Random random = Random();
    var id = random.nextInt(100000);

    // Mostrar notificación localmente con flutter_local_notifications
    LocalNotification.showLocalNotification(
      id: id,
      title: title,
      body: body,
    );
  }
}
