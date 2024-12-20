import 'package:flutter/material.dart';
import 'package:teafarm_pro/screens/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TEA FARM PRO',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 36, 233, 141)),
        useMaterial3: true,
      ),
      home: LoginScreen(),
    );
  }
}
