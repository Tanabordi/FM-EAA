import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/figma_auth_widgets.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../providers/auth_provider.dart';

/// Screen #4: Reset Password matching Figma node 64:3
class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _emailError;

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
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendLink() async {
    final isTh = _isThRead();
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _emailError = isTh ? 'กรุณากรอกอีเมล' : 'Email is required');
      return;
    } else if (!email.contains('@') || !email.contains('.')) {
      setState(() => _emailError = isTh ? 'กรุณากรอกอีเมลที่ถูกต้อง' : 'Please enter a valid email address');
      return;
    }

    setState(() {
      _emailError = null;
      _isLoading = true;
    });

    try {
      await ref.read(authRepositoryProvider).requestPasswordReset(email);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isTh
              ? 'ส่งรหัสรีเซ็ตรหัสผ่านไปยังอีเมลของคุณเรียบร้อยแล้ว'
              : 'Password reset code has been sent to your email.'),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );

      context.push('/verify-otp?email=${Uri.encodeComponent(email)}');
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() => _emailError = msg);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isTh = ref.watch(localeProvider).languageCode == 'th';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar with rounded back button
              Row(
                children: [
                  const FigmaBackButton(),
                  const SizedBox(width: 16),
                  Text(
                    isTh ? 'รีเซ็ตรหัสผ่าน' : 'Reset Password',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Subtitle
              Text(
                isTh ? 'กรอกอีเมลของคุณ' : 'Enter your email',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 24),
              // Email input matching Figma style
              AppTextField(
                controller: _emailController,
                labelText: isTh ? 'อีเมล' : 'Email',
                hintText: '',
                errorText: _emailError,
                onChanged: (_) {
                  if (_emailError != null) setState(() => _emailError = null);
                },
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 32),
              // Send Link Button
              PrimaryButton(
                label: isTh ? 'ส่งรหัสรีเซ็ต' : 'Send Link',
                isLoading: _isLoading,
                onPressed: _handleSendLink,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
