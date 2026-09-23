import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/database/DeviceIdHelper.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/database/database_helper.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/reports/presentation/screens/device_mismatch_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;
  await DatabaseHelper.instance.database;

  final isValidDevice = await LicenseGuard.validateDevice();

  runApp(FoodProApp(isValidDevice: isValidDevice));
}

/// نقطة الدخول الرئيسية لنظام فود برو
class FoodProApp extends StatelessWidget {
  final bool isValidDevice;
  const FoodProApp({super.key, required this.isValidDevice});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,

      // ─── دعم التعريب الكامل (ضروري لـ Date Pickers و Dialogs) ──────
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
      locale: const Locale('ar'),

      // ─── الـ Theme المركزي ─────────────────────────────────────────
      theme: AppTheme.light,

      // ─── الشاشة الرئيسية مع RTL ───────────────────────────────────
      home: isValidDevice ? const LoginScreen() : const DeviceMismatchScreen(),
    );
  }
}
