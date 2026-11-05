import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/l10n/locale_provider.dart';
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

  bool get _isTh {
    try {
      return ref.watch(localeProvider).languageCode == 'th';
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

  bool get _hasNewPasswordMinLength =>
      _newPasswordController.text.length >= 8 && _newPasswordController.text.length <= 64;
  bool get _hasNewPasswordLetter => RegExp(r'[a-zA-Z]').hasMatch(_newPasswordController.text);
  bool get _hasNewPasswordNumber => RegExp(r'[0-9]').hasMatch(_newPasswordController.text);

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
    final isTh = _isThRead();
    if (_hasUnsavedChanges) {
      showDialog(
        context: context,
        builder: (dialogContext) => ConfirmDialog(
          title: isTh ? 'ละทิ้งการเปลี่ยนแปลง?' : 'Discard changes?',
          message: isTh
              ? 'คุณมีข้อมูลที่ยังไม่ได้บันทึก คุณแน่ใจหรือไม่ว่าต้องการละทิ้ง?'
              : 'You have unsaved changes. Are you sure you want to discard them?',
          confirmLabel: isTh ? 'ละทิ้ง' : 'Discard',
          cancelLabel: isTh ? 'แก้ไขต่อ' : 'Keep editing',
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
                Text(
                  _isThRead() ? 'เปลี่ยนรูปโปรไฟล์' : 'Change Profile Photo',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                    child: Icon(Icons.photo_camera_outlined, color: theme.colorScheme.primary),
                  ),
                  title: Text(_isThRead() ? 'ถ่ายภาพ' : 'Take Photo'),
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
                  title: Text(_isThRead() ? 'เลือกจากคลังภาพ' : 'Choose from Gallery'),
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
                    title: Text(
                      _isThRead() ? 'ลบรูปภาพ' : 'Remove Photo',
                      style: const TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.w500),
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
      final errStr = e.toString().toLowerCase();
      final msg = (errStr.contains('camera_access_denied') || errStr.contains('permission'))
          ? (source == ImageSource.camera
              ? 'Camera permission was denied. Please allow camera access in Settings.'
              : 'Photo library permission was denied. Please allow gallery access in Settings.')
          : 'Could not access image. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
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
    final isTh = _isThRead();

    if (name.isEmpty) {
      setState(() => _nameError = isTh ? 'กรุณากรอกชื่อ' : 'Name is required');
      hasError = true;
    } else if (name.length < 3) {
      setState(() => _nameError = isTh ? 'ชื่อผู้ใช้ต้องมีอย่างน้อย 3 ตัวอักษร' : 'Username must be at least 3 characters');
      hasError = true;
    } else if (name.length > 20) {
      setState(() => _nameError = isTh ? 'ชื่อผู้ใช้ต้องไม่เกิน 20 ตัวอักษร' : 'Username must not exceed 20 characters');
      hasError = true;
    } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(name)) {
      setState(() => _nameError = isTh ? 'ใช้ได้เฉพาะตัวอักษร ตัวเลข และขีดล่างเท่านั้น' : 'Letters, numbers, and underscores only');
      hasError = true;
    }

    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      setState(() => _emailError = isTh ? 'กรุณากรอกอีเมลที่ถูกต้อง' : 'Please enter a valid email address');
      hasError = true;
    }

    if (newPassword.isNotEmpty) {
      if (currentPassword.isEmpty) {
        setState(() => _passwordError = isTh ? 'ต้องระบุรหัสผ่านปัจจุบันเพื่อตั้งรหัสผ่านใหม่' : 'Current password is required to set a new password');
        hasError = true;
      } else if (newPassword.length < 8) {
        setState(() => _passwordError = isTh ? 'รหัสผ่านใหม่ต้องมีอย่างน้อย 8 ตัวอักษร' : 'New password must be at least 8 characters long');
        hasError = true;
      } else if (newPassword.length > 64) {
        setState(() => _passwordError = isTh ? 'รหัสผ่านใหม่ต้องไม่เกิน 64 ตัวอักษร' : 'New password must not exceed 64 characters');
        hasError = true;
      } else if (!RegExp(r'[a-zA-Z]').hasMatch(newPassword) || !RegExp(r'[0-9]').hasMatch(newPassword)) {
        setState(() => _passwordError = isTh ? 'รหัสผ่านใหม่ต้องมีทั้งตัวอักษรและตัวเลข' : 'New password must contain both letters and numbers');
        hasError = true;
      }
    }

    if (hasError) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(userProfileProvider);
      final isUsernameChanged = name != user.username;
      final isPasswordChanged = newPassword.isNotEmpty;
      final isAvatarChanged = _removeAvatar || _selectedImageFile != null;
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

      String successMessage;
      if (isUsernameChanged && isPasswordChanged && !isAvatarChanged) {
        successMessage = isTh ? 'อัปเดตชื่อผู้ใช้และรหัสผ่านเรียบร้อยแล้ว' : 'Username and password updated successfully';
      } else if (isUsernameChanged && !isPasswordChanged && !isAvatarChanged) {
        successMessage = isTh ? 'อัปเดตชื่อผู้ใช้เรียบร้อยแล้ว' : 'Username updated successfully';
      } else if (isPasswordChanged && !isUsernameChanged && !isAvatarChanged) {
        successMessage = isTh ? 'อัปเดตรหัสผ่านเรียบร้อยแล้ว' : 'Password updated successfully';
      } else if (isAvatarChanged && !isUsernameChanged && !isPasswordChanged) {
        successMessage = isTh ? 'อัปเดตรูปโปรไฟล์เรียบร้อยแล้ว' : 'Profile photo updated successfully';
      } else {
        successMessage = isTh ? 'อัปเดตโปรไฟล์เรียบร้อยแล้ว' : 'Profile updated successfully';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() => _forceExit = true);
      _currentPasswordController.clear();
      _newPasswordController.clear();
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      String errorMsg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      if (e is DioException && e.response?.data is Map && e.response!.data['error'] != null) {
        errorMsg = e.response!.data['error'].toString();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red.shade700,
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
    final isTh = _isTh;

    int? usernameCooldownDays;
    if (user.lastUsernameChange != null) {
      final nextAllowed = user.lastUsernameChange!.add(const Duration(days: 14));
      final now = DateTime.now();
      if (now.isBefore(nextAllowed)) {
        usernameCooldownDays = nextAllowed.difference(now).inDays + 1;
      }
    }
    final isUsernameLocked = usernameCooldownDays != null;

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
          title: Text(isTh ? 'แก้ไขโปรไฟล์' : 'Edit Profile', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    labelText: isTh ? 'ชื่อ' : 'Name',
                    hintText: isTh ? 'กรอกชื่อของคุณ' : 'Enter your name',
                    helperText: isUsernameLocked
                        ? (isTh
                            ? 'คุณจะเปลี่ยนชื่อผู้ใช้ได้อีกครั้งในอีก $usernameCooldownDays วัน'
                            : 'You can change your username again in $usernameCooldownDays day${usernameCooldownDays > 1 ? 's' : ''}')
                        : (isTh
                            ? '• 3–20 ตัวอักษร (ตัวอักษร, ตัวเลข, ขีดล่าง)\n• เปลี่ยนได้ 1 ครั้งทุกๆ 14 วัน'
                            : '• 3–20 characters (letters, numbers, underscores)\n• Can be changed once every 14 days'),
                    errorText: _nameError,
                    readOnly: isUsernameLocked,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _currentPasswordFocus.requestFocus(),
                    suffixIcon: isUsernameLocked
                        ? Icon(
                            Icons.lock_outline,
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          )
                        : null,
                    onChanged: (_) {
                      if (_nameError != null) setState(() => _nameError = null);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email Field (Locked / Read-only)
                  AppTextField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    labelText: isTh ? 'อีเมล' : 'Email',
                    hintText: isTh ? 'กรอกอีเมลของคุณ' : 'Enter your email',
                    errorText: _emailError,
                    readOnly: true,
                    keyboardType: TextInputType.emailAddress,
                    suffixIcon: Icon(
                      Icons.lock_outline,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    onChanged: (_) {
                      if (_emailError != null) setState(() => _emailError = null);
                    },
                  ),
                  const SizedBox(height: 32),

                  // Change Password Section
                  Text(
                    isTh ? 'เปลี่ยนรหัสผ่าน' : 'Change password',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isTh ? 'เว้นว่างไว้หากไม่ต้องการเปลี่ยนรหัสผ่าน' : 'Leave blank to keep your current password.',
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
                    labelText: isTh ? 'รหัสผ่านปัจจุบัน' : 'Current Password',
                    hintText: isTh ? 'กรอกรหัสผ่านปัจจุบัน' : 'Enter current password',
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
                    labelText: isTh ? 'รหัสผ่านใหม่' : 'New Password',
                    hintText: isTh ? 'กรอกรหัสผ่านใหม่' : 'Enter new password',
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
                      setState(() {
                        if (_passwordError != null) _passwordError = null;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  // Real-time password requirement checklist
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRequirementItem(
                          isMet: _hasNewPasswordMinLength,
                          label: isTh ? 'อย่างน้อย 8 ตัวอักษร (8–64 ตัวอักษร)' : 'At least 8 characters (8–64 characters)',
                          colorScheme: theme.colorScheme,
                        ),
                        _buildRequirementItem(
                          isMet: _hasNewPasswordLetter,
                          label: isTh ? 'มีตัวอักษรภาษาอังกฤษอย่างน้อย 1 ตัว (a-z, A-Z)' : 'At least 1 letter (a-z, A-Z)',
                          colorScheme: theme.colorScheme,
                        ),
                        _buildRequirementItem(
                          isMet: _hasNewPasswordNumber,
                          label: isTh ? 'มีตัวเลขอย่างน้อย 1 ตัว (0-9)' : 'At least 1 number (0-9)',
                          colorScheme: theme.colorScheme,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Save Changes Button
                  PrimaryButton(
                    label: isTh ? 'บันทึกการเปลี่ยนแปลง' : 'Save Changes',
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
