import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:maternal_infant_care/core/theme/app_theme.dart';
import 'package:maternal_infant_care/core/utils/notification_service.dart';
import 'package:maternal_infant_care/data/local/hive_adapters.dart';
import 'package:maternal_infant_care/presentation/pages/splash_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maternal_infant_care/core/constants/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Handle Flutter errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter Error: ${details.exception}');
    print('Stack: ${details.stack}');
  };
  
  // Handle async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    print('Platform Error: $error');
    print('Stack: $stack');
    return true;
  };
  
  try {
    await Hive.initFlutter();
    await HiveAdapters.registerAdapters();
    
    // Load Environment Variables
    await dotenv.load(fileName: ".env");

    // Initialize Supabase
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );

    
    try {
      await NotificationService.initialize();
    } catch (e) {
      print('Notification service initialization failed: $e');
      // Continue without notifications
    }
    
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (e, stackTrace) {
    print('Initialization error: $e');
    print('Stack trace: $stackTrace');
    // Still run the app even if initialization fails
  }
  
  runApp(
    const ProviderScope(
      child: VatsalyaApp(),
    ),
  );
}

class VatsalyaApp extends StatelessWidget {
  const VatsalyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vatsalya',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: const SplashPage(),
    );
  }
}
