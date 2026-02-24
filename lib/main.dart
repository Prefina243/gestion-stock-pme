import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart'; // ✅ pour Android 13+
import 'providers/product_provider.dart';
import 'controllers/product_controller.dart'; // ✅ import du ProductController
import 'views/auth/login_screen.dart';
import 'views/home/home_screen.dart';
import 'controllers/auth_controller.dart';
import 'firebase_options.dart';

// 🔔 Instance globale du plugin de notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🟣 Initialisation Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 🟢 Initialisation des notifications locales

  // Paramètres d'initialisation pour Android
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  // Regroupement Android / iOS (ici iOS vide pour simplifier)
  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  // Initialise le plugin
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // 🔐 Android 13+ : demander la permission d’afficher des notifications
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  // 🟣 Lance l'application
  runApp(const GestionStockPME());
}

class GestionStockPME extends StatelessWidget {
  const GestionStockPME({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ProductController()), // ✅ ajouté
        Provider(create: (_) => AuthController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gestion Stock PME',
        theme: ThemeData(primarySwatch: Colors.indigo),
        home: const AuthGate(),
      ),
    );
  }
}

// 🔐 Vérifie si l’utilisateur est connecté
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthController();

    return StreamBuilder(
      stream: auth.userChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}