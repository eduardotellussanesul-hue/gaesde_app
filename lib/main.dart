import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const GaesdeApp());
}

class GaesdeApp extends StatelessWidget {
  const GaesdeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GAESDE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
