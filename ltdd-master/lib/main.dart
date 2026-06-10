import 'package:doan_lttdd/provider/admin_auth_provide.dart';
import 'package:doan_lttdd/screens/home_screen.dart';
import 'package:doan_lttdd/screens/auth/login_screen.dart';
import 'package:doan_lttdd/screens/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doan_lttdd/provider/auth_provider.dart';
import 'package:doan_lttdd/provider/cart_provider.dart';
import 'package:doan_lttdd/provider/wishlist_provider.dart';
import 'package:doan_lttdd/provider/product_provider.dart';
import 'package:doan_lttdd/provider/order_provider.dart';
import 'package:doan_lttdd/screens/splash_screen.dart';
import 'package:doan_lttdd/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:doan_lttdd/screens/admin/admin_dashboard_home_screen.dart';
import 'package:doan_lttdd/provider/user_admin_provider.dart';
import 'package:doan_lttdd/provider/product_admin_provider.dart';
import 'package:doan_lttdd/provider/order_admin_provider.dart';
import 'package:doan_lttdd/provider/chat_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    await DatabaseHelper.instance.initDatabase();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => AdminAuthProvider()),
        ChangeNotifierProvider(create: (_) => UserAdminProvider()),
        ChangeNotifierProvider(create: (_) => ProductAdminProvider()),
        ChangeNotifierProvider(create: (_) => OrderAdminProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'Premium Cyber Store',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F0C1B),
          primaryColor: const Color(0xFFD946EF),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFD946EF),
            secondary: Color(0xFF8B5CF6),
            surface: Color(0xFF1E1A33),
          ),
          cardColor: Colors.white.withOpacity(0.06),
          fontFamily: 'Poppins',
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            iconTheme: IconThemeData(color: Colors.white),
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/cart': (context) => const CartScreen(),
          '/admin-dashboard': (context) => const AdminDashboardHomeScreen(),
        },
      ),
    );
  }
}