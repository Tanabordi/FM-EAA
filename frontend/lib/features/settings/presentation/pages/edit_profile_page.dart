import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/user_avatar.dart';
import 'package:fm_eaa/features/settings/providers/settings_provider.dart';

/// Screen #23: Edit Profile matching Figma Node 138:183
/// Features Avatar with camera button and photo picker bottom sheet (Camera/Gallery/Remove),
/// Name and Email fields, Change password section, password visibility toggle,
/// unsaved changes discard confirmation on back, tap-outside keyboard dismissal,
/// and smooth TextInputAction navigation
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;

  late final FocusNode _nameFocus;
  late final FocusNode _emailFocus;
  late final FocusNode _currentPasswordFocus;
  late final FocusNode _newPasswordFocus;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;

  String? _selectedAvatarPath;
  XFile? _selectedImageFile;
  bool _removeAvatar = false;
  bool _forceExit = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProfileProvider);
    _nameController = TextEditingController(text: user.username);
    _emailController = TextEditingController(text: user.email);
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();

    _nameFocus = FocusNode();
    _emailFocus = FocusNode();
    _currentPasswordFocus = FocusNode();
    _newPasswordFocus = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.clear();
    _currentPasswordController.dispose();
    _newPasswordController.clear();
    _newPasswordController.dispose();

    _nameFocus.dispose();
    _emailFocus.dispose();
    _currentPasswordFocus.dispose();
    _newPasswordFocus.dispose();
    super.dispose();
  }

  bool get _hasUnsavedChanges {
    if (_forceExit) return false;
    final user = ref.read(userProfileProvider);
    return _nameController.text != user.username ||
        _emailController.text != user.email ||
        _currentPasswordController.text.isNotEmpty ||
        _newPasswordController.text.isNotEmpty ||
        _selectedAvatarPath != null ||
        _removeAvatar;
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
            Navigator.of(context).pop();
          },
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _showPhotoPickerSheet() async {
    final theme = Theme.of(context);
    final user = ref.read(userProfileProvider);
    final hasPhoto = (!_removeAvatar && (_selectedAvatarPath != null || (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)));

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Change Profile Photo',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                    child: Icon(Icons.photo_camera_outlined, color: theme.colorScheme.primary),
                  ),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                    child: Icon(Icons.photo_library_outlined, color: theme.colorScheme.primary),
                  ),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (hasPhoto)
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFEBEE),
                      child: Icon(Icons.delete_outline, color: Color(0xFFB91C1C)),
                    ),
                    title: const Text(
                      'Remove Photo',
                      style: TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.of(bottomSheetContext).pop();
                      setState(() {
                        _selectedImageFile = null;
                        _selectedAvatarPath = null;
                        _removeAvatar = true;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = pickedFile;
          _selectedAvatarPath = pickedFile.path;
          _removeAvatar = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not access image: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleSave() async {
    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;

    bool hasError = false;

    if (name.isEmpty) {
      setState(() => _nameError = 'Name is required');
      hasError = true;
    }

    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      setState(() => _emailError = 'Please enter a valid email address');
      hasError = true;
    }

    if (newPassword.isNotEmpty) {
      if (currentPassword.isEmpty) {
        setState(() => _passwordError = 'Current password is required to set a new password');
        hasError = true;
      } else if (newPassword.length < 8) {
        setState(() => _passwordError = 'New password must be at least 8 characters long');
        hasError = true;
      }
    }

    if (hasError) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(userProfileProvider);
      String? finalAvatarUrl = _removeAvatar ? null : user.avatarUrl;

      // Upload newly selected image file to Oracle Cloud Object Storage via backend
      if (!_removeAvatar && _selectedImageFile != null) {
        final bytes = await _selectedImageFile!.readAsBytes();
        final fileName = _selectedImageFile!.name;
        finalAvatarUrl = await ref.read(authRepositoryProvider).uploadAvatar(bytes, fileName);
      }

      await ref.read(userProfileProvider.notifier).updateProfile(
            name: name,
            email: email,
            avatarUrl: finalAvatarUrl,
            clearAvatar: _removeAvatar,
            currentPassword: currentPassword.isNotEmpty ? currentPassword : null,
            newPassword: newPassword.isNotEmpty ? newPassword : null,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() => _forceExit = true);
      _currentPasswordController.clear();
      _newPasswordController.clear();
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(userProfileProvider);
    final displayedAvatarUrl = _removeAvatar ? null : (_selectedAvatarPath ?? user.avatarUrl);

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          leadingWidth: 68,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: AppBackButton(
              onPressed: _handleBack,
            ),
          ),
          title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.opaque,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Avatar with camera icon
                  Center(
                    child: GestureDetector(
                      onTap: _showPhotoPickerSheet,
                      child: Stack(
                        children: [
                          UserAvatar(name: user.username, avatarUrl: displayedAvatarUrl, radius: 48),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: theme.colorScheme.primary,
                              child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Name Field
                  AppTextField(
                    controller: _nameController,
                    focusNode: _nameFocus,
                    labelText: 'Name',
                    hintText: 'Enter your name',
                    errorText: _nameError,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _emailFocus.requestFocus(),
                    onChanged: (_) {
                      if (_nameError != null) setState(() => _nameError = null);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  AppTextField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    errorText: _emailError,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _currentPasswordFocus.requestFocus(),
                    onChanged: (_) {
                      if (_emailError != null) setState(() => _emailError = null);
                    },
                  ),
                  const SizedBox(height: 32),

                  // Change Password Section
                  const Text(
                    'Change password',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Leave blank to keep your current password.',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                  ),
                  if (_passwordError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _passwordError!,
                      style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 16),

                  AppTextField(
                    controller: _currentPasswordController,
                    focusNode: _currentPasswordFocus,
                    labelText: 'Current Password',
                    hintText: 'Enter current password',
                    obscureText: _obscureCurrentPassword,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _newPasswordFocus.requestFocus(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrentPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                    ),
                    onChanged: (_) {
                      if (_passwordError != null) setState(() => _passwordError = null);
                    },
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    controller: _newPasswordController,
                    focusNode: _newPasswordFocus,
                    labelText: 'New Password',
                    hintText: 'Enter new password',
                    obscureText: _obscureNewPassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      FocusScope.of(context).unfocus();
                      _handleSave();
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                    ),
                    onChanged: (_) {
                      if (_passwordError != null) setState(() => _passwordError = null);
                    },
                  ),
                  const SizedBox(height: 36),

                  // Save Changes Button
                  PrimaryButton(
                    label: 'Save Changes',
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _handleSave,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
