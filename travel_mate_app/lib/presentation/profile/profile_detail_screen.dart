import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:travel_mate_app/app/theme.dart';
import 'package:travel_mate_app/app/constants.dart';
import 'package:travel_mate_app/domain/entities/user_profile.dart';
import 'package:travel_mate_app/domain/usecases/get_user_profile.dart';

/// 현재 사용자 프로필 상세·편집 진입 화면.
class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({Key? key}) : super(key: key);

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in.');
      }
      final getUserProfile = Provider.of<GetUserProfile>(context, listen: false);
      final profile = await getUserProfile.execute(currentUser.uid);
      
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = context.watch<User?>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.go('/profile/edit'); // Navigate to edit profile screen
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundImage: NetworkImage(_userProfile?.profileImageUrl ?? 'https://www.gravatar.com/avatar/?d=mp'),
                        backgroundColor: AppColors.lightGrey,
                      ),
                      const SizedBox(height: AppConstants.spacingLarge),
                      Text(
                        _userProfile?.nickname ?? 'N/A',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        currentUser?.email ?? 'No Email',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingLarge),
                      _buildProfileDetailCard(
                        context,
                        title: 'About Me',
                        content: _userProfile?.bio ?? 'No bio provided.',
                      ),
                      const SizedBox(height: AppConstants.spacingMedium),
                      _buildProfileDetailCard(
                        context,
                        title: 'Gender',
                        content: _userProfile?.gender ?? 'N/A',
                      ),
                      const SizedBox(height: AppConstants.spacingMedium),
                      _buildProfileDetailCard(
                        context,
                        title: 'Age Range',
                        content: _userProfile?.ageRange ?? 'N/A',
                      ),
                      const SizedBox(height: AppConstants.spacingMedium),
                      _buildProfileDetailCard(
                        context,
                        title: 'Travel Styles',
                        content: _userProfile?.travelStyles.join(', ') ?? 'No travel styles selected.',
                      ),
                      const SizedBox(height: AppConstants.spacingMedium),
                      _buildProfileDetailCard(
                        context,
                        title: 'Interests',
                        content: _userProfile?.interests.join(', ') ?? 'No interests selected.',
                      ),
                      const SizedBox(height: AppConstants.spacingMedium),
                      _buildProfileDetailCard(
                        context,
                        title: 'Preferred Destinations',
                        content: _userProfile?.preferredDestinations.join(', ') ?? 'No preferred destinations.',
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileDetailCard(BuildContext context, {required String title, required String content}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}