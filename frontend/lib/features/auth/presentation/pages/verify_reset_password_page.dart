import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/figma_auth_widgets.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../providers/auth_provider.dart';

class VerifyResetPasswordPage extends ConsumerStatefulWidget {
  final String email;

  const VerifyResetPasswordPage({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<VerifyResetPasswordPage> createState() => _VerifyResetPasswordPageState();
}

class _VerifyResetPasswordPageState extends ConsumerState<VerifyResetPasswordPage> {
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isResending = false;

  String? _otpError;
  String? _passwordError;
  String? _confirmPasswordError;

  int _resendCooldown = 60;
  Timer? _cooldownTimer;

  bool get _hasMinLength => _passwordController.text.length >= 8 && _passwordController.text.length <= 64;
  bool get _hasLetter => RegExp(r'[a-zA-Z]').hasMatch(_passwordController.text);
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_passwordController.text);
  bool get _isPasswordComplex => _hasMinLength && _hasLetter && _hasNumber;

  @override
  void initState() {
    super.initState();
    _startCooldownTimer();
  }

  void _startCooldownTimer() {
    setState(() => _resendCooldown = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleResendOtp() async {
    if (_resendCooldown > 0 || _isResending) return;

    setState(() => _isResending = true);
    try {
      await ref.read(authRepositoryProvider).requestPasswordReset(widget.email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A new verification code has been sent to your email.'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      _startCooldownTimer();
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _handleResetPassword() async {
    final otp = _otpController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    String? oError;
    String? pError;
    String? cError;

    if (otp.isEmpty) {
      oError = 'Verification code is required';
    } else if (otp.length != 6) {
      oError = 'Verification code must be 6 digits';
    }

    if (password.isEmpty) {
      pError = 'New password is required';
    } else if (!_isPasswordComplex) {
      pError = 'Password does not meet complexity requirements';
    }

    if (confirmPassword.isEmpty) {
      cError = 'Please confirm your new password';
    } else if (password != confirmPassword) {
      cError = 'Passwords do not match';
    }

    if (oError != null || pError != null || cError != null) {
      setState(() {
        _otpError = oError;
        _passwordError = pError;
        _confirmPasswordError = cError;
      });
      return;
    }

    setState(() {
      _otpError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _isLoading = true;
    });

    try {
      await ref.read(authRepositoryProvider).resetPassword(
            email: widget.email,
            otp: otp,
            newPassword: password,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully! Please sign in with your new password.'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );

      context.go('/sign-in');
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      if (msg.toLowerCase().contains('code') || msg.toLowerCase().contains('otp')) {
        setState(() => _otpError = msg);
      } else {
        setState(() => _passwordError = msg);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildRequirementItem({
    required bool isMet,
    required String label,
    required ColorScheme colorScheme,
  }) {
    const activeColor = Color(0xFF2E7D32); // Green
    final inactiveColor = colorScheme.outline;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isMet ? activeColor : inactiveColor,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? activeColor : inactiveColor,
              fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar
              Row(
                children: [
                  const FigmaBackButton(),
                  const SizedBox(width: 16),
                  Text(
                    'Reset Password',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Subtitle
              Text(
                'Enter the 6-digit code sent to:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.email,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              // OTP field
              AppTextField(
                controller: _otpController,
                labelText: '6-digit Verification Code',
                hintText: '123456',
                keyboardType: TextInputType.number,
                errorText: _otpError,
                onChanged: (_) {
                  if (_otpError != null) setState(() => _otpError = null);
                },
              ),
              const SizedBox(height: 18),
              // New Password
              AppTextField(
                controller: _passwordController,
                labelText: 'New Password',
                hintText: '',
                errorText: _passwordError,
                onChanged: (_) {
                  setState(() {
                    if (_passwordError != null) _passwordError = null;
                  });
                },
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 8),
              // Password Checklist
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRequirementItem(
                      isMet: _hasMinLength,
                      label: 'At least 8 characters (8–64 characters)',
                      colorScheme: colorScheme,
                    ),
                    _buildRequirementItem(
                      isMet: _hasLetter,
                      label: 'At least 1 letter (a-z, A-Z)',
                      colorScheme: colorScheme,
                    ),
                    _buildRequirementItem(
                      isMet: _hasNumber,
                      label: 'At least 1 number (0-9)',
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Confirm Password
              AppTextField(
                controller: _confirmPasswordController,
                labelText: 'Confirm New Password',
                hintText: '',
                errorText: _confirmPasswordError,
                onChanged: (_) {
                  if (_confirmPasswordError != null) setState(() => _confirmPasswordError = null);
                },
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
              const SizedBox(height: 32),
              // Reset Password Button
              PrimaryButton(
                label: 'Reset Password',
                isLoading: _isLoading,
                onPressed: _handleResetPassword,
              ),
              const SizedBox(height: 16),
              // Resend Code
              Center(
                child: TextButton(
                  onPressed: _resendCooldown == 0 && !_isResending ? _handleResendOtp : null,
                  child: Text(
                    _resendCooldown > 0
                        ? 'Resend code in ${_resendCooldown}s'
                        : 'Didn’t receive code? Resend Code',
                    style: TextStyle(
                      color: _resendCooldown > 0
                          ? colorScheme.outline
                          : colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
