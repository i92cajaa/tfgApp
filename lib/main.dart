import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tfg/home_screen.dart';
import 'package:tfg/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Reserva Cultura',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          // Check the state of the Future
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for the future to resolve, show a loading spinner
            return const CircularProgressIndicator();
          } else if (snapshot.data != false) {
            // If we have data, navigate to the HomeScreen
            return HomeScreen();
          } else {
            // Otherwise, navigate to the LoginScreen
            return LoginScreen();
          }
        },
      ),
    );
  }

  Future<bool> _checkLoginStatus() async {
    final storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'auth_token');
    return token != null;
  }
}