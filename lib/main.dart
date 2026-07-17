import 'dart:io';

import 'package:attendance_management_system/app/theme/app_theme.dart';
import 'package:attendance_management_system/data/providers/academic_session_provider.dart';
import 'package:attendance_management_system/data/providers/auth_provider.dart';
import 'package:attendance_management_system/data/providers/course_provider.dart';
import 'package:attendance_management_system/data/providers/level_provider.dart';
import 'package:attendance_management_system/data/services/academic_session_service.dart';
import 'package:attendance_management_system/data/services/course_service.dart';
import 'package:attendance_management_system/data/services/level_service.dart';
import 'package:attendance_management_system/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:provider/provider.dart';

import 'data/database/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await DatabaseService.instance.database;

  // await DatabaseService.instance.deleteDatabaseFile();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => CourseProvider(CourseService.instance),
        ),
        ChangeNotifierProvider(
          create: (_) => LevelProvider(LevelService.instance),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              AcademicSessionProvider(AcademicSessionSerivce.instance),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
