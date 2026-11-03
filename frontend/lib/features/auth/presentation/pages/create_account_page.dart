import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/figma_auth_widgets.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../providers/auth_provider.dart';

/// Screen #3: Create an Account matching Figma nodes 52:113 & 362:18
class CreateAccountPage extends ConsumerStatefulWidget {
  /// When prefilledEmail is supplied (e.g. from Google or invite flow),
  /// the email field is locked with a lock icon matching frame 2 in Figma
  final String? prefilledEmail;

  const CreateAccountPage({super.key, this.prefilledEmail});

  @override
  ConsumerState<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends ConsumerState<CreateAccountPage> {
  final _usernameController = TextEditingController();
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  late bool _isGoogleLocked;
  bool _forceExit = false;

  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  bool get _hasMinLength =>
      _passwordController.text.length >= 8 && _passwordController.text.length <= 64;
  bool get _hasLetter => RegExp(r'[a-zA-Z]').hasMatch(_passwordController.text);
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_passwordController.text);

  bool get _hasUnsavedChanges {
    if (_forceExit) return false;
    final initialEmail = widget.prefilledEmail ?? '';
    return _usernameController.text.trim().isNotEmpty ||
        _passwordController.text.isNotEmpty ||
        _confirmPasswordController.text.isNotEmpty ||
        _emailController.text.trim() != initialEmail ||
        (_isGoogleLocked && initialEmail.isEmpty);
  }

  void _handleBack() {
    if (_hasUnsavedChanges) {
      showDialog(
        context: context,
        builder: (dialogContext) => ConfirmDialog(
          title: 'Discard changes?',
          message: 'You have unsaved changes. Are you sure you want to discard them?',
          confirmLabel: 'Discard',
          cancelLabel: 'Keep editing',
          isDestructive: true,
          onConfirm: () {
            setState(() => _forceExit = true);
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/sign-in');
            }
          },
        ),
      );
    } else {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/sign-in');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.prefilledEmail ?? '');
    _isGoogleLocked = widget.prefilledEmail != null && widget.prefilledEmail!.isNotEmpty;
  }

  @override
  void didUpdateWidget(covariant CreateAccountPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.prefilledEmail != oldWidget.prefilledEmail && widget.prefilledEmail != null) {
      _emailController.text = widget.prefilledEmail!;
      _isGoogleLocked = widget.prefilledEmail!.isNotEmpty;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    String? uError;
    String? eError;
    String? pError;
    String? cError;

    if (username.isEmpty) {
      uError = 'Username is required';
    } else if (username.length < 3) {
      uError = 'Username must be at least 3 characters';
    } else if (username.length > 20) {
      uError = 'Username must not exceed 20 characters';
    } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      uError = 'Letters, numbers, and underscores only';
    }

    if (email.isEmpty) {
      eError = 'Email is required';
    } else if (!email.contains('@') || !email.contains('.')) {
      eError = 'Please enter a valid email address';
    }

    if (password.isEmpty) {
      pError = 'Password is required';
    } else if (password.length < 8) {
      pError = 'Password must be at least 8 characters';
    } else if (password.length > 64) {
      pError = 'Password must not exceed 64 characters';
    } else if (!RegExp(r'[a-zA-Z]').hasMatch(password) || !RegExp(r'[0-9]').hasMatch(password)) {
      pError = 'Password must contain both letters and numbers';
    }

    if (confirmPassword.isEmpty) {
      cError = 'Please confirm your password';
    } else if (password != confirmPassword) {
      cError = 'Passwords do not match';
    }

    setState(() {
      _usernameError = uError;
      _emailError = eError;
      _passwordError = pError;
      _confirmPasswordError = cError;
    });

    if (uError != null || eError != null || pError != null || cError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please check your input fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Connect to auth repository/provider
      await ref.read(authProvider.notifier).signUp(username, email, password);

      if (!mounted) return;
      setState(() => _forceExit = true);
      context.go('/onboarding');
    } catch (e) {
      if (!mounted) return;
      final errorMsg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() => _isLoading = true);
    try {
      final email = await ref.read(authProvider.notifier).pickGoogleEmail();
      if (!mounted) return;
      if (email == null || email.isEmpty) return; // User cancelled or no email selected

      // Populate Google email, lock the field with lock icon, and transition to Image 2
      setState(() {
        _isGoogleLocked = true;
        _emailController.text = email;
        _emailError = null;
      });
    } catch (e) {
      if (!mounted) return;
      final errorMsg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      if (errorMsg != 'Google sign-in was cancelled') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEmailLocked = _isGoogleLocked || (widget.prefilledEmail != null && widget.prefilledEmail!.isNotEmpty);

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
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
                    FigmaBackButton(
                      onPressed: _handleBack,
                    ),
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
                helperText: '3–20 characters (letters, numbers, underscores)',
                errorText: _usernameError,
                onChanged: (_) {
                  if (_usernameError != null) setState(() => _usernameError = null);
                },
              ),
              const SizedBox(height: 18),
              // Email (supports locked state with lock icon as in Figma 362:18)
              AppTextField(
                controller: _emailController,
                labelText: 'Email',
                hintText: '',
                errorText: _emailError,
                onChanged: (_) {
                  if (_emailError != null) setState(() => _emailError = null);
                },
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
              // Password with real-time requirement checklist
              AppTextField(
                controller: _passwordController,
                labelText: 'Password',
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
              // Real-time password requirement checklist
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
                      label: 'Contains letters (a-z, A-Z)',
                      colorScheme: colorScheme,
                    ),
                    _buildRequirementItem(
                      isMet: _hasNumber,
                      label: 'Contains numbers (0-9)',
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Confirm Password
              AppTextField(
                controller: _confirmPasswordController,
                labelText: 'Confirm Password',
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
                    onTap: _handleBack,
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
    ),
  );
  }

  Widget _buildRequirementItem({
    required bool isMet,
    required String label,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 15,
            color: isMet ? Colors.green.shade600 : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              color: isMet ? Colors.green.shade700 : colorScheme.onSurfaceVariant,
              fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
