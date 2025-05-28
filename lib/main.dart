import 'package:flutter/material.dart';
//import 'package:flutter_application_3/auth/login.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth/auth_gate.dart';
import 'services/QuizProgressProvider.dart';
//import 'home_screen.dart';

void main()  async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://qgsxdgjbausaspkkxwsn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFnc3hkZ2piYXVzYXNwa2t4d3NuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc5NjI1ODQsImV4cCI6MjA2MzUzODU4NH0.5J9MSsYUIPCttKKEk7UNfjYjFkxfayEX2K9a0XdlYDw',
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuizProgressProvider()),
      ],
      child: MyApp(),
    ),
  );
}

final supabase = Supabase.instance.client;
class MyApp extends StatelessWidget {
  MyApp({super.key});
  final Color background = Color(0xFFf4f6f8);
  final Color main = Color(0xFF212528);
  final Color accentColor = Color(0xFF4ecdc4);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // keep your other colors…
        primaryColor: accentColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: main,
          surface: background,
          primary: accentColor,
          onSurface: main,
          outline: main,
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: main),
          labelStyle: TextStyle(color: main),
        ),
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(color: main, fontSize: 20),
          iconTheme: IconThemeData(color: main),
        ),
      ),

      home: const Authgate(),
      debugShowCheckedModeBanner: false,
    );
  }
}