import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doan_lttdd/models/user_model.dart';
import 'package:doan_lttdd/database/database_helper.dart';

class UserAdminProvider with ChangeNotifier {
  static const String _webUsersKey = 'users';
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<User> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  User? _selectedUser;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get selectedUser => _selectedUser;

  UserAdminProvider() {
    _init();
  }

  Future<void> _init() async {
    await fetchUsers();
  }

  Future<List<Map<String, dynamic>>> _loadWebUserMaps() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUsers = prefs.getStringList(_webUsersKey) ?? [];
    return rawUsers
        .map((raw) => Map<String, dynamic>.from(json.decode(raw)))
        .toList();
  }

  Future<void> _saveWebUserMaps(List<Map<String, dynamic>> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _webUsersKey,
      users.map((user) => json.encode(user)).toList(),
    );
  }

  bool _isNormalUser(Map<String, dynamic> data) {
    return (data['role']?.toString() ?? 'user') == 'user';
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  Future<Map<String, dynamic>?> _findStoredUserMap(String userId) async {
    if (kIsWeb) {
      final users = await _loadWebUserMaps();
      try {
        return users.firstWhere((user) => user['id']?.toString() == userId);
      } catch (_) {
        return null;
      }
    }

    final rows = await _dbHelper.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return rows.isEmpty ? null : Map<String, dynamic>.from(rows.first);
  }

  Map<String, dynamic> _userToStoredMap(User user, {String? password}) {
    final data = user.toJson();
    if (password != null) {
      data['password'] = password;
    }
    return data;
  }

  Future<void> fetchUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userData = kIsWeb
          ? (await _loadWebUserMaps()).where(_isNormalUser).toList()
          : await _dbHelper.getAllUsersForAdmin();

      _users = userData.map((data) => User.fromJson(data)).toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to fetch users: $e';
      print('Fetch users error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUsers() async {
    await fetchUsers();
  }

  User? getUserById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (_) {
      return null;
    }
  }

  void selectUser(User user) {
    _selectedUser = user;
    notifyListeners();
  }

  Future<bool> addUser({
    required String email,
    required String name,
    String? password,
    String? phone,
    String? address,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cleanEmail = email.trim();
      final cleanName = name.trim();
      final cleanPassword = password?.trim() ?? '';

      if (cleanEmail.isEmpty || cleanName.isEmpty) {
        _errorMessage = 'Email and name are required';
        return false;
      }

      if (cleanPassword.isEmpty || cleanPassword.length < 6) {
        _errorMessage = 'Password must be at least 6 characters';
        return false;
      }

      final normalizedEmail = _normalizeEmail(cleanEmail);
      final exists = kIsWeb
          ? (await _loadWebUserMaps()).any(
              (user) => _normalizeEmail(user['email']?.toString() ?? '') == normalizedEmail,
            )
          : (await _dbHelper.query(
              'users',
              where: 'LOWER(TRIM(email)) = ?',
              whereArgs: [normalizedEmail],
              limit: 1,
            ))
              .isNotEmpty;

      if (exists) {
        _errorMessage = 'Email already exists';
        return false;
      }

      final newUser = User(
        id: 'u${DateTime.now().millisecondsSinceEpoch}',
        email: cleanEmail,
        name: cleanName,
        phone: phone?.trim() ?? '',
        address: address?.trim() ?? '',
        role: 'user',
        isActive: true,
        createdAt: DateTime.now(),
        avatarUrl: '',
        points: 0,
      );

      final userMap = _userToStoredMap(newUser, password: cleanPassword);

      if (kIsWeb) {
        final users = await _loadWebUserMaps();
        users.add(userMap);
        await _saveWebUserMaps(users);
      } else {
        await _dbHelper.insert('users', userMap);
      }

      _users.add(newUser);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add user: $e';
      print('Add user error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUser({
    required String userId,
    required String name,
    required String email,
    String? phone,
    String? address,
    bool? isActive,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cleanEmail = email.trim();
      final cleanName = name.trim();

      if (cleanName.isEmpty || cleanEmail.isEmpty) {
        _errorMessage = 'Name and email are required';
        return false;
      }

      final index = _users.indexWhere((user) => user.id == userId);
      if (index == -1) {
        _errorMessage = 'User not found';
        return false;
      }

      final normalizedEmail = _normalizeEmail(cleanEmail);
      final emailUsed = kIsWeb
          ? (await _loadWebUserMaps()).any(
              (user) =>
                  user['id']?.toString() != userId &&
                  _normalizeEmail(user['email']?.toString() ?? '') == normalizedEmail,
            )
          : (await _dbHelper.query(
              'users',
              where: 'LOWER(TRIM(email)) = ? AND id != ?',
              whereArgs: [normalizedEmail, userId],
              limit: 1,
            ))
              .isNotEmpty;

      if (emailUsed) {
        _errorMessage = 'Email already used by another user';
        return false;
      }

      final current = _users[index];
      final storedUser = await _findStoredUserMap(userId);
      final password = storedUser?['password']?.toString();
      final updatedUser = User(
        id: current.id,
        email: cleanEmail,
        name: cleanName,
        avatarUrl: current.avatarUrl,
        points: current.points,
        phone: phone?.trim() ?? '',
        address: address?.trim() ?? '',
        role: current.role,
        isActive: isActive ?? current.isActive,
        createdAt: current.createdAt,
      );
      final updatedMap = _userToStoredMap(updatedUser, password: password);

      if (kIsWeb) {
        final users = await _loadWebUserMaps();
        final storedIndex = users.indexWhere((user) => user['id']?.toString() == userId);
        if (storedIndex == -1) {
          _errorMessage = 'User not found';
          return false;
        }
        users[storedIndex] = updatedMap;
        await _saveWebUserMaps(users);
      } else {
        final updatedCount = await _dbHelper.update(
          'users',
          updatedMap,
          where: 'id = ?',
          whereArgs: [userId],
        );
        if (updatedCount == 0) {
          _errorMessage = 'User not found';
          return false;
        }
      }

      _users[index] = updatedUser;
      _selectedUser = updatedUser;
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update user: $e';
      print('Update user error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteUser(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final index = _users.indexWhere((user) => user.id == userId);
      if (index == -1) {
        _errorMessage = 'User not found';
        return false;
      }

      if (_users[index].role != 'user') {
        _errorMessage = 'Cannot delete admin account';
        return false;
      }

      if (kIsWeb) {
        final users = await _loadWebUserMaps();
        final beforeLength = users.length;
        users.removeWhere(
          (user) => user['id']?.toString() == userId && _isNormalUser(user),
        );
        if (users.length == beforeLength) {
          _errorMessage = 'User not found';
          return false;
        }
        await _saveWebUserMaps(users);
      } else {
        final deletedCount = await _dbHelper.delete(
          'users',
          where: 'id = ? AND role = ?',
          whereArgs: [userId, 'user'],
        );
        if (deletedCount == 0) {
          _errorMessage = 'User not found';
          return false;
        }
      }

      _users.removeAt(index);
      if (_selectedUser?.id == userId) {
        _selectedUser = null;
      }
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete user: $e';
      print('Delete user error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleUserStatus(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final index = _users.indexWhere((user) => user.id == userId);
      if (index == -1) {
        _errorMessage = 'User not found';
        return false;
      }

      final current = _users[index];
      final storedUser = await _findStoredUserMap(userId);
      final password = storedUser?['password']?.toString();
      final updatedUser = User(
        id: current.id,
        email: current.email,
        name: current.name,
        avatarUrl: current.avatarUrl,
        points: current.points,
        phone: current.phone,
        address: current.address,
        role: current.role,
        isActive: !current.isActive,
        createdAt: current.createdAt,
      );
      final updatedMap = _userToStoredMap(updatedUser, password: password);

      if (kIsWeb) {
        final users = await _loadWebUserMaps();
        final storedIndex = users.indexWhere(
          (user) => user['id']?.toString() == userId && _isNormalUser(user),
        );
        if (storedIndex == -1) {
          _errorMessage = 'User not found';
          return false;
        }
        users[storedIndex] = updatedMap;
        await _saveWebUserMaps(users);
      } else {
        final updatedCount = await _dbHelper.update(
          'users',
          updatedMap,
          where: 'id = ? AND role = ?',
          whereArgs: [userId, 'user'],
        );
        if (updatedCount == 0) {
          _errorMessage = 'User not found';
          return false;
        }
      }

      _users[index] = updatedUser;
      if (_selectedUser?.id == userId) {
        _selectedUser = updatedUser;
      }
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to toggle user status: $e';
      print('Toggle user status error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
