import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/main_scaffold.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/precision_button.dart';
import '../../../shared/widgets/precision_input.dart';
import '../../../shared/widgets/precision_glass_card.dart';
import '../widgets/precision_background.dart';
import '../widgets/precision_flip_card.dart';
import '../../../shared/widgets/precision_notification.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLogin = true;
  bool _isLoading = false;
  bool _isAnimating = false;
  late AnimationController _waveController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() async {
    if (_isAnimating) return;
    
    _waveController.forward(from: 0);
    
    if (mounted) {
      setState(() {
        _isAnimating = true;
        _isLogin = !_isLogin;
        _emailError = null;
        _passwordError = null;
        _confirmPasswordError = null;
      });
    }

    // Wait for the animation to complete (1000ms)
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() => _isAnimating = false);
    }
  }

  void _resetErrors() {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });
  }

  bool _validateFields() {
    _resetErrors();
    bool isValid = true;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Email Validation
    if (email.isEmpty) {
      setState(() => _emailError = 'E-posta alanı boş bırakılamaz');
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => _emailError = 'Geçerli bir e-posta adresi girin');
      isValid = false;
    }

    // Password Validation
    if (password.isEmpty) {
      setState(() => _passwordError = 'Şifre alanı boş bırakılamaz');
      isValid = false;
    } else if (password.length < 6) {
      setState(() => _passwordError = 'Şifre en az 6 karakter olmalıdır');
      isValid = false;
    }

    // Confirm Password Validation (Register only)
    if (!_isLogin) {
      if (confirmPassword.isEmpty) {
        setState(() => _confirmPasswordError = 'Şifre tekrarı yapın');
        isValid = false;
      } else if (password != confirmPassword) {
        setState(() => _confirmPasswordError = 'Şifreler eşleşmiyor');
        isValid = false;
      }
    }

    return isValid;
  }

  Future<void> _submit() async {
    if (!_validateFields()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      if (_isLogin) {
        await authService.signIn(email: email, password: password);
      } else {
        await authService.signUp(email: email, password: password);
        if (mounted) {
          _showSnackBar('Kayıt başarılı! Lütfen giriş yapın.');
          _toggleAuthMode();
        }
      }
    } catch (e) {
      if (mounted) _showSnackBar('Hata: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
    } catch (e) {
      if (mounted) _showSnackBar('Google Giriş Hatası: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    PrecisionNotification.info(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.getPrimary(context);
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    
    // Dynamically adjust spacings based on screen height
    final double topSpacer = screenHeight * 0.03;
    final double heroToCardSpacer = screenHeight * 0.05;
    final double cardToBottomSpacer = screenHeight * 0.04;

    return PrecisionBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        SizedBox(height: topSpacer),
                        _buildHero(context, primaryColor, screenHeight),
                        SizedBox(height: heroToCardSpacer),
  
                        PrecisionGlassCard(
                          padding: const EdgeInsets.all(24),
                          isGlass: true,
                          child: RepaintBoundary(
                            child: AnimatedSize(
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.easeInOutSine,
                              alignment: Alignment.topCenter,
                              child: PrecisionFlipCard(
                                isFront: _isLogin,
                                front: _buildLoginForm(context, screenHeight),
                                back: _buildRegisterForm(context, screenHeight),
                              ),
                            ),
                          ),
                        ),
  
                        SizedBox(height: cardToBottomSpacer),
                        _buildBottomActions(context, primaryColor),
                        const SizedBox(height: 20), // Extra space for scrolling
                    ],
                  ),
                ),
            ),
          ),
        ),
      );
  }

  Widget _buildHero(BuildContext context, Color primaryColor, double screenHeight) {
    final double fontSize = (screenHeight * 0.06).clamp(32.0, 56.0);
    
    return Column(
      children: [
        Text(
          'Finarcast',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: AppColors.getTextPrimary(context),
            letterSpacing: -3,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: fontSize * 0.8,
          height: 4,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context, double screenHeight) {
    return Column(
      key: const ValueKey('login_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hoş Geldiniz',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Hesabınıza giriş yaparak finanslarınıza hükmedin.',
          style: TextStyle(
            color: AppColors.getTextSecondary(context).withValues(alpha: 0.7), 
            fontSize: (screenHeight * 0.016).clamp(11.0, 14.0),
          ),
        ),
        SizedBox(height: screenHeight * 0.035),
        PrecisionInput(
          controller: _emailController,
          hintText: 'E-posta',
          icon: Icons.email_rounded,
          errorText: _emailError,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: screenHeight * 0.02),
        PrecisionInput(
          controller: _passwordController,
          hintText: 'Şifre',
          icon: Icons.lock_rounded,
          obscureText: _obscurePassword,
          errorText: _passwordError,
          suffix: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: AppColors.getPrimary(context).withValues(alpha: 0.5),
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              _showSnackBar('Şifre sıfırlama servisi yakında aktif edilecek.');
            },
            child: Text(
              'Şifremi Unuttum',
              style: TextStyle(
                color: AppColors.getPrimary(context).withValues(alpha: 0.8), 
                fontSize: (screenHeight * 0.015).clamp(10.0, 13.0),
              ),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.015),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : PrecisionButton(
                label: 'Giriş Yap',
                onTap: _submit,
              ),
        SizedBox(height: screenHeight * 0.035),
        _buildSocialLogin(context, screenHeight),
      ],
    );
  }

  Widget _buildRegisterForm(BuildContext context, double screenHeight) {
    return Column(
      key: const ValueKey('register_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yeni Hesap',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.getPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Finarcast dünyasına katılarak limitlerinizi belirleyin.',
          style: TextStyle(
            color: AppColors.getTextSecondary(context).withValues(alpha: 0.7), 
            fontSize: (screenHeight * 0.016).clamp(11.0, 14.0),
          ),
        ),
        SizedBox(height: screenHeight * 0.035),
        PrecisionInput(
          controller: _emailController,
          hintText: 'E-posta',
          icon: Icons.email_rounded,
          errorText: _emailError,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: screenHeight * 0.02),
        PrecisionInput(
          controller: _passwordController,
          hintText: 'Şifre',
          icon: Icons.lock_rounded,
          obscureText: _obscurePassword,
          errorText: _passwordError,
          suffix: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: AppColors.getPrimary(context).withValues(alpha: 0.5),
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        PrecisionInput(
          controller: _confirmPasswordController,
          hintText: 'Şifre Tekrar',
          icon: Icons.security_rounded,
          obscureText: _obscureConfirmPassword,
          errorText: _confirmPasswordError,
          suffix: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: AppColors.secondary.withValues(alpha: 0.5),
              size: 20,
            ),
            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          ),
        ),
        SizedBox(height: screenHeight * 0.035),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : PrecisionButton(
                label: 'Hemen Katıl',
                onTap: _submit,
                activeColor: AppColors.secondary,
              ),
      ],
    );
  }

  Widget _buildSocialLogin(BuildContext context, double screenHeight) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.getTextSecondary(context).withValues(alpha: 0.1))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Veya', 
                style: TextStyle(
                  color: AppColors.getTextSecondary(context).withValues(alpha: 0.4), 
                  fontSize: (screenHeight * 0.015).clamp(10.0, 12.0),
                ),
              ),
            ),
            Expanded(child: Divider(color: AppColors.getTextSecondary(context).withValues(alpha: 0.1))),
          ],
        ),
        SizedBox(height: screenHeight * 0.025),
        PrecisionButton(
          label: 'Google ile Devam Et',
          onTap: _signInWithGoogle,
          isPrimary: false,
          activeColor: AppColors.getTextPrimary(context).withValues(alpha: 0.6),
          leading: Icon(
            Icons.g_mobiledata, 
            size: (screenHeight * 0.045).clamp(24.0, 42.0), 
            color: AppColors.getTextPrimary(context)
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context, Color primaryColor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isLogin ? 'Hesabınız yok mu?' : 'Zaten hesabınız var mı?',
              style: TextStyle(color: AppColors.getTextSecondary(context)),
            ),
            TextButton(
              onPressed: _toggleAuthMode,
              child: Text(
                _isLogin ? 'Kayıt Ol' : 'Giriş Yap',
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainScaffold()),
            );
          },
          child: Text(
            'Misafir Olarak Devam Et',
            style: TextStyle(
              color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
              fontSize: 12,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
