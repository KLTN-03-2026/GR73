import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';
import '../models/user.dart';
import '../config/constants.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null && _token != null;

  AuthProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final userJson = prefs.getString(AppConstants.userKey);

    if (token != null && userJson != null) {
      _token = token;
      try {
        final Map<String, dynamic> userMap = json.decode(userJson) as Map<String, dynamic>;
        _user = User.fromJson(userMap);
        notifyListeners();
      } catch (e) {
        await prefs.remove(AppConstants.userKey);
      }
    }
  }

  Future<void> _saveUserData(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
    await prefs.setString(AppConstants.userKey, json.encode(user.toJson()));
    await prefs.setBool(AppConstants.isLoggedInKey, true);
  }

  Future<void> refreshUser() async {
    if (_user == null) return;
    try {
      final fresh = await FirebaseService.getUser(_user!.id);
      if (fresh != null) {
        _user = fresh;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.userKey, json.encode(_user!.toJson()));
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final firebaseUser = await FirebaseService.signInWithEmail(
        email: email,
        password: password,
      );
      if (firebaseUser == null) {
        throw Exception('Đăng nhập thất bại');
      }
      final firestoreUser = await FirebaseService.getUser(firebaseUser.uid);
      if (firestoreUser == null) {
        final minimal = User(
          id: firebaseUser.uid,
          email: email,
          name: firebaseUser.displayName ?? 'Người dùng',
          phone: firebaseUser.phoneNumber,
          createdAt: DateTime.now(),
        );
        await FirebaseService.upsertUser(minimal);
        _user = minimal;
      } else {
        _user = firestoreUser;
      }
      _token = 'firebase_${firebaseUser.uid}';
      await _saveUserData(_token!, _user!);
      await _ensureAdminByEmail();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password, String name, String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final firebaseUser = await FirebaseService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      if (firebaseUser == null) {
        throw Exception('Đăng ký thất bại');
      }
      final newUser = User(
        id: firebaseUser.uid,
        email: email,
        name: name,
        phone: phone,
        createdAt: DateTime.now(),
      );
      await FirebaseService.upsertUser(newUser);
      // Không tự đăng nhập
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final firebaseUser = await FirebaseService.signInWithGoogle();
      if (firebaseUser == null) {
        throw Exception('Đăng nhập Google bị huỷ');
      }
      final firestoreUser = await FirebaseService.getUser(firebaseUser.uid);
      if (firestoreUser == null) {
        final minimal = User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'Người dùng',
          phone: firebaseUser.phoneNumber,
          avatarUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
        );
        await FirebaseService.upsertUser(minimal);
        _user = minimal;
      } else {
        _user = firestoreUser;
      }
      _token = 'firebase_${firebaseUser.uid}';
      await _saveUserData(_token!, _user!);
      await _ensureAdminByEmail();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
    await prefs.remove(AppConstants.isLoggedInKey);
    
    _user = null;
    _token = null;
    _error = null;
    notifyListeners();
  }
  
  Future<void> loginWithFacebook() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final firebaseUser = await FirebaseService.signInWithFacebook();
      if (firebaseUser == null) {
        _error = 'Đăng nhập Facebook bị huỷ';
        return;
      }
      final firestoreUser = await FirebaseService.getUser(firebaseUser.uid);
      if (firestoreUser == null) {
        final minimal = User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'Người dùng',
          phone: firebaseUser.phoneNumber,
          avatarUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
        );
        await FirebaseService.upsertUser(minimal);
        _user = minimal;
      } else {
        _user = firestoreUser;
      }
      _token = 'firebase_${firebaseUser.uid}';
      await _saveUserData(_token!, _user!);
      await _ensureAdminByEmail();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(String name, String phone, String? avatarUrl) async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      _user = User(
        id: _user!.id,
        email: _user!.email,
        name: name,
        phone: phone,
        avatarUrl: avatarUrl ?? _user!.avatarUrl,
        createdAt: _user!.createdAt,
        role: _user!.role,
        isVerified: _user!.isVerified,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userKey, json.encode(_user!.toJson()));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setRole(String role) async {
    if (_user == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      if (role == 'admin') {
        final email = (_user!.email).trim().toLowerCase();
        final allowed = AppConstants.adminEmails.map((e) => e.trim().toLowerCase()).contains(email);
        if (!allowed) {
          throw Exception('Tài khoản hiện tại không có quyền admin');
        }
      }
      await FirebaseService.setUserRole(userId: _user!.id, role: role);
      _user = User(
        id: _user!.id,
        email: _user!.email,
        name: _user!.name,
        phone: _user!.phone,
        avatarUrl: _user!.avatarUrl,
        createdAt: _user!.createdAt,
        role: role,
        isVerified: _user!.isVerified,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userKey, json.encode(_user!.toJson()));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _ensureAdminByEmail() async {
    try {
      if (_user == null) return;
      final email = (_user!.email).trim().toLowerCase();
      final allowed = AppConstants.adminEmails.map((e) => e.trim().toLowerCase()).contains(email);
      if (allowed && _user!.role != 'admin') {
        await setRole('admin');
      }
    } catch (_) {}
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
