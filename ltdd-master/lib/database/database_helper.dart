import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io' show Platform;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('shopping_app.db');
    return _database!;
  }

  Future<void> initDatabase() async {
    await database;
  }

  Future<Database> _initDB(String fileName) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, fileName);

    return await openDatabase(
      path,
      version: 4, // Cập nhật version
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _seedProducts(db);
        }
        if (oldVersion < 3) {
          await _createAdminTables(db);
        }
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // ===== USERS TABLE =====
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE,
        password TEXT,
        name TEXT,
        avatarUrl TEXT,
        points INTEGER,
        phone TEXT,
        address TEXT,
        syncStatus TEXT,
        role TEXT DEFAULT 'user',
        isActive INTEGER DEFAULT 1,
        createdAt TEXT
      )
    ''');

    // ===== PRODUCTS TABLE =====
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT,
        description TEXT,
        price REAL,
        discountPrice REAL,
        category TEXT,
        images TEXT,
        stock INTEGER,
        rating REAL,
        soldCount INTEGER,
        brand TEXT,
        lastUpdated TEXT
      )
    ''');

    // ===== CART TABLE =====
    await db.execute('''
      CREATE TABLE cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId TEXT,
        name TEXT,
        imageUrl TEXT,
        price REAL,
        quantity INTEGER,
        userId TEXT
      )
    ''');

    // ===== WISHLIST TABLE =====
    await db.execute('''
      CREATE TABLE wishlist (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId TEXT,
        userId TEXT
      )
    ''');

    // ===== ORDERS TABLE =====
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        userId TEXT,
        totalAmount REAL,
        status TEXT,
        address TEXT,
        paymentMethod TEXT,
        createdAt TEXT,
        pointsUsed INTEGER,
        pointsEarned INTEGER,
        fullName TEXT,
        phone TEXT
      )
    ''');

    // ===== ORDER_ITEMS TABLE =====
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId TEXT,
        productId TEXT,
        productName TEXT,
        quantity INTEGER,
        price REAL,
        imageUrl TEXT
      )
    ''');

    // ===== ADMIN TABLES =====
    await _createAdminTables(db);

    await _seedUsers(db);
    await _seedProducts(db);
  }

  Future<void> _createAdminTables(Database db) async {
    // ===== CATEGORIES TABLE =====
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id TEXT PRIMARY KEY,
        name TEXT UNIQUE NOT NULL,
        description TEXT,
        icon TEXT,
        createdAt TEXT
      )
    ''');

    // ===== PROMOTIONS TABLE =====
    await db.execute('''
      CREATE TABLE IF NOT EXISTS promotions (
        id TEXT PRIMARY KEY,
        code TEXT UNIQUE NOT NULL,
        type TEXT,
        value REAL,
        minAmount REAL,
        maxUsage INTEGER,
        usageCount INTEGER,
        expiryDate TEXT,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT
      )
    ''');

    // ===== AUDIT_LOGS TABLE =====
    await db.execute('''
      CREATE TABLE IF NOT EXISTS audit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        adminId TEXT,
        action TEXT,
        entityType TEXT,
        entityId TEXT,
        changes TEXT,
        timestamp TEXT
      )
    ''');
  }

  Future<void> _seedUsers(Database db) async {
    // Tạo 1 admin account
    await db.insert(
      'users',
      {
        'id': 'admin1',
        'email': 'admin@gmail.com',
        'password': '123456',
        'name': 'Admin User',
        'avatarUrl': '',
        'points': 0,
        'phone': '0123456789',
        'address': 'Hồ Chí Minh',
        'syncStatus': 'local',
        'role': 'admin', // Đây là admin
        'isActive': 1,
        'createdAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.abort,    );

    // Tạo 1 user bình thường để test
    await db.insert(
      'users',
      {
        'id': 'u1',
        'email': 'test@gmail.com',
        'password': '123456',
        'name': 'Test User',
        'avatarUrl': '',
        'points': 0,
        'phone': '0123456789',
        'address': 'Hồ Chí Minh',
        'syncStatus': 'local',
        'role': 'user',
        'isActive': 1,
        'createdAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _seedProducts(Database db) async {
    final now = DateTime.now().toIso8601String();

    final products = [
      {
        'id': 'p1',
        'name': 'iPhone 15 Pro',
        'description': 'Điện thoại Apple iPhone 15 Pro, hiệu năng mạnh mẽ.',
        'price': 25990000.0,
        'discountPrice': 23990000.0,
        'category': 'Electronics',
        'images': 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=600',
        'stock': 20,
        'rating': 4.8,
        'soldCount': 120,
        'brand': 'Apple',
        'lastUpdated': now,
      },
      {
        'id': 'p2',
        'name': 'Samsung Galaxy S24',
        'description': 'Điện thoại Samsung Galaxy S24 màn hình đẹp, pin tốt.',
        'price': 21990000.0,
        'discountPrice': 19990000.0,
        'category': 'Electronics',
        'images': 'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?w=600',
        'stock': 30,
        'rating': 4.7,
        'soldCount': 98,
        'brand': 'Samsung',
        'lastUpdated': now,
      },
      {
        'id': 'p3',
        'name': 'Áo thun nam basic',
        'description': 'Áo thun cotton form rộng, dễ phối đồ.',
        'price': 199000.0,
        'discountPrice': 149000.0,
        'category': 'Fashion',
        'images': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600',
        'stock': 100,
        'rating': 4.5,
        'soldCount': 300,
        'brand': 'Local Brand',
        'lastUpdated': now,
      },
      {
        'id': 'p4',
        'name': 'Giày sneaker trắng',
        'description': 'Giày sneaker thời trang, phù hợp đi học và đi chơi.',
        'price': 799000.0,
        'discountPrice': 699000.0,
        'category': 'Fashion',
        'images': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600',
        'stock': 50,
        'rating': 4.6,
        'soldCount': 210,
        'brand': 'Sneaker',
        'lastUpdated': now,
      },
      {
        'id': 'p5',
        'name': 'Ghế làm việc Ergonomic',
        'description': 'Ghế văn phòng công thái học, hỗ trợ lưng tốt.',
        'price': 2990000.0,
        'discountPrice': 2590000.0,
        'category': 'Home',
        'images': 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=600',
        'stock': 15,
        'rating': 4.9,
        'soldCount': 60,
        'brand': 'HomePro',
        'lastUpdated': now,
      },
      {
        'id': 'p6',
        'name': 'Đèn ngủ để bàn',
        'description': 'Đèn ngủ ánh sáng ấm, thiết kế tối giản.',
        'price': 299000.0,
        'discountPrice': 249000.0,
        'category': 'Home',
        'images': 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=600',
        'stock': 45,
        'rating': 4.4,
        'soldCount': 150,
        'brand': 'Decor',
        'lastUpdated': now,
      },
    ];

    for (final product in products) {
      await db.insert(
        'products',
        product,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // ===== EXISTING METHODS (from original file) =====
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;
    return await db.update(
      table,
      data,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<int> delete(
    String table, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;
    return await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<void> clearTable(String table) async {
    final db = await database;
    await db.delete(table);
  }

  Future<void> addToCart(
    String userId,
    String productId,
    String name,
    String imageUrl,
    double price,
    int quantity, // ← Thêm tham số quantity
  ) async {
    final db = await database;
    final existing = await db.query(
      'cart',
      where: 'userId = ? AND productId = ?',
      whereArgs: [userId, productId],
    );

    if (existing.isNotEmpty) {
      await db.update(
        'cart',
        {'quantity': (existing.first['quantity'] as int) + 1},
        where: 'userId = ? AND productId = ?',
        whereArgs: [userId, productId],
      );
    } else {
      await db.insert('cart', {
        'productId': productId,
        'name': name,
        'imageUrl': imageUrl,
        'price': price,
        'quantity': quantity,
        'userId': userId,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getCartItems(String userId) async {
    final db = await database;
    return await db.query('cart', where: 'userId = ?', whereArgs: [userId]);
  }

  Future<void> increaseQuantity(String userId, String productId) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE cart SET quantity = quantity + 1 WHERE userId = ? AND productId = ?',
      [userId, productId],
    );
  }

  Future<void> decreaseQuantity(String userId, String productId) async {
    final db = await database;
    final existing = await db.query(
      'cart',
      where: 'userId = ? AND productId = ?',
      whereArgs: [userId, productId],
    );

    if (existing.isNotEmpty && (existing.first['quantity'] as int) > 1) {
      await db.rawUpdate(
        'UPDATE cart SET quantity = quantity - 1 WHERE userId = ? AND productId = ?',
        [userId, productId],
      );
    } else {
      await removeFromCart(userId, productId);
    }
  }

  Future<void> removeFromCart(String userId, String productId) async {
    final db = await database;
    await db.delete(
      'cart',
      where: 'userId = ? AND productId = ?',
      whereArgs: [userId, productId],
    );
  }

  Future<void> clearCart(String userId) async {
    final db = await database;
    await db.delete('cart', where: 'userId = ?', whereArgs: [userId]);
  }

  Future<double> getTotalPrice(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(price * quantity) as total FROM cart WHERE userId = ?',
      [userId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<String> createOrder({
    required String userId,
    required String fullName,
    required String phone,
    required String address,
    required double totalAmount,
    String paymentMethod = 'COD',
  }) async {
    final db = await database;
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();

    await db.insert('orders', {
      'id': orderId,
      'userId': userId,
      'totalAmount': totalAmount,
      'status': 'pending',
      'address': address,
      'paymentMethod': paymentMethod,
      'createdAt': DateTime.now().toIso8601String(),
      'pointsUsed': 0,
      'pointsEarned': 0,
      'fullName': fullName,
      'phone': phone,
    });

    return orderId;
  }

  Future<void> insertOrderDetail(
    String orderId,
    Map<String, dynamic> cartItem,
  ) async {
    final db = await database;

    await db.insert('order_items', {
      'orderId': orderId,
      'productId': cartItem['productId'],
      'productName': cartItem['name'],
      'quantity': cartItem['quantity'],
      'price': cartItem['price'],
      'imageUrl': cartItem['imageUrl'],
    });
  }

  Future<String> checkoutCart({
    required String userId,
    required String fullName,
    required String phone,
    required String address,
    String paymentMethod = 'COD',
  }) async {
    final cartItems = await getCartItems(userId);

    double total = 0;
    for (final item in cartItems) {
      total += (item['price'] as num).toDouble() * (item['quantity'] as int);
    }

    final orderId = await createOrder(
      userId: userId,
      fullName: fullName,
      phone: phone,
      address: address,
      totalAmount: total,
      paymentMethod: paymentMethod,
    );

    for (final item in cartItems) {
      await insertOrderDetail(orderId, item);
    }

    await clearCart(userId);
    return orderId;
  }

  // ===== NEW ADMIN METHODS =====

  // ===== CATEGORIES =====
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await database;
    return await db.query('categories', orderBy: 'name ASC');
  }

  Future<void> addCategory({
    required String id,
    required String name,
    required String description,
    String? icon,
  }) async {
    final db = await database;
    await db.insert('categories', {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    required String description,
    String? icon,
  }) async {
    final db = await database;
    await db.update(
      'categories',
      {
        'name': name,
        'description': description,
        'icon': icon,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteCategory(String categoryId) async {
    final db = await database;
    await db.delete('categories', where: 'id = ?', whereArgs: [categoryId]);
  }

  // ===== PROMOTIONS =====
  Future<List<Map<String, dynamic>>> getAllPromotions() async {
    final db = await database;
    return await db.query('promotions', orderBy: 'createdAt DESC');
  }

  Future<void> addPromotion({
    required String id,
    required String code,
    required String type,
    required double value,
    double? minAmount,
    int? maxUsage,
    DateTime? expiryDate,
  }) async {
    final db = await database;
    await db.insert('promotions', {
      'id': id,
      'code': code,
      'type': type,
      'value': value,
      'minAmount': minAmount,
      'maxUsage': maxUsage,
      'usageCount': 0,
      'expiryDate': expiryDate?.toIso8601String(),
      'isActive': 1,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deletePromotion(String promotionId) async {
    final db = await database;
    await db.delete('promotions', where: 'id = ?', whereArgs: [promotionId]);
  }

  // ===== AUDIT LOGS =====
  Future<void> addAuditLog({
    required String adminId,
    required String action,
    required String entityType,
    required String entityId,
    String? changes,
  }) async {
    final db = await database;
    await db.insert('audit_logs', {
      'adminId': adminId,
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'changes': changes,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getAuditLogs({int limit = 50}) async {
    final db = await database;
    return await db.query(
      'audit_logs',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
  }

  // ===== STATISTICS & DASHBOARD =====
  Future<Map<String, dynamic>> getDashboardStats() async {
    final db = await database;

    // Total revenue
    final revenueResult = await db.rawQuery(
      'SELECT SUM(totalAmount) as total FROM orders WHERE status != "cancelled"',
    );
    final totalRevenue =
        (revenueResult.first['total'] as num?)?.toDouble() ?? 0.0;

    // Total orders
    final ordersResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM orders',
    );
    final totalOrders = (ordersResult.first['count'] as int?) ?? 0;

    // Total products
    final productsResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM products',
    );
    final totalProducts = (productsResult.first['count'] as int?) ?? 0;

    // Total users (excluding admins)
    final usersResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM users WHERE role != "admin"',
    );
    final totalUsers = (usersResult.first['count'] as int?) ?? 0;

    // Today's orders
    final todayResult = await db.rawQuery(
      '''SELECT COUNT(*) as count FROM orders 
         WHERE DATE(createdAt) = DATE('now')''',
    );
    final todayOrders = (todayResult.first['count'] as int?) ?? 0;

    return {
      'totalRevenue': totalRevenue,
      'totalOrders': totalOrders,
      'totalProducts': totalProducts,
      'totalUsers': totalUsers,
      'todayOrders': todayOrders,
    };
  }

  Future<List<Map<String, dynamic>>> getRecentOrders({int limit = 5}) async {
    final db = await database;
    return await db.query(
      'orders',
      orderBy: 'createdAt DESC',
      limit: limit,
    );
  }

  Future<List<Map<String, dynamic>>> getRevenueTrend({required int days}) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        DATE(createdAt) as date,
        SUM(totalAmount) as revenue,
        COUNT(*) as orderCount
      FROM orders
      WHERE createdAt >= datetime('now', '-$days days')
      AND status != 'cancelled'
      GROUP BY DATE(createdAt)
      ORDER BY date ASC
    ''');
  }

  Future<List<Map<String, dynamic>>> getTopProducts({int limit = 10}) async {
    final db = await database;
    return await db.query(
      'products',
      orderBy: 'soldCount DESC',
      limit: limit,
    );
  }

  Future<List<Map<String, dynamic>>> getAllUsersForAdmin() async {
    final db = await database;
    return await db.query(
      'users',
      where: 'role = ?',
      whereArgs: ['user'],
      orderBy: 'createdAt DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getOrdersByStatus(
      String status) async {
    final db = await database;
    return await db.query(
      'orders',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'createdAt DESC',
    );
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final db = await database;
    await db.update(
      'orders',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }
}