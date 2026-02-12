import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import 'package:travel_mate_app/app/theme.dart';
import 'package:travel_mate_app/app/constants.dart';
import 'package:travel_mate_app/core/services/auth_service.dart';

/// 계정 설정 화면. 로그아웃·계정 삭제 등.
class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _changeEmail(BuildContext context) async {
    final TextEditingController emailController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Email'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'New Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your new email';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                try {
                  await FirebaseAuth.instance.currentUser?.updateEmail(emailController.text.trim());
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email updated successfully!')),
                    );
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  setState(() {
                    _errorMessage = 'Failed to update email: ${e.toString()}';
                  });
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          throw Exception('User not logged in.');
        }

        // Call backend API to delete user data
        // TODO: Implement actual API call for backend to delete user data in MariaDB
        // For now, simulate deletion in Firebase Auth directly
        await currentUser.delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account deleted successfully!')),
          );
          context.go('/login'); // Redirect to login screen after deletion
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to delete account: ${e.toString()}';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        backgroundColor: AppColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Change Email'),
                    onTap: () => _changeEmail(context),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Change Password'),
                    onTap: () {
                      // TODO: Implement change password functionality (Firebase Auth)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Change Password functionality coming soon!')),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.exit_to_app),
                    title: const Text('Logout'),
                    onTap: () async {
                      await Provider.of<AuthService>(context, listen: false).signOut();
                      if (mounted) {
                        context.go('/login'); // Redirect to login after logout
                      }
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                    onTap: () => _deleteAccount(context),
                  ),
                  const Spacer(),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
