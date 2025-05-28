import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_3/auth/login.dart';
import 'package:flutter_application_3/home_screen.dart';


class Authgate extends StatelessWidget {
  const Authgate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final session = snapshot.data!.session;
          return session != null ? HomeScreen() : const LoginScreen();
        }
        return const LoginScreen();
      },
    );
  }
}