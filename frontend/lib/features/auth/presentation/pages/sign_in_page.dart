import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/figma_auth_widgets.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../providers/auth_provider.dart';

/// Screen #2: Sign In matching Figma node 8:39 exactly
class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _identifierError;
  String? _passwordError;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _identifierError = identifier.isEmpty ? 'Please enter username or email' : null;
      _passwordError = password.isEmpty ? 'Please enter password' : null;
    });

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both username/email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Connect to authProvider
      await ref.read(authProvider.notifier).signIn(identifier, password);

      final prefs = await SharedPreferences.getInstance();
      final hasEnabled = prefs.getBool('notifications_permission_granted') ?? false;

      if (!mounted) return;

      if (!hasEnabled) {
        context.go('/onboarding');
      } else {
        context.go('/fridges');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasEnabled = prefs.getBool('notifications_permission_granted') ?? false;

      if (!mounted) return;

      if (!hasEnabled) {
        context.go('/onboarding');
      } else {
        context.go('/fridges');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // App Logo - Green rounded square with fridge illustration
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7E8D8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.kitchen_outlined,
                      size: 40,
                      color: Color(0xFF2E6A44),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Title matching Figma
              Text(
                'Welcome To\nFridge Management &\nExpiry Alert App',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  height: 1.25,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              // Subtitle
              Text(
                'Sign in to your account to continue.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              // Username or Email
              AppTextField(
                controller: _identifierController,
                labelText: 'Username or Email',
                hintText: '',
                errorText: _identifierError,
                onChanged: (_) {
                  if (_identifierError != null) setState(() => _identifierError = null);
                },
              ),
              const SizedBox(height: 20),
              // Password
              AppTextField(
                controller: _passwordController,
                labelText: 'Password',
                hintText: '',
                errorText: _passwordError,
                onChanged: (_) {
                  if (_passwordError != null) setState(() => _passwordError = null);
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
              const SizedBox(height: 12),
              // Forgot password?
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () => context.push('/reset-password'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Sign In Button
              PrimaryButton(
                label: 'Sign In',
                isLoading: _isLoading,
                onPressed: _handleSignIn,
              ),
              const SizedBox(height: 24),
              // "Or" Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Or',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Google Sign-In Button
              GoogleSignInButton(
                label: 'Sign in with Google',
                onPressed: _handleGoogleSignIn,
              ),
              const SizedBox(height: 36),
              // Don’t have an account? Sign up
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    "Don’t have an account? ",
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                  InkWell(
                    onTap: () => context.push('/create-account'),
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
