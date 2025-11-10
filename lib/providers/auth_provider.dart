import 'package:flutter/material.dart';
import 'package:rkfitness/models/user_model.dart';
import 'package:rkfitness/supabaseMaster/auth_service.dart';
import 'package:rkfitness/supabaseMaster/useServices.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  
  bool _isLoading = false;
  String? _error;
  UserModel? _currentUser;

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get currentUser => _currentUser;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void _setUser(UserModel? user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final existingUser = await _userService.getUser(email);

      if (existingUser == null) {
        await _authService.signUp(email, password);
        await _createAndProvisionNewUser(email);
      } else {
        await _authService.signIn(email, password);
      }

      final user = await _userService.getUser(email);
      _setUser(user);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _createAndProvisionNewUser(String email) async {
    final newUser = UserModel(
      gmail: email,
      name: email.split('@')[0],
      userType: 'user',
    );
    await _userService.createUser(newUser);
    _setUser(newUser);
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _setUser(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPassword(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updatePassword(String newPassword) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.updatePassword(newPassword);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}