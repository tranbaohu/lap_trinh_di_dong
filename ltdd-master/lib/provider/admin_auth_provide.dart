import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:doan_lttdd/models/user_model.dart';
import 'package:doan_lttdd/database/database_helper.dart';
 
class AdminAuthProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
 
  User? _adminUser;
  bool _isAdminAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
 
  // Getters
  User? get adminUser => _adminUser;
  bool get isAdminAuthenticated => _isAdminAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAdmin => _adminUser?.role == 'admin';
  String get adminName => _adminUser?.name ?? 'Admin';
 
  AdminAuthProvider() {
    _init();
  }
 
  Future<void> _init() async {
    await checkAdminStatus();
  }
 
  /// Check if running on web
  bool _isWebPlatform() {
    try {
      return identical(0, 0.0) == false; // Web-specific check
    } catch (e) {
      return false;
    }
  }
 
  /// Kiểm tra xem có admin đã login chưa
  Future<void> checkAdminStatus() async {
    _isLoading = true;
    notifyListeners();
 
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('adminIsLoggedIn') ?? false;
 
      if (isLoggedIn) {
        final adminData = prefs.getString('adminUser');
        if (adminData != null) {
          _adminUser = User.fromJson(json.decode(adminData));
 
          // Verify admin role
          if (_adminUser?.role == 'admin') {
            _isAdminAuthenticated = true;
          } else {
            await logout();
          }
        }
      }
    } catch (e) {
      _errorMessage = 'Error checking admin status: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
 
  /// Admin login
  Future<bool> loginAdmin(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
 
    try {
      // 🌐 WEB MODE - Hardcoded test credentials
      // For web, we use SharedPreferences to store admin data
      if (email == 'admin@gmail.com' && password == '123456') {
        _adminUser = User(
          id: 'admin1',
          email: email,
          name: 'Admin User',
          avatarUrl: '',
          points: 0,
          phone: '0123456789',
          address: 'Hồ Chí Minh',
          role: 'admin',
          isActive: true,
          createdAt: DateTime.now(),
        );
        _isAdminAuthenticated = true;
 
        // Lưu vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('adminIsLoggedIn', true);
        await prefs.setString('adminUser', json.encode(_adminUser!.toJson()));
        await prefs.setString('adminToken', _adminUser!.id);
 
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid admin credentials';
        _isAdminAuthenticated = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login failed: $e';
      print('Login error: $e');
      _isAdminAuthenticated = false;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
 
  /// Admin logout
  Future<void> logout() async {
    _adminUser = null;
    _isAdminAuthenticated = false;
 
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('adminIsLoggedIn');
    await prefs.remove('adminUser');
    await prefs.remove('adminToken');
 
    notifyListeners();
  }
 
  /// Cập nhật profile admin
  Future<void> updateAdminProfile({
    String? name,
    String? phone,
    String? address,
    String? avatarUrl,
  }) async {
    if (_adminUser == null) return;
 
    _isLoading = true;
    notifyListeners();
 
    try {
      if (name != null) _adminUser!.name = name;
      if (phone != null) _adminUser!.phone = phone;
      if (address != null) _adminUser!.address = address;
      if (avatarUrl != null) _adminUser!.avatarUrl = avatarUrl;
 
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('adminUser', json.encode(_adminUser!.toJson()));
 
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update profile: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
 
  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}