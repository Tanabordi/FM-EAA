import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/figma_auth_widgets.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../core/l10n/locale_provider.dart';
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

  bool get _isTh {
    try {
      return ref.read(localeProvider).languageCode == 'th';
    } catch (_) {
      try {
        return Localizations.localeOf(context).languageCode == 'th';
      } catch (_) {
        return false;
      }
    }
  }

  bool _isThRead() {
    try {
      return ref.read(localeProvider).languageCode == 'th';
    } catch (_) {
      try {
        return Localizations.localeOf(context).languageCode == 'th';
      } catch (_) {
        return false;
      }
    }
  }

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
    final isTh = _isThRead();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _passwordError = null;
      _confirmPasswordError = null;
    });

    if (password.isEmpty) {
      setState(() => _passwordError = isTh ? 'กรุณากรอกรหัสผ่าน' : 'Password is required');
      return;
    } else if (!_isPasswordComplex) {
      setState(() => _passwordError = isTh
          ? 'รหัสผ่านไม่ตรงตามข้อกำหนดความปลอดภัย'
          : 'Password does not meet the security requirements');
      return;
    }

    if (confirmPassword.isEmpty) {
      setState(() => _confirmPasswordError = isTh
          ? 'กรุณายืนยันรหัสผ่านใหม่'
          : 'Please confirm your new password');
      return;
    } else if (password != confirmPassword) {
      setState(() => _confirmPasswordError = isTh ? 'รหัสผ่านไม่ตรงกัน' : 'Passwords do not match');
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
        SnackBar(
          content: Text(isTh
              ? 'รีเซ็ตรหัสผ่านสำเร็จเรียบร้อย! กรุณาเข้าสู่ระบบด้วยรหัสผ่านใหม่'
              : 'Password has been reset successfully! Please sign in with your new password.'),
          backgroundColor: const Color(0xFF2E7D32),
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
    final isTh = _isThRead();
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmDialog(
        title: isTh ? 'ยกเลิกการรีเซ็ตรหัสผ่าน?' : 'Cancel password reset?',
        message: isTh
            ? 'คุณแน่ใจหรือไม่ว่าต้องการยกเลิก? รหัสผ่านใหม่ของคุณจะไม่ถูกบันทึก'
            : 'Are you sure you want to cancel? Your new password will not be saved.',
        confirmLabel: isTh ? 'ใช่, ยกเลิก' : 'Yes, Cancel',
        cancelLabel: isTh ? 'ดำเนินการต่อ' : 'Stay',
        isDestructive: true,
        onConfirm: () {
          context.go('/sign-in');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isTh = _isTh;

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
                      isTh ? 'ตั้งรหัสผ่านใหม่' : 'Set New Password',
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
                  isTh
                      ? 'สร้างรหัสผ่านใหม่สำหรับ ${widget.email.isNotEmpty ? widget.email : 'บัญชีของคุณ'}'
                      : 'Create a new password for ${widget.email.isNotEmpty ? widget.email : 'your account'}.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 28),

                // New Password Field
                AppTextField(
                  controller: _passwordController,
                  labelText: isTh ? 'รหัสผ่านใหม่' : 'New Password',
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
                      _buildCriteriaItem(isTh ? 'อย่างน้อย 8 ตัวอักษร' : 'At least 8 characters', _hasMinLength),
                      _buildCriteriaItem(isTh ? 'มีตัวอักษรภาษาอังกฤษอย่างน้อย 1 ตัว' : 'Contains at least one letter', _hasLetter),
                      _buildCriteriaItem(isTh ? 'มีตัวเลขอย่างน้อย 1 ตัว' : 'Contains at least one number', _hasNumber),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Confirm Password Field
                AppTextField(
                  controller: _confirmPasswordController,
                  labelText: isTh ? 'ยืนยันรหัสผ่านใหม่' : 'Confirm New Password',
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
                  label: isTh ? 'รีเซ็ตรหัสผ่าน' : 'Reset Password',
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
