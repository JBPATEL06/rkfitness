import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _secureStorage = const FlutterSecureStorage();
  final _supabase = Supabase.instance.client;

  Future<void> signIn(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.session != null) {
      await _saveSession(response.session!);
    }
  }

  Future<void> signUp(String email, String password) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );
    if (response.session != null) {
      await _saveSession(response.session!);
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    await _secureStorage.delete(key: 'supabase_session');
  }

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  Future<void> updatePassword(String newPassword) async {
    await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  Future<void> _saveSession(Session session) async {
    await _secureStorage.write(
      key: 'supabase_session',
      value: jsonEncode(session.toJson()),
    );
  }

  Future<Session?> getSession() async {
    final sessionJson = await _secureStorage.read(key: 'supabase_session');
    if (sessionJson != null) {
      return Session.fromJson(jsonDecode(sessionJson));
    }
    return null;
  }
}
