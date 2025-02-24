import 'package:flutter/material.dart';
import 'app.dart';
//import 'src/features/login/login_screen.dart';
//import 'src/features/splash/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  await Supabase.initialize(
    url: 'https://zvurnjqmcegutysaqrjs.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp2dXJuanFtY2VndXR5c2FxcmpzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQwMzUxOTUsImV4cCI6MjA0OTYxMTE5NX0.U0hdzJcGMDhkdOvm6HF1XxX-FEVqpec9KZmomvL1y6E',
  );

  // Inicializa os dados de formatação para o locale 'pt_BR'
  await initializeDateFormatting('pt_BR', null);
  Intl.defaultLocale = 'pt_BR';

  runApp(const App());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}
