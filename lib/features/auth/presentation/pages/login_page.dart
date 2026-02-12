import 'package:flutter/material.dart';
import '../../../../core/config/debug_config.dart';
import 'package:tocke/config/app_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/google_sign_in_service.dart'; // Reactivado
import '../../../home/presentation/pages/home_page.dart';
import '../../../../core/services/crashlytics_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeEmailController = TextEditingController();
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _codeFocusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _showCodeInput = false;
  double _tabHeight = 300.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        // Usuario = 300, Código = 300
        _tabHeight = 300.0;
      });
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      // Obtener el token de Google usando el servicio
      final googleToken = await GoogleSignInService.signIn();

      if (googleToken == null) {
        // El usuario canceló o hubo un error
        _showError('Login con Google cancelado');
        return;
      }

      // Enviar el token al backend para verificación
      final result = await AuthService.loginWithGoogle(
        googleToken: googleToken,
      );

      if (mounted) {
        if (result['success'] == true) {
          _showSuccess('¡Bienvenido! Iniciando con Google...');
          final userData = await AuthService.getUserData();
          if (userData != null) {
            await CrashlyticsService.setUserInfo(
              id: userData['id']?.toString(),
              email: userData['email']?.toString(),
              name: userData['name']?.toString(),
            );
          }
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        } else {
          // Cerrar sesión de Google si el backend rechaza el token
          await GoogleSignInService.signOut();
          _showError(result['error'] ?? 'Error al iniciar sesión con Google');
        }
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _codeEmailController.dispose();
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _codeFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _handleCredentialsLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Por favor completa todos los campos');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await AuthService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (result['success'] == true) {
          _showSuccess('¡Bienvenido! Iniciando sesión...');
          final userData = await AuthService.getUserData();
          if (userData != null) {
            await CrashlyticsService.setUserInfo(
              id: userData['id']?.toString(),
              email: userData['email']?.toString(),
              name: userData['name']?.toString(),
            );
          }
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        } else {
          _showError(result['error'] ?? 'Error al iniciar sesión');
        }
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleCodeEmailSubmit() async {
    if (_codeEmailController.text.isEmpty) {
      _showError('Por favor ingresa tu correo');
      return;
    }

    // Validar formato de email
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(_codeEmailController.text)) {
      _showError('Por favor ingresa un correo válido');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Solicitar código OTP al backend
      final result = await AuthService.requestOtp(
        email: _codeEmailController.text.trim(),
      );

      if (mounted) {
        if (result['success'] == true) {
          setState(() => _showCodeInput = true);
          _showSuccess('Código enviado a tu correo');
        } else {
          _showError(result['error'] ?? 'Error al solicitar código');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCodeLogin() async {
    final code = _codeControllers.map((c) => c.text).join();
    if (code.length < 6) {
      _showError('Por favor ingresa el código completo');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await AuthService.loginWithCode(
        code: code,
        email: _codeEmailController.text.trim(),
      );

      if (mounted) {
        if (result['success'] == true) {
          _showSuccess('Código validado correctamente');
          final userData = await AuthService.getUserData();
          if (userData != null) {
            await CrashlyticsService.setUserInfo(
              id: userData['id']?.toString(),
              email: userData['email']?.toString(),
              name: userData['name']?.toString(),
            );
          }
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        } else {
          _showError(result['error'] ?? 'Código inválido');
        }
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo Section
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.jpg',
                        width: 120,
                        height: 120,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback al icono si la imagen no carga
                          return Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.qr_code_2,
                              color: Colors.white,
                              size: 50,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Bienvenido',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Inicia sesión para continuar',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Login Card
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.border.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Iniciar Sesión',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Elige tu método de acceso',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Tab List
                      Container(
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelColor: Colors.white,
                          unselectedLabelColor: AppColors.textSecondary,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          tabs: const [
                            Tab(text: 'Usuario'),
                            Tab(text: 'Código'),
                          ],
                        ),
                      ),
                      // Tab Content
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        height: _tabHeight,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Credenciales Tab
                            _buildCredentialsTab(),
                            // Código Tab
                            _buildCodeTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Terms Text
                Center(
                  child: Text(
                    'Al iniciar sesión, aceptas nuestros términos de servicio',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleTab() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleGoogleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.grey, width: 1),
              ),
              elevation: 0,
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.black87,
                        ),
                      ),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/google_logo.png',
                          width: 20,
                          height: 20,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback SVG si la imagen no carga
                            return SizedBox(
                              width: 20,
                              height: 20,
                              child: CustomPaint(painter: GoogleLogoPainter()),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Continuar con Google',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Se abrirá una ventana para autenticarte',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildCredentialsTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Label
          const Text(
            'Correo Electrónico',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          // Email Field
          TextField(
            controller: _emailController,
            enabled: !_isLoading,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'tu@email.com',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon: const Icon(
                Icons.mail_outline,
                color: AppColors.textSecondary,
                size: 20,
              ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Password Label
          const Text(
            'Contraseña',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          // Password Field
          TextField(
            controller: _passwordController,
            enabled: !_isLoading,
            obscureText: true,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon: const Icon(
                Icons.key_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Login Button
          ElevatedButton(
            onPressed: _isLoading ? null : _handleCredentialsLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: !_showCodeInput ? _buildCodeEmailForm() : _buildCodeInputForm(),
    );
  }

  Widget _buildCodeEmailForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Correo Electrónico',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _codeEmailController,
          enabled: !_isLoading,
          style: const TextStyle(color: AppColors.textPrimary),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'tu@email.com',
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            prefixIcon: const Icon(
              Icons.mail_outline,
              color: AppColors.textSecondary,
              size: 20,
            ),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.border.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.border.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleCodeEmailSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child:
              _isLoading
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Text(
                    'Continuar',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Ingresa tu correo para acceder con código único',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildCodeInputForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Código Único',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Código enviado a ${_codeEmailController.text}',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        // 6 cuadrados para el código
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) {
            return Container(
              width: 45,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: TextField(
                controller: _codeControllers[index],
                focusNode: _codeFocusNodes[index],
                enabled: !_isLoading,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    // Solo números
                    if (!RegExp(r'^[0-9]$').hasMatch(value)) {
                      _codeControllers[index].clear();
                      return;
                    }
                    // Auto-focus al siguiente
                    if (index < 5) {
                      _codeFocusNodes[index + 1].requestFocus();
                    } else {
                      // Último campo, quitar focus
                      _codeFocusNodes[index].unfocus();
                    }
                  }
                },
                onTap: () {
                  // Seleccionar todo al hacer tap
                  _codeControllers[index].selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _codeControllers[index].text.length,
                  );
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed:
                    _isLoading
                        ? null
                        : () {
                          setState(() {
                            _showCodeInput = false;
                            for (var controller in _codeControllers) {
                              controller.clear();
                            }
                          });
                        },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: AppColors.primary),
                ),
                child: const Text(
                  'Volver',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleCodeLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text(
                          'Acceder',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Custom painter para el logo de Google
class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Azul
    paint.color = const Color(0xFF4285F4);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.94, size.height * 0.51)
        ..cubicTo(
          size.width * 0.94,
          size.height * 0.47,
          size.width * 0.94,
          size.height * 0.43,
          size.width * 0.92,
          size.height * 0.40,
        )
        ..lineTo(size.width * 0.50, size.height * 0.40)
        ..lineTo(size.width * 0.50, size.height * 0.58)
        ..lineTo(size.width * 0.75, size.height * 0.58)
        ..cubicTo(
          size.width * 0.74,
          size.height * 0.64,
          size.width * 0.70,
          size.height * 0.69,
          size.width * 0.66,
          size.height * 0.72,
        )
        ..lineTo(size.width * 0.66, size.height * 0.84)
        ..cubicTo(
          size.width * 0.75,
          size.height * 0.76,
          size.width * 0.87,
          size.height * 0.64,
          size.width * 0.94,
          size.height * 0.51,
        ),
      paint,
    );

    // Verde
    paint.color = const Color(0xFF34A853);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.50, size.height * 0.96)
        ..cubicTo(
          size.width * 0.62,
          size.height * 0.96,
          size.width * 0.73,
          size.height * 0.92,
          size.width * 0.81,
          size.height * 0.85,
        )
        ..lineTo(size.width * 0.66, size.height * 0.72)
        ..cubicTo(
          size.width * 0.62,
          size.height * 0.75,
          size.width * 0.56,
          size.height * 0.77,
          size.width * 0.50,
          size.height * 0.77,
        )
        ..cubicTo(
          size.width * 0.38,
          size.height * 0.77,
          size.width * 0.28,
          size.height * 0.69,
          size.width * 0.24,
          size.height * 0.58,
        )
        ..lineTo(size.width * 0.09, size.height * 0.70)
        ..cubicTo(
          size.width * 0.17,
          size.height * 0.85,
          size.width * 0.32,
          size.height * 0.96,
          size.width * 0.50,
          size.height * 0.96,
        ),
      paint,
    );

    // Amarillo
    paint.color = const Color(0xFFFBBC05);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.24, size.height * 0.59)
        ..cubicTo(
          size.width * 0.23,
          size.height * 0.56,
          size.width * 0.23,
          size.height * 0.53,
          size.width * 0.23,
          size.height * 0.50,
        )
        ..cubicTo(
          size.width * 0.23,
          size.height * 0.47,
          size.width * 0.23,
          size.height * 0.44,
          size.width * 0.24,
          size.height * 0.41,
        )
        ..lineTo(size.width * 0.09, size.height * 0.29)
        ..cubicTo(
          size.width * 0.06,
          size.height * 0.36,
          size.width * 0.04,
          size.height * 0.43,
          size.width * 0.04,
          size.height * 0.50,
        )
        ..cubicTo(
          size.width * 0.04,
          size.height * 0.57,
          size.width * 0.06,
          size.height * 0.64,
          size.width * 0.09,
          size.height * 0.70,
        )
        ..lineTo(size.width * 0.24, size.height * 0.59),
      paint,
    );

    // Rojo
    paint.color = const Color(0xFFEA4335);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.50, size.height * 0.22)
        ..cubicTo(
          size.width * 0.57,
          size.height * 0.22,
          size.width * 0.63,
          size.height * 0.25,
          size.width * 0.68,
          size.height * 0.29,
        )
        ..lineTo(size.width * 0.81, size.height * 0.16)
        ..cubicTo(
          size.width * 0.73,
          size.height * 0.09,
          size.width * 0.62,
          size.height * 0.04,
          size.width * 0.50,
          size.height * 0.04,
        )
        ..cubicTo(
          size.width * 0.32,
          size.height * 0.04,
          size.width * 0.17,
          size.height * 0.15,
          size.width * 0.09,
          size.height * 0.29,
        )
        ..lineTo(size.width * 0.24, size.height * 0.41)
        ..cubicTo(
          size.width * 0.28,
          size.height * 0.30,
          size.width * 0.38,
          size.height * 0.22,
          size.width * 0.50,
          size.height * 0.22,
        ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
