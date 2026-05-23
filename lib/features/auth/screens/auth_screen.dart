import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../dashboard/main_scaffold.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/solid_surface.dart';
import '../widgets/auth_background.dart';
import '../widgets/flip_card.dart';
import '../../../shared/widgets/custom_notification.dart';
import '../../../l10n/app_localizations.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();
  final _usernameController = TextEditingController();
  
  bool _isLogin = true;
  bool _isLoading = false;
  bool _isAnimating = false;
  late AnimationController _waveController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _otpError;

  bool _showOtpVerification = false;
  String _registeredEmail = '';
  int _resendCountdown = 0;
  Timer? _countdownTimer;

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
    _otpController.dispose();
    _usernameController.dispose();
    _waveController.dispose();
    _countdownTimer?.cancel();
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
      _usernameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });
  }

  bool _validateFields() {
    _resetErrors();
    bool isValid = true;
    final l10n = AppLocalizations.of(context)!;

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Username Validation (Register only)
    if (!_isLogin) {
      if (username.isEmpty) {
        setState(() => _usernameError = l10n.authUsernameRequired);
        isValid = false;
      } else if (username.length < 3) {
        setState(() => _usernameError = l10n.authUsernameTooShort);
        isValid = false;
      } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
        setState(() => _usernameError = l10n.authUsernameInvalid);
        isValid = false;
      }
    }

    // Email Validation
    if (email.isEmpty) {
      setState(() => _emailError = l10n.authEmailRequired);
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => _emailError = l10n.authEmailInvalid);
      isValid = false;
    }

    // Password Validation
    if (password.isEmpty) {
      setState(() => _passwordError = l10n.authPasswordRequired);
      isValid = false;
    } else if (password.length < 6) {
      setState(() => _passwordError = l10n.authPasswordTooShort);
      isValid = false;
    }

    // Confirm Password Validation (Register only)
    if (!_isLogin) {
      if (confirmPassword.isEmpty) {
        setState(() => _confirmPasswordError = l10n.authConfirmPasswordRequired);
        isValid = false;
      } else if (password != confirmPassword) {
        setState(() => _confirmPasswordError = l10n.authPasswordsDoNotMatch);
        isValid = false;
      }
    }

    return isValid;
  }

  void _startCountdown() {
    setState(() => _resendCountdown = 60);
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCountdown == 0) {
        timer.cancel();
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  Future<void> _submit() async {
    if (!_validateFields()) return;
    final l10n = AppLocalizations.of(context)!;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final username = _usernameController.text.trim();

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      if (_isLogin) {
        await authService.signIn(email: email, password: password);
      } else {
        // Kullanıcı adının benzersiz olup olmadığını kontrol et
        final isTaken = await authService.isUsernameTaken(username);
        if (isTaken) {
          if (mounted) {
            setState(() {
              _usernameError = l10n.authUsernameTaken;
              _isLoading = false;
            });
          }
          return;
        }

        await authService.signUp(
          email: email,
          password: password,
          username: username,
        );
        if (mounted) {
          setState(() {
            _registeredEmail = email;
            _showOtpVerification = true;
            _otpError = null;
            _otpController.clear();
          });
          _showSnackBar(l10n.authRegistrationSuccess);
          _startCountdown();
        }
      }
    } catch (e) {
      if (mounted) _showSnackBar(_getFriendlyErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitOtp() async {
    final l10n = AppLocalizations.of(context)!;
    final code = _otpController.text.trim();
    if (code.isEmpty || (code.length != 6 && code.length != 8)) {
      setState(() => _otpError = l10n.authOtpRequired);
      return;
    }

    setState(() {
      _otpError = null;
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.verifyOTP(email: _registeredEmail, token: code);
    } catch (e) {
      if (mounted) {
        setState(() => _otpError = _getFriendlyErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_resendCountdown > 0) return;
    final l10n = AppLocalizations.of(context)!;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.resendSignUpOTP(email: _registeredEmail);
      if (mounted) {
        _showSnackBar(l10n.authOtpSent);
        _startCountdown();
      }
    } catch (e) {
      if (mounted) _showSnackBar(_getFriendlyErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getFriendlyErrorMessage(Object error) {
    final l10n = AppLocalizations.of(context)!;
    if (error is AuthException) {
      final message = error.message.toLowerCase();
      if (error.code == 'signup_disabled' ||
          message.contains('signup is disabled') ||
          message.contains('signups are disabled') ||
          message.contains('signup_disabled')) {
        return l10n.authSignupDisabled;
      }
      if (error.code == 'rate_limit_exceeded' ||
          message.contains('rate limit') ||
          message.contains('too many requests')) {
        return l10n.authRateLimitExceeded;
      }
      switch (error.code) {
        case 'email_not_confirmed':
          return l10n.authEmailNotConfirmed;
        case 'invalid_credentials':
          return l10n.authInvalidCredentials;
        case 'email_exists':
        case 'user_already_exists':
          return l10n.authEmailExists;
        case 'weak_password':
          return l10n.authWeakPassword;
        case 'otp_expired':
          return l10n.authOtpExpired;
        case 'bad_code':
        case 'invalid_grant':
          return l10n.authBadCode;
        default:
          return error.message;
      }
    }
    return '${l10n.error}: ${error.toString()}';
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
    } catch (e) {
      if (mounted) _showSnackBar('Google Giriş Hatası: ${_getFriendlyErrorMessage(e)}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    CustomNotification.info(context, message);
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

    return AuthBackground(
      showPattern: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(), // Stretch efektini engeller, BackdropFilter'ın bozulmasını önler
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        SizedBox(height: topSpacer),
                        _buildHero(context, primaryColor, screenHeight),
                        SizedBox(height: heroToCardSpacer),
  
                        SolidSurface(
                          padding: const EdgeInsets.all(24),
                          child: RepaintBoundary(
                            child: AnimatedSize(
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.easeInOutSine,
                              alignment: Alignment.topCenter,
                              child: _showOtpVerification
                                  ? _buildOtpForm(context, screenHeight)
                                  : FlipCard(
                                      isFront: _isLogin,
                                      front: _buildLoginForm(context, screenHeight),
                                      back: _buildRegisterForm(context, screenHeight),
                                    ),
                            ),
                          ),
                        ),
  
                        if (!_showOtpVerification) ...[
                          SizedBox(height: cardToBottomSpacer),
                          _buildBottomActions(context, primaryColor),
                        ],
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

  Widget _buildOtpForm(BuildContext context, double screenHeight) {
    return Column(
      key: const ValueKey('otp_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Doğrulama Kodu',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.getPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$_registeredEmail adresine bir doğrulama kodu gönderdik. Lütfen kodu girin.',
          style: TextStyle(
            color: AppColors.getTextSecondary(context).withValues(alpha: 0.7),
            fontSize: (screenHeight * 0.016).clamp(11.0, 14.0),
          ),
        ),
        SizedBox(height: screenHeight * 0.035),
        CustomTextField(
          controller: _otpController,
          hintText: 'Doğrulama Kodu',
          icon: Icons.security_rounded,
          errorText: _otpError,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(8),
          ],
        ),
        Column(
          children: [
            CustomButton(
              label: 'Kodu Doğrula',
              onTap: _submitOtp,
              activeColor: AppColors.getPrimary(context),
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: (_resendCountdown > 0 || _isLoading) ? null : _resendOtp,
                  child: Text(
                    _resendCountdown > 0
                        ? 'Kodu Tekrar Gönder ($_resendCountdown sn)'
                        : 'Kodu Tekrar Gönder',
                    style: TextStyle(
                      color: (_resendCountdown > 0 || _isLoading)
                          ? AppColors.getTextSecondary(context).withValues(alpha: 0.5)
                          : AppColors.getPrimary(context),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      setState(() {
                        _showOtpVerification = false;
                        _isLogin = true;
                        _otpError = null;
                        _otpController.clear();
                      });
                    },
              child: Text(
                'Geri Dön',
                style: TextStyle(
                  color: _isLoading
                      ? AppColors.getTextSecondary(context).withValues(alpha: 0.3)
                      : AppColors.getTextSecondary(context).withValues(alpha: 0.7),
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
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
        CustomTextField(
          controller: _emailController,
          hintText: 'E-posta',
          icon: Icons.email_rounded,
          errorText: _emailError,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: screenHeight * 0.02),
        CustomTextField(
          controller: _passwordController,
          hintText: 'Şifre',
          icon: Icons.lock_rounded,
          obscureText: _obscurePassword,
          errorText: _passwordError,
          suffix: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 20,
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
        CustomButton(
          label: 'Giriş Yap',
          onTap: _submit,
          isLoading: _isLoading,
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
        CustomTextField(
          controller: _usernameController,
          hintText: 'Kullanıcı Adı',
          icon: Icons.person_rounded,
          errorText: _usernameError,
        ),
        SizedBox(height: screenHeight * 0.02),
        CustomTextField(
          controller: _emailController,
          hintText: 'E-posta',
          icon: Icons.email_rounded,
          errorText: _emailError,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: screenHeight * 0.02),
        CustomTextField(
          controller: _passwordController,
          hintText: 'Şifre',
          icon: Icons.lock_rounded,
          obscureText: _obscurePassword,
          errorText: _passwordError,
          suffix: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 20,
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: AppColors.getPrimary(context).withValues(alpha: 0.5),
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        CustomTextField(
          controller: _confirmPasswordController,
          hintText: 'Şifre Tekrar',
          icon: Icons.security_rounded,
          obscureText: _obscureConfirmPassword,
          errorText: _confirmPasswordError,
          suffix: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 20,
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: AppColors.getSecondary(context).withValues(alpha: 0.5),
              size: 20,
            ),
            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          ),
        ),
        SizedBox(height: screenHeight * 0.035),
        CustomButton(
          label: 'Hemen Katıl',
          onTap: _submit,
          activeColor: AppColors.getSecondary(context),
          isLoading: _isLoading,
        ),
        SizedBox(height: screenHeight * 0.035),
        _buildSocialLogin(context, screenHeight),
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
        CustomButton(
          label: 'Google ile Devam Et',
          onTap: _signInWithGoogle,
          isPrimary: false,
          activeColor: AppColors.getTextPrimary(context).withValues(alpha: 0.75),
          leading: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 3,
                  offset: const Offset(0, 1.5),
                ),
              ],
            ),
            child: const Text(
              'G',
              style: TextStyle(
                color: Color(0xFF4285F4),
                fontWeight: FontWeight.w900,
                fontSize: 13,
                fontFamily: 'Roboto',
              ),
            ),
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
