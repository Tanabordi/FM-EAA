import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/figma_auth_widgets.dart';
import '../../../../shared/widgets/primary_button.dart';

/// Screen #3: Create an Account matching Figma nodes 52:113 & 362:18
class CreateAccountPage extends StatefulWidget {
  /// When prefilledEmail is supplied (e.g. from Google or invite flow),
  /// the email field is locked with a lock icon matching frame 2 in Figma
  final String? prefilledEmail;

  const CreateAccountPage({super.key, this.prefilledEmail});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _usernameController = TextEditingController();
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final bool _isLoading = false;

  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.prefilledEmail ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    // Bypass validation for now while backend/DB is in development
    // Directly navigate to Onboarding & Permission
    context.go('/onboarding');
  }

  Future<void> _handleGoogleSignUp() async {
    // When clicking "Sign up with Google":
    // If not already in locked state, simulate Google login with prefilled locked email
    // Otherwise directly proceed to onboarding
    if (widget.prefilledEmail != null && widget.prefilledEmail!.isNotEmpty) {
      context.go('/onboarding');
    } else {
      context.go('/create-account?email=user@gmail.com');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEmailLocked = widget.prefilledEmail != null && widget.prefilledEmail!.isNotEmpty;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
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
                    'Create an Account',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // Subtitle
              Text(
                'A few details and you’re ready to get started.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 28),
              // Username
              AppTextField(
                controller: _usernameController,
                labelText: 'Username',
                hintText: '',
              ),
              const SizedBox(height: 18),
              // Email (supports locked state with lock icon as in Figma 362:18)
              AppTextField(
                controller: _emailController,
                labelText: 'Email',
                hintText: '',
                readOnly: isEmailLocked,
                keyboardType: TextInputType.emailAddress,
                suffixIcon: isEmailLocked
                    ? Icon(
                        Icons.lock_outline,
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      )
                    : null,
              ),
              const SizedBox(height: 18),
              // Password with helper text "Use at least 8 characters."
              AppTextField(
                controller: _passwordController,
                labelText: 'Password',
                hintText: '',
                helperText: _passwordError == null ? 'Use at least 8 characters.' : null,
                errorText: _passwordError,
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
              const SizedBox(height: 18),
              // Confirm Password
              AppTextField(
                controller: _confirmPasswordController,
                labelText: 'Confirm Password',
                hintText: '',
                errorText: _confirmPasswordError,
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
              // Sign Up Button
              PrimaryButton(
                label: 'Sign Up',
                isLoading: _isLoading,
                onPressed: _handleSignUp,
              ),
              // Show Google Sign Up and Divider only if not locked from Google flow
              if (!isEmailLocked) ...[
                const SizedBox(height: 24),
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
                GoogleSignInButton(
                  label: 'Sign up with Google',
                  onPressed: _handleGoogleSignUp,
                ),
              ],
              const SizedBox(height: 32),
              // Already have an account? Sign In
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/sign-in');
                      }
                    },
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
