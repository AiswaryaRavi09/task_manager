import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthNotifier extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  User? _user;
  bool _loading = false;

  User? get user => _user;
  bool get loading => _loading;
  bool get isAuthenticated => _user != null;

  AuthNotifier() {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    _loading = true;
    notifyListeners();

    final session = _supabase.auth.currentSession;
    _user = session?.user;

    _loading = false;
    notifyListeners();

    _supabase.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      notifyListeners();
    });
  }


  /// **Send OTP to email**
  Future<void> sendEmailOTP(String email) async {
    try {
      _loading = true;
      notifyListeners();

      await _supabase.auth.signInWithOtp(
        email: email,
      );

      print("✅ OTP sent successfully to $email");
    } catch (e) {
      print("❌ Error sending OTP: $e");
      throw Exception("Failed to send OTP. Please try again.");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }


  /// **Verify OTP manually (for numeric OTPs)**
  Future<void> verifyOTP(String email, String otp) async {
    try {
      _loading = true;
      notifyListeners();

      final response = await _supabase.auth.verifyOTP(
        type: OtpType.email,  // ✅ Required parameter
        email: email,
        token: otp,
      );

      if (response.session != null) {
        print("✅ OTP verified successfully!");
      } else {
        throw Exception("Invalid OTP. Please try again.");
      }
    } catch (e) {
      print("❌ Error verifying OTP: $e");
      throw Exception("OTP verification failed.");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// **Sign out user**
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _user = null;
    notifyListeners();
  }
}
