import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart'; // 👈 pour une police moderne
import 'providers/product_provider.dart';
import 'controllers/product_controller.dart';
import 'views/auth/login_screen.dart';
import 'views/home/home_screen.dart';
import 'controllers/auth_controller.dart';
import 'firebase_options.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);


  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);


  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  runApp(const GestionStockPME());
}

class GestionStockPME extends StatelessWidget {
  const GestionStockPME({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ProductController()),
        Provider(create: (_) => AuthController()),
      ],


      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gestion Stock PME',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            primary: Colors.indigo,
            secondary: Colors.teal,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.indigo,
            elevation: 2,
          ),
        ),


        builder: (context, child) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: child,
          );
        },

        home: const AuthGate(),
      ),
    );
  }
}


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
            body: Center(child: CircularProgressIndicator(color: Colors.indigo)),
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