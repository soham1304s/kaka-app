import 'package:flutter/material.dart';
import 'package:kaka_app/ui/view_models/auth_view_model.dart';

class EditProfileDialog extends StatefulWidget {
  final AuthViewModel authViewModel;

  const EditProfileDialog({
    super.key,
    required this.authViewModel,
  });

  static void show(BuildContext context, {required AuthViewModel authViewModel}) {
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(authViewModel: authViewModel),
    );
  }

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final user = widget.authViewModel.currentUser;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _save() {
    final current = widget.authViewModel.currentUser;
    if (current == null) return;

    final updated = current.copyWith(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    widget.authViewModel.updateProfile(updated);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1F2937),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
            SizedBox(width: 10),
            Text('Profile updated successfully!'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Edit Profile Details', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Full Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(controller: _nameController, decoration: const InputDecoration(isDense: true)),
            const SizedBox(height: 12),
            const Text('Email Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(controller: _emailController, decoration: const InputDecoration(isDense: true)),
            const SizedBox(height: 12),
            const Text('Phone Number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(controller: _phoneController, decoration: const InputDecoration(isDense: true)),
            const SizedBox(height: 12),
            const Text('Delivery Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(controller: _addressController, maxLines: 2, decoration: const InputDecoration(isDense: true)),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}
