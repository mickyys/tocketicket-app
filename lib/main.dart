import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:firebase_core/firebase_core.dart';  // Temporalmente comentado
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';  // Temporalmente comentado
// import 'firebase_options.dart';  // Temporalmente comentado
import 'config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/app_colors.dart';
import 'core/storage/database_helper.dart';
import 'core/utils/logger.dart';
import 'core/services/auth_service.dart';
import 'core/services/google_sign_in_service.dart'; // Reactivado
import 'core/services/crashlytics_service.dart'; // Reactivado con implementación stub
import 'core/di/dependency_injection.dart';
import 'features/events/domain/usecases/get_attendee_status_summary.dart';
import 'features/events/domain/usecases/get_events.dart';
import 'features/events/domain/usecases/get_event_participants_detailed.dart';
import 'features/events/domain/usecases/search_participants.dart';
import 'features/events/domain/usecases/change_participant.dart';
import 'features/events/presentation/bloc/event_bloc.dart';
import 'features/events/presentation/bloc/participant_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'core/utils/global_keys.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase - Temporalmente comentado
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializar Crashlytics - Temporalmente comentado
  await CrashlyticsService.initialize();

  // Inicializar Google Sign-In con credenciales reales
  final googleClientId = const String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue:
        '1054622389903-o3rr07gqdm9k395e3roc33buqs033v9f.apps.googleusercontent.com',
  );

  GoogleSignInService.configure(
    scopes: ['email', 'profile'],
    clientId: googleClientId,
  );

  // Configurar Crashlytics para capturar errores de Flutter - Temporalmente comentado
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
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0a0a0a),
      systemNavigationBarIconBrightness: Brightness.light,
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
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create:
                (context) => EventBloc(
                  getEvents: context.read<GetEvents>(),
                  getAttendeeStatusSummary:
                      context.read<GetAttendeeStatusSummary>(),
                )..add(FetchEvents()),
          ),
          BlocProvider(
            create:
                (context) => ParticipantBloc(
                  getEventParticipantsDetailed:
                      context.read<GetEventParticipantsDetailed>(),
                  searchParticipants: context.read<SearchParticipants>(),
                  changeParticipant: context.read<ChangeParticipant>(),
                ),
          ),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es', 'ES'),
            Locale('en', 'US'),
          ],
          locale: const Locale('es', 'ES'),
          home: const SplashScreen(),
        ),
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
          nextPage = const HomePage();
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
                colors: [Color(0xFF0a0a0a), Color(0xFF1a1a1a)],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/images/logo.jpg',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Tocke Validador',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Validador de entradas QR',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 48),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
