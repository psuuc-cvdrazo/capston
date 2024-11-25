import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign in
  Future<AuthResponse> signInWithEmailPassword(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(email: email, password: password);
      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Sign up
   Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password, {
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
       
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
        },
      );

      if (response.user != null) {
        
        await _supabase.from('useraccount').insert({
          'uid': response.user?.id,
          'email': email,
          'firstname': firstName,
          'lastname': lastName,
          'phone': phoneNumber,
          'password': password,
        });
      }
      
      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }


  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
