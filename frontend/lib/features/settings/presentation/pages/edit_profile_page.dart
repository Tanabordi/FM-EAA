import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/user_avatar.dart';

// TODO(screen #23 Edit Profile): อวตาร + ปุ่มกล้อง, ช่อง Name, Email, หัวข้อ "Change password" ("Leave blank to keep your current password."), Current Password, New Password, ปุ่ม Save Changes
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController(text: 'Alex Lee');
  final _emailController = TextEditingController(text: 'alex.lee@example.com');
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar with camera icon
              Center(
                child: Stack(
                  children: [
                    const UserAvatar(name: 'Alex Lee', radius: 48),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: _nameController,
                labelText: 'Name',
                hintText: 'Enter your name',
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _emailController,
                labelText: 'Email',
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 32),
              const Text('Change password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(
                'Leave blank to keep your current password.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _currentPasswordController,
                labelText: 'Current Password',
                hintText: 'Enter current password',
                obscureText: true,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _newPasswordController,
                labelText: 'New Password',
                hintText: 'Enter new password',
                obscureText: true,
              ),
              const SizedBox(height: 36),
              PrimaryButton(
                label: 'Save Changes',
                onPressed: () {
                  // TODO(profile update): Call API to update user profile
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

