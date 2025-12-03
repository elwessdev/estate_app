import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../services/database_helper.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  static const String _userIdKey = 'user_id';
  static const String _isLoggedInKey = 'is_logged_in';

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Check for existing session on app start
  Future<bool> checkSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      final userId = prefs.getInt(_userIdKey);

      if (isLoggedIn && userId != null) {
        final user = await DatabaseHelper.instance.getUserById(userId);
        if (user != null) {
          _currentUser = user;
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Save session to local storage
  Future<void> _saveSession(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setInt(_userIdKey, userId);
      print('Session saved successfully');
    } catch (e) {
      print('Warning: Could not save session: $e');
      // Continue anyway - session will be lost on restart but user is logged in
    }
  }

  // Clear session from local storage
  Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_isLoggedInKey);
      await prefs.remove(_userIdKey);
    } catch (e) {
      print('Warning: Could not clear session: $e');
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      print('=== REGISTRATION STARTED ===');
      _isLoading = true;
      notifyListeners();

      // Validate inputs
      if (name.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
        print('ERROR: Empty fields detected');
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'message': 'All fields are required'};
      }

      // Normalize email to lowercase
      final normalizedEmail = email.toLowerCase().trim();
      print('Checking for existing user with email: $normalizedEmail');

      // Check if user already exists
      final existingUser = await DatabaseHelper.instance.getUserByEmail(normalizedEmail);
      if (existingUser != null) {
        print('ERROR: User already exists with this email');
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'message': 'This email is already registered'};
      }

      print('No existing user found. Creating new user...');
      final user = User(
        name: name.trim(),
        email: normalizedEmail,
        passwordHash: _hashPassword(password),
      );

      print('Inserting user into database...');
      final id = await DatabaseHelper.instance.createUser(user);
      print('User created successfully with ID: $id');
      
      _currentUser = user.copyWith(id: id);

      // Save session after successful registration (non-blocking)
      print('Saving session...');
      _saveSession(id).catchError((e) {
        print('Session save failed but registration succeeded: $e');
      });

      _isLoading = false;
      notifyListeners();
      print('=== REGISTRATION COMPLETED SUCCESSFULLY ===');
      return {'success': true, 'message': 'Registration successful'};
    } catch (e) {
      print('ERROR during registration: $e');
      _isLoading = false;
      notifyListeners();
      // Check if it's a duplicate email error from database
      if (e.toString().contains('UNIQUE constraint failed')) {
        return {'success': false, 'message': 'This email is already registered'};
      }
      return {'success': false, 'message': 'Registration failed: ${e.toString()}'};
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final normalizedEmail = email.toLowerCase().trim();
      final user = await DatabaseHelper.instance.getUserByEmail(normalizedEmail);
      if (user == null || user.passwordHash != _hashPassword(password)) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = user;

      // Save session
      await _saveSession(user.id!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _clearSession();
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? name,
    String? email,
    String? profilePicture,
  }) async {
    if (_currentUser == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      final updatedUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        email: email ?? _currentUser!.email,
        profilePicture: profilePicture ?? _currentUser!.profilePicture,
      );

      await DatabaseHelper.instance.updateUser(updatedUser);
      _currentUser = updatedUser;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (_currentUser == null) return false;

    try {
      if (_currentUser!.passwordHash != _hashPassword(oldPassword)) {
        return false;
      }

      final updatedUser = _currentUser!.copyWith(
        passwordHash: _hashPassword(newPassword),
      );

      await DatabaseHelper.instance.updateUser(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
