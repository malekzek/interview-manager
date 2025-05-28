import 'package:google_sign_in/google_sign_in.dart' show GoogleSignIn;
import 'package:supabase_flutter/supabase_flutter.dart';

class Authprovider {
  final supabase = Supabase.instance.client;

  // Sign in with email and password
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    try {
      const webClientId =
          '1058538958020-qc9rh0sr3rau7qbop2ju229mjj7jutck.apps.googleusercontent.com';
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
      );
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      final response = supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Get current user email
  String? getCurrentUserEmail() {
    try {
      final user = supabase.auth.currentUser;
      return user?.email;
    } catch (e) {
      return null;
    }
  }

  // Get current user
  User? getCurrentUser() {
    try {
      return supabase.auth.currentUser;
    } catch (e) {
      return null;
    }
  }
}