import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Supabase Authentication Service
class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Stream of Auth State changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign Up with Email, Password and Username
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username.trim().toLowerCase()},
    );
  }

  /// Check if username is already taken
  Future<bool> isUsernameTaken(String username) async {
    try {
      final response = await _client
          .from('profiles')
          .select('id')
          .eq('username', username.trim().toLowerCase())
          .maybeSingle();
      return response != null;
    } catch (e) {
      // Eğer tablo henüz oluşturulmadıysa kaydı engellememek için false dönüyoruz
      return false;
    }
  }

  /// Verify OTP for Email Signup
  Future<AuthResponse> verifyOTP({
    required String email,
    required String token,
  }) async {
    return await _client.auth.verifyOTP(
      type: OtpType.signup,
      email: email,
      token: token,
    );
  }

  /// Resend SignUp OTP
  Future<void> resendSignUpOTP({
    required String email,
  }) async {
    await _client.auth.resend(
      type: OtpType.signup,
      email: email,
    );
  }

  /// Sign In with Email and Password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign In with Google
  Future<bool> signInWithGoogle() async {
    return await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      // For mobile, you might need a redirectTo URL configured in Supabase
    );
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  /// Sign Out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

/// Riverpod Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Riverpod StreamProvider for Auth State
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});
