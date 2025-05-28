// lib/utils/error_handler.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorHandler {
  // Basic error display with retry option
  static Widget buildErrorWidget(Object error, VoidCallback onRetry) {
    final message = parseException(error);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // Snackbar for quick error messages
  static void showErrorSnackbar(BuildContext context, Object error) {
    final message = parseException(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Success notification
  static void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Parse different exception types
  static String parseException(Object error) {
    if (error is PostgrestException) {
      return 'Database error: ${error.message}';
    } else if (error is TimeoutException) {
      return 'Request timed out. Please check your connection';
    } else if (error is SocketException) {
      return 'No internet connection';
    } else if (error is AuthException) {
      return 'Authentication error: ${error.message}';
    } else if (error is FormatException) {
      return 'Data format error: ${error.message}';
    } else if (error is PlatformException) {
      return 'Platform error: ${error.message}';
    }
    return 'Something went wrong: ${error.toString()}';
  }

  // Handle errors with logging
  static void handleError(BuildContext context, Object error,
      {bool showUI = true, VoidCallback? onRetry}) {
    // Log error
    _logError(error);

    if (showUI) {
      if (error is AuthException) {
        // Handle auth errors specially
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/login', 
          (route) => false
        );
        showErrorSnackbar(context, 'Session expired. Please login again');
      } else {
        showErrorSnackbar(context, error);
      }
    }
  }

  // Log errors to console (can be extended to crashlytics)
  static void _logError(Object error) {
    debugPrint('''[ERROR] ${DateTime.now()}
    Error: ${error.toString()}
    Stack Trace: ${error is Error ? error.stackTrace : ''}''');
  }

  // Form error styling
    static InputDecoration errorDecoration(String errorText) {
    return InputDecoration(
      errorText: errorText,
      errorStyle: const TextStyle(color: Colors.red),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  static void handleAuthError(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context, 
      '/login', 
      (route) => false
    );
  }
}