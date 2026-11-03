import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/figma_auth_widgets.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../providers/auth_provider.dart';

class SetNewPasswordPage extends ConsumerStatefulWidget {
  final String email;
  final String otp;

  const SetNewPasswordPage({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  ConsumerState<SetNewPasswordPage> createState() => _SetNewPasswordPageState();
}

class _SetNewPasswordPageState extends ConsumerState<SetNewPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  String? _passwordError;
  String? _confirmPasswordError;

  bool get _hasMinLength => _passwordController.text.length >= 8 && _passwordController.text.length <= 64;
  bool get _hasLetter => RegExp(r'[a-zA-Z]').hasMatch(_passwordController.text);
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_passwordController.text);
  bool get _isPasswordComplex => _hasMinLength && _hasLetter && _hasNumber;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _passwordError = null;
      _confirmPasswordError = null;
    });

    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      return;
    } else if (!_isPasswordComplex) {
      setState(() => _passwordError = 'Password does not meet the security requirements');
      return;
    }

    if (confirmPassword.isEmpty) {
      setState(() => _confirmPasswordError = 'Please confirm your new password');
      return;
    } else if (password != confirmPassword) {
      setState(() => _confirmPasswordError = 'Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).resetPassword(
        email: widget.email,
        otp: widget.otp,
        newPassword: password,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password has been reset successfully! Please sign in with your new password.'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );

      context.go('/sign-in');
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildCriteriaItem(String label, bool isMet) {
    const activeColor = Color(0xFF2E7D32);
    final inactiveColor = Theme.of(context).colorScheme.outline;
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

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmDialog(
        title: 'Cancel password reset?',
        message: 'Are you sure you want to cancel? Your new password will not be saved.',
        confirmLabel: 'Yes, Cancel',
        cancelLabel: 'Stay',
        isDestructive: true,
        onConfirm: () {
          context.go('/sign-in');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showCancelDialog();
      },
      child: Scaffold(
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
                    FigmaBackButton(
                      onPressed: _showCancelDialog,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Set New Password',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text(
                'Create a new password for ${widget.email.isNotEmpty ? widget.email : 'your account'}.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 28),

              // New Password Field
              AppTextField(
                controller: _passwordController,
                labelText: 'New Password',
                hintText: '',
                errorText: _passwordError,
                obscureText: _obscurePassword,
                onChanged: (_) {
                  setState(() {
                    if (_passwordError != null) _passwordError = null;
                  });
                },
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 12),

              // Criteria Checklist
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withAlpha(50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCriteriaItem('At least 8 characters', _hasMinLength),
                    _buildCriteriaItem('Contains at least one letter', _hasLetter),
                    _buildCriteriaItem('Contains at least one number', _hasNumber),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Confirm Password Field
              AppTextField(
                controller: _confirmPasswordController,
                labelText: 'Confirm New Password',
                hintText: '',
                errorText: _confirmPasswordError,
                obscureText: _obscureConfirmPassword,
                onChanged: (_) {
                  if (_confirmPasswordError != null) setState(() => _confirmPasswordError = null);
                },
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
              const SizedBox(height: 36),

              // Reset Password Button
              PrimaryButton(
                label: 'Reset Password',
                isLoading: _isLoading,
                onPressed: _handleResetPassword,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
