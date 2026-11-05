import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/figma_auth_widgets.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../providers/auth_provider.dart';

class VerifyOtpPage extends ConsumerStatefulWidget {
  final String email;

  const VerifyOtpPage({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends ConsumerState<VerifyOtpPage> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;
  String? _otpError;

  int _resendCooldown = 60;
  Timer? _cooldownTimer;

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
        SnackBar(
          content: Text(_isThRead()
              ? 'ส่งรหัสยืนยันใหม่ไปยังอีเมลของคุณเรียบร้อยแล้ว'
              : 'A new verification code has been sent to your email.'),
          backgroundColor: const Color(0xFF2E7D32),
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

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      setState(() => _otpError = _isThRead() ? 'กรุณากรอกรหัสยืนยัน' : 'Verification code is required');
      return;
    } else if (otp.length != 6) {
      setState(() => _otpError = _isThRead() ? 'รหัสยืนยันต้องมี 6 หลัก' : 'Verification code must be 6 digits');
      return;
    }

    setState(() {
      _otpError = null;
      _isLoading = true;
    });

    try {
      await ref.read(authRepositoryProvider).verifyOtp(
        email: widget.email,
        otp: otp,
      );

      if (!mounted) return;
      context.push('/new-password', extra: {
        'email': widget.email,
        'otp': otp,
      });
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() => _otpError = msg);
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

  void _showCancelDialog() {
    final isTh = _isThRead();
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmDialog(
        title: isTh ? 'ยกเลิกการรีเซ็ตรหัสผ่าน?' : 'Cancel password reset?',
        message: isTh
            ? 'คุณแน่ใจหรือไม่ว่าต้องการยกเลิก? คุณจะต้องขอรหัสใหม่อีกครั้งเพื่อรีเซ็ตรหัสผ่าน'
            : 'Are you sure you want to cancel? You will need to request a new code to reset your password.',
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
                      isTh ? 'รหัสยืนยัน' : 'Verification Code',
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
                      ? 'กรอกรหัสยืนยัน 6 หลักที่ส่งไปยัง:'
                      : 'Enter the 6-digit verification code sent to:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.email.isNotEmpty ? widget.email : (isTh ? 'อีเมลของคุณ' : 'your email'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 32),

                // 6-digit OTP Field
                AppTextField(
                  controller: _otpController,
                  labelText: isTh ? 'รหัส 6 หลัก' : '6-Digit Code',
                  hintText: '123456',
                  errorText: _otpError,
                  keyboardType: TextInputType.number,
                  onChanged: (_) {
                    if (_otpError != null) setState(() => _otpError = null);
                  },
                ),
                const SizedBox(height: 16),

                // Resend Code Row with Cooldown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isTh ? 'ไม่ได้รับรหัสใช่หรือไม่?' : "Didn't receive the code?",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: (_resendCooldown == 0 && !_isResending)
                          ? _handleResendOtp
                          : null,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: _isResending
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _resendCooldown > 0
                                  ? (isTh
                                      ? 'ส่งรหัสอีกครั้งใน ${_resendCooldown} วิ'
                                      : 'Resend in ${_resendCooldown}s')
                                  : (isTh ? 'ส่งรหัสอีกครั้ง' : 'Resend Code'),
                              style: TextStyle(
                                color: _resendCooldown > 0
                                    ? colorScheme.outline
                                    : colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // Verify Code Button
                PrimaryButton(
                  label: isTh ? 'ยืนยันรหัส' : 'Verify Code',
                  isLoading: _isLoading,
                  onPressed: _handleVerifyOtp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
