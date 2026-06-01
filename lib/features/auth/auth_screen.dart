import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/main_scaffold.dart';
import '../../../core/utils/route_transitions.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/solid_surface.dart';
import 'widgets/auth_background.dart';
import 'widgets/flip_card.dart';
import '../../../shared/widgets/custom_notification.dart';
import '../../../l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/subscription_service.dart';
import '../../../core/providers/settings_provider.dart';

import 'widgets/login_form.dart';
import 'widgets/register_form.dart';
import 'widgets/otp_form.dart';
import 'widgets/forgot_password_form.dart';
import 'widgets/bottom_actions.dart';
import 'utils/auth_error_helper.dart';
import 'utils/auth_validator.dart';

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
  bool _isGoogleLoading = false;
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
  bool _isFlippingBack = false;
  String _registeredEmail = '';
  int _resendCountdown = 0;
  Timer? _countdownTimer;
  final FocusNode _otpFocusNode = FocusNode();
  bool _showForgotPassword = false;
  int _forgotPasswordStep = 1; // 1: Email, 2: OTP, 3: New Password

  @override
  void initState() {
    super.initState();
    _otpFocusNode.addListener(() {
      if (_otpFocusNode.hasFocus) {
        _otpController.selection = TextSelection.fromPosition(
          TextPosition(offset: _otpController.text.length),
        );
      }
      if (mounted) setState(() {});
    });
    _otpController.addListener(() {
      if (mounted) {
        final textLength = _otpController.text.length;
        if (_otpController.selection.baseOffset != textLength) {
          _otpController.selection = TextSelection.fromPosition(
            TextPosition(offset: textLength),
          );
        }
        setState(() {});
      }
    });
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
    _otpFocusNode.dispose();
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
        _resetErrors();
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
      _otpError = null;
    });
  }

  bool _validateFields() {
    _resetErrors();
    bool isValid = true;

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (!_isLogin) {
      final usernameErr = AuthValidator.validateUsername(context, username);
      if (usernameErr != null) {
        setState(() => _usernameError = usernameErr);
        isValid = false;
      }
    }

    final emailErr = AuthValidator.validateEmail(context, email);
    if (emailErr != null) {
      setState(() => _emailError = emailErr);
      isValid = false;
    }

    final passwordErr = AuthValidator.validatePassword(context, password);
    if (passwordErr != null) {
      setState(() => _passwordError = passwordErr);
      isValid = false;
    }

    if (!_isLogin) {
      final confirmPasswordErr = AuthValidator.validateConfirmPassword(context, password, confirmPassword);
      if (confirmPasswordErr != null) {
        setState(() => _confirmPasswordError = confirmPasswordErr);
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
    if (_isLoading || _isGoogleLoading) return;
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
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            FadeScalePageRoute(child: const MainScaffold()),
            (route) => false,
          );
        }
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
          CustomNotification.success(context, l10n.authRegistrationSuccess);
          _startCountdown();
        }
      }
    } catch (e) {
      if (mounted) CustomNotification.error(context, AuthErrorHelper.getFriendlyErrorMessage(context, e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendRecoveryCode() async {
    if (_isLoading || _isGoogleLoading) return;
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = l10n.authEmailRequired);
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => _emailError = l10n.authEmailInvalid);
      return;
    }

    setState(() {
      _isLoading = true;
      _emailError = null;
    });

    try {
      await ref.read(authServiceProvider).resetPassword(email);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _forgotPasswordStep = 2;
          _otpController.clear();
          _otpError = null;
        });
        _startCountdown();
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _otpFocusNode.requestFocus();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _emailError = AuthErrorHelper.getFriendlyErrorMessage(context, e);
        });
      }
    }
  }

  Future<void> _resendRecoveryCode() async {
    if (_resendCountdown > 0 || _isLoading || _isGoogleLoading) return;
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();

    setState(() {
      _isLoading = true;
      _otpError = null;
      _otpController.clear();
    });

    try {
      await ref.read(authServiceProvider).resetPassword(email);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _startCountdown();
        CustomNotification.success(context, l10n.authOtpSent);
        _otpFocusNode.requestFocus();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _otpError = AuthErrorHelper.getFriendlyErrorMessage(context, e);
        });
      }
    }
  }

  Future<void> _verifyRecoveryCode() async {
    if (_isLoading || _isGoogleLoading) return;
    final l10n = AppLocalizations.of(context)!;
    final code = _otpController.text.trim();
    if (code.isEmpty || code.length != 6) {
      setState(() => _otpError = l10n.authOtpRequired);
      return;
    }

    setState(() {
      _isLoading = true;
      _otpError = null;
    });

    try {
      final email = _emailController.text.trim();
      await ref.read(authServiceProvider).verifyRecoveryOTP(email: email, token: code);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _forgotPasswordStep = 3;
          _passwordController.clear();
          _confirmPasswordController.clear();
          _passwordError = null;
          _confirmPasswordError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _otpError = AuthErrorHelper.getFriendlyErrorMessage(context, e);
        });
      }
    }
  }

  Future<void> _submitNewPassword() async {
    if (_isLoading || _isGoogleLoading) return;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _passwordError = null;
      _confirmPasswordError = null;
    });

    bool isValid = true;
    final passwordErr = AuthValidator.validatePassword(context, password);
    if (passwordErr != null) {
      setState(() => _passwordError = passwordErr);
      isValid = false;
    }

    final confirmPasswordErr = AuthValidator.validateConfirmPassword(context, password, confirmPassword);
    if (confirmPasswordErr != null) {
      setState(() => _confirmPasswordError = confirmPasswordErr);
      isValid = false;
    }

    if (!isValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authServiceProvider).updatePassword(password);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        CustomNotification.success(context, l10n.authPasswordResetSuccess);
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          FadeScalePageRoute(child: const MainScaffold()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _passwordError = AuthErrorHelper.getFriendlyErrorMessage(context, e);
        });
      }
    }
  }

  Future<void> _submitOtp() async {
    if (_isLoading || _isGoogleLoading) return;
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
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          FadeScalePageRoute(child: const MainScaffold()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _otpError = AuthErrorHelper.getFriendlyErrorMessage(context, e));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_resendCountdown > 0 || _isLoading || _isGoogleLoading) return;
    final l10n = AppLocalizations.of(context)!;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.resendSignUpOTP(email: _registeredEmail);
      if (mounted) {
        CustomNotification.success(context, l10n.authOtpSent);
        _startCountdown();
      }
    } catch (e) {
      if (mounted) CustomNotification.error(context, AuthErrorHelper.getFriendlyErrorMessage(context, e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isLoading || _isGoogleLoading) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isGoogleLoading = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
    } catch (e) {
      if (mounted) CustomNotification.error(context, '${l10n.authGoogleError}: ${AuthErrorHelper.getFriendlyErrorMessage(context, e)}');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
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
                        child: FlipCard(
                          isFront: _showOtpVerification
                              ? !_isFlippingBack
                              : _showForgotPassword
                                  ? _isFlippingBack
                                  : _isLogin,
                          front: _showOtpVerification 
                              ? OtpForm(
                                  otpController: _otpController,
                                  otpFocusNode: _otpFocusNode,
                                  otpError: _otpError,
                                  isLoading: _isLoading,
                                  resendCountdown: _resendCountdown,
                                  onVerify: _submitOtp,
                                  onResend: _resendOtp,
                                  registeredEmail: _registeredEmail,
                                )
                              : LoginForm(
                                  emailController: _emailController,
                                  passwordController: _passwordController,
                                  emailError: _emailError,
                                  passwordError: _passwordError,
                                  obscurePassword: _obscurePassword,
                                  onObscurePasswordToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                                  onForgotPasswordPressed: () {
                                    setState(() {
                                      _showForgotPassword = true;
                                      _forgotPasswordStep = 1;
                                      _resetErrors();
                                    });
                                  },
                                  onSubmit: _submit,
                                  isLoading: _isLoading,
                                  isGoogleLoading: _isGoogleLoading,
                                  onGoogleSignIn: _signInWithGoogle,
                                ),
                          back: _showForgotPassword
                              ? ForgotPasswordForm(
                                  emailController: _emailController,
                                  otpController: _otpController,
                                  passwordController: _passwordController,
                                  confirmPasswordController: _confirmPasswordController,
                                  emailError: _emailError,
                                  otpError: _otpError,
                                  passwordError: _passwordError,
                                  confirmPasswordError: _confirmPasswordError,
                                  obscurePassword: _obscurePassword,
                                  obscureConfirmPassword: _obscureConfirmPassword,
                                  onObscurePasswordToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                                  onObscureConfirmPasswordToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                  isLoading: _isLoading,
                                  resendCountdown: _resendCountdown,
                                  forgotPasswordStep: _forgotPasswordStep,
                                  onSendCode: _sendRecoveryCode,
                                  onVerifyCode: _verifyRecoveryCode,
                                  onSubmitNewPassword: _submitNewPassword,
                                  onChangeEmail: () {
                                    setState(() {
                                      _forgotPasswordStep = 1;
                                      _otpController.clear();
                                      _resetErrors();
                                    });
                                  },
                                  onResendCode: _resendRecoveryCode,
                                  otpFocusNode: _otpFocusNode,
                                )
                              : RegisterForm(
                                  usernameController: _usernameController,
                                  emailController: _emailController,
                                  passwordController: _passwordController,
                                  confirmPasswordController: _confirmPasswordController,
                                  usernameError: _usernameError,
                                  emailError: _emailError,
                                  passwordError: _passwordError,
                                  confirmPasswordError: _confirmPasswordError,
                                  obscurePassword: _obscurePassword,
                                  obscureConfirmPassword: _obscureConfirmPassword,
                                  onObscurePasswordToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                                  onObscureConfirmPasswordToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                  onSubmit: _submit,
                                  isLoading: _isLoading,
                                  isGoogleLoading: _isGoogleLoading,
                                  onGoogleSignIn: _signInWithGoogle,
                                ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: cardToBottomSpacer),
                  BottomActions(
                    isLogin: _isLogin,
                    showCancel: (_showOtpVerification || _showForgotPassword) && !_isFlippingBack,
                    isOtpVerification: _showOtpVerification,
                    isLoading: _isLoading || _isGoogleLoading,
                    onToggleAuthMode: _toggleAuthMode,
                    onContinueAsGuest: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('Finarcast_is_pro_user', false);
                      await prefs.setBool('Finarcast_is_guest_mode', true);
                      try {
                        await ref.read(subscriptionServiceProvider).setProStatus(false);
                      } catch (_) {}
                      ref.read(guestModeProvider.notifier).state = true;
                      ref.invalidate(settingsProvider);
                    },
                    onCancel: () {
                      setState(() {
                        _isFlippingBack = true;
                        _resetErrors();
                      });
                      
                      Future.delayed(const Duration(milliseconds: 1000), () {
                        if (mounted) {
                          setState(() {
                            if (_showOtpVerification) {
                              _showOtpVerification = false;
                              _isLogin = false; // Stay on register
                              _otpController.clear();
                            } else {
                              _showForgotPassword = false;
                              _forgotPasswordStep = 1;
                              _isLogin = true;
                            }
                            _isFlippingBack = false;
                          });
                        }
                      });
                    },
                  ),
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
}
