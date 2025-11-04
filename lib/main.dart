import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'firebase_options.dart';
import 'config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/storage/database_helper.dart';
import 'core/utils/logger.dart';
import 'core/services/auth_service.dart';
// import 'core/services/crashlytics_service.dart';
import 'core/di/dependency_injection.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/events/presentation/pages/organizer_events_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Inicializar Firebase cuando se resuelvan conflictos de dependencias
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // TODO: Inicializar Crashlytics cuando se resuelvan conflictos
  // await CrashlyticsService.initialize();

  // TODO: Configurar Crashlytics para capturar errores de Flutter
  // FlutterError.onError = (errorDetails) {
  //   FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  // };

  // Configurar entorno
  AppConfig.setEnvironment();
  AppConfig.printConfig();

  await Hive.initFlutter();
  await DatabaseHelper.instance.database;

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  AppLogger.init();

  runApp(const TocketValidatorApp());
}

class TocketValidatorApp extends StatelessWidget {
  const TocketValidatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: DependencyInjection.repositoryProviders,
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  void _navigateToLogin() {
    Future.delayed(AppConstants.splashDuration, () async {
      // Verificar si el usuario ya está logueado
      final isLoggedIn = await AuthService.isLoggedIn();

      if (mounted) {
        Widget nextPage;
        if (isLoggedIn) {
          nextPage = const OrganizerEventsPage();
        } else {
          nextPage = const LoginPage();
        }

        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (context) => nextPage));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF6C63FF), Color(0xFF5A52E8)],
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_scanner, size: 120, color: Colors.white),
                SizedBox(height: 24),
                Text(
                  'Tocke Validator',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Validador de entradas QR',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                SizedBox(height: 48),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
