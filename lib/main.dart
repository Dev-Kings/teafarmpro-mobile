import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:teafarm_pro/screens/home.dart';
import 'package:teafarm_pro/screens/login.dart';
import 'package:teafarm_pro/screens/register.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const MyApp());
  });
}

final secureStorage = FlutterSecureStorage();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _isAuthenticated() async {
    final accessToken = await secureStorage.read(key: 'access_token');
    return accessToken != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else {
          final isAuthenticated = snapshot.data ?? false;

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'TEA FARM PRO',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 36, 233, 141),
              ),
              useMaterial3: true,
            ),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const HomeScreen(),
            },
            home: isAuthenticated ? const HomeScreen() : const LoginScreen(),
          );
        }
      },
    );
  }
}
