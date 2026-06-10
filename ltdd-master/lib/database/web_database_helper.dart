// File: lib/database/web_database_helper.dart
// Mock Database cho Web (dùng LocalStorage)

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WebDatabaseHelper {
  static final WebDatabaseHelper instance = WebDatabaseHelper._init();
  late SharedPreferences _prefs;

  WebDatabaseHelper._init();

  Future<void> initDatabase() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final key = 'table_$table';
    final data = _prefs.getString(key);
    if (data == null) return [];

    List<dynamic> items = json.decode(data);
    List<Map<String, dynamic>> result =
        items.cast<Map<String, dynamic>>();

    return result;
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final key = 'table_$table';
    final existing = _prefs.getString(key);
    List<Map<String, dynamic>> items = [];

    if (existing != null) {
      items = List<Map<String, dynamic>>.from(
        json.decode(existing),
      );
    }

    items.add(data);
    await _prefs.setString(key, json.encode(items));
    return items.length;
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    return 0;
  }

  Future<int> delete(
    String table, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    return 0;
  }

  Future<void> clearTable(String table) async {
    final key = 'table_$table';
    await _prefs.remove(key);
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    return {
      'totalRevenue': 0.0,
      'totalOrders': 0,
      'totalProducts': 0,
      'totalUsers': 0,
      'todayOrders': 0,
    };
  }

  Future<List<Map<String, dynamic>>> getRecentOrders({int limit = 5}) async {
    return [];
  }

  Future<List<Map<String, dynamic>>> getRevenueTrend({required int days}) async {
    return [];
  }

  Future<void> addAuditLog({
    required String adminId,
    required String action,
    required String entityType,
    required String entityId,
    String? changes,
  }) async {
    // Implement if needed
  }
}