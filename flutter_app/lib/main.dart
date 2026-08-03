import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/prediction_screen.dart';
import 'screens/result_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HealthInsuranceApp());
}

class HealthInsuranceApp extends StatelessWidget {
  const HealthInsuranceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Insurance Premium Predictor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/home': (_) => const HomeScreen(),
        '/predict': (_) => const PredictionScreen(),
        '/result': (_) => const ResultScreen(),
      },
    );
  }
}
