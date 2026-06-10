import 'dart:convert';
import 'dart:io'; // Bắt buộc import để dùng lớp File
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doan_lttdd/models/user_model.dart';
import 'package:doan_lttdd/database/database_helper.dart';
import 'package:doan_lttdd/utils/constants.dart';
import 'package:path_provider/path_provider.dart'; // Bắt buộc import để lấy thư mục hệ thống trên Mobile
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

class AuthProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    await checkAuthStatus();
  }

  // ================= CHECK LOGIN =================
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(Constants.prefIsLoggedIn) ?? false;

      if (isLoggedIn) {
        final userData = prefs.getString(Constants.prefUser);

        if (userData != null) {
          _user = User.fromJson(json.decode(userData));
          _isAuthenticated = true;
        }
      }
    } catch (e) {
      debugPrint('CHECK AUTH ERROR: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ================= LOGIN =================
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final cleanEmail = email.trim();
      final cleanPassword = password.trim();

      if (kIsWeb) {
        final users = prefs.getStringList('users') ?? [];
        Map<String, dynamic>? foundUser;

        for (var user in users) {
          final data = json.decode(user);
          if (data['email'].toString().trim().toLowerCase() == cleanEmail.toLowerCase() &&
              data['password'].toString().trim() == cleanPassword &&
              (data['isActive'] == null || data['isActive'] == true || data['isActive'] == 1)) {
            foundUser = data;
            break;
          }
        }

        if (foundUser != null) {
          _user = User.fromJson(foundUser);
          _isAuthenticated = true;

          await prefs.setBool(Constants.prefIsLoggedIn, true);
          await prefs.setString(Constants.prefUser, json.encode(_user!.toJson()));
          await prefs.setString(Constants.prefToken, _user!.id);

          notifyListeners();
          return;
        }
        throw Exception('Invalid email or password');
      }

      final userData = await _dbHelper.query(
        Constants.tableUsers,
        where: 'LOWER(TRIM(email)) = ? AND TRIM(password) = ?',
        whereArgs: [cleanEmail.toLowerCase(), cleanPassword],
      );

      if (userData.isNotEmpty) {
        final dbUser = userData.first;
        if (dbUser['isActive'] == 0 || dbUser['isActive'] == false) {
          throw Exception('Account has been disabled');
        }

        _user = User.fromJson(dbUser);
        _isAuthenticated = true;

        await prefs.setBool(Constants.prefIsLoggedIn, true);
        await prefs.setString(Constants.prefUser, json.encode(_user!.toJson()));
        await prefs.setString(Constants.prefToken, _user!.id);

        notifyListeners();
      } else {
        throw Exception('Invalid email or password');
      }
    } catch (e) {
      _isAuthenticated = false;
      notifyListeners();
      throw Exception('Login failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================= REGISTER =================
  Future<void> register(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final cleanEmail = email.trim();
      final cleanPassword = password.trim();
      final cleanName = name.trim();

      if (kIsWeb) {
        final users = prefs.getStringList('users') ?? [];
        final exists = users.any((u) {
          final data = json.decode(u);
          return data['email'].toString().trim().toLowerCase() == cleanEmail.toLowerCase();
        });

        if (exists) {
          throw Exception('Email already exists');
        }

        final userId = const Uuid().v4();
        final userMap = {
          'id': userId,
          'email': cleanEmail,
          'password': cleanPassword,
          'name': cleanName,
          'points': 0,
          'phone': '',
          'address': '',
          'avatarUrl': '',
          'role': 'user',
          'isActive': true,
          'createdAt': DateTime.now().toIso8601String(),
        };

        users.add(json.encode(userMap));
        await prefs.setStringList('users', users);

        _user = User.fromJson(userMap);
        _isAuthenticated = true;

        await prefs.setBool(Constants.prefIsLoggedIn, true);
        await prefs.setString(Constants.prefUser, json.encode(_user!.toJson()));
        await prefs.setString(Constants.prefToken, userId);

        notifyListeners();
        return;
      }

      final existingUser = await _dbHelper.query(
        Constants.tableUsers,
        where: 'LOWER(TRIM(email)) = ?',
        whereArgs: [cleanEmail.toLowerCase()],
      );

      if (existingUser.isNotEmpty) {
        throw Exception('Email already exists');
      }

      final userId = const Uuid().v4();
      _user = User(
        id: userId,
        email: cleanEmail,
        name: cleanName,
        points: 0,
        role: 'user',
        isActive: true,
        createdAt: DateTime.now(),
      );

      final userData = _user!.toJson();
      userData['password'] = cleanPassword;

      await _dbHelper.insert(Constants.tableUsers, userData);
      _isAuthenticated = true;

      await prefs.setBool(Constants.prefIsLoggedIn, true);
      await prefs.setString(Constants.prefUser, json.encode(_user!.toJson()));
      await prefs.setString(Constants.prefToken, userId);

      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      notifyListeners();
      throw Exception('Registration failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = null;
      _isAuthenticated = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(Constants.prefIsLoggedIn);
      await prefs.remove(Constants.prefUser);
      await prefs.remove(Constants.prefToken);

      notifyListeners();
    } catch (e) {
      throw Exception('Logout failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================= UPDATE PROFILE (ĐÃ FIX LỖI CÚ PHÁP) =================
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? avatarUrl,
    File? avatarFile,
  }) async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      if (name != null) _user!.name = name;
      if (phone != null) _user!.phone = phone;
      if (address != null) _user!.address = address;
      if (avatarUrl != null) _user!.avatarUrl = avatarUrl;

      // ---- XỬ LÝ LƯU FILE CỤC BỘ XUỐNG BỘ NHỚ AN TOÀN ----
      if (avatarFile != null) {
        if (kIsWeb) {
          _user!.avatarUrl = avatarFile.path;
        } else {
          try {
            final directory = await getApplicationDocumentsDirectory();
            final String extension = avatarFile.path.split('.').last;
            final String newFileName = 'avatar_${_user!.id}_${DateTime.now().millisecondsSinceEpoch}.$extension';
            final String newPath = '${directory.path}/$newFileName';

            final File savedFile = await avatarFile.copy(newPath);
            _user!.avatarUrl = savedFile.path;
          } catch (e) {
            debugPrint('Save avatar error: $e');
            _user!.avatarUrl = avatarFile.path;
          }
        }
      }

      // ===== CẬP NHẬT DATABASE =====
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final users = prefs.getStringList('users') ?? [];
        List<String> updatedUsers = [];
        for (var u in users) {
          final data = json.decode(u);
          if (data['id'] == _user!.id) {
            data['name'] = _user!.name;
            data['phone'] = _user!.phone;
            data['address'] = _user!.address;
            data['avatarUrl'] = _user!.avatarUrl;
            updatedUsers.add(json.encode(data));
          } else {
            updatedUsers.add(u);
          }
        }
        await prefs.setStringList('users', updatedUsers);
      } else {
        await _dbHelper.update(
          Constants.tableUsers,
          {
            'name': _user!.name,
            'phone': _user!.phone,
            'address': _user!.address,
            'avatarUrl': _user!.avatarUrl,
          },
          where: 'id = ?',
          whereArgs: [_user!.id],
        );
      }

      // Đồng bộ Session Preferences hiện tại
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(Constants.prefUser, json.encode(_user!.toJson()));

      notifyListeners();
    } catch (e) {
      debugPrint('UPDATE PROFILE ERROR: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================= ADD POINTS =================
  Future<void> addPoints(int points) async {
    if (_user == null) return;

    _user!.points += points;

    await _dbHelper.update(
      Constants.tableUsers,
      {'points': _user!.points},
      where: 'id = ?',
      whereArgs: [_user!.id],
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.prefUser, json.encode(_user!.toJson()));

    notifyListeners();
  }
}