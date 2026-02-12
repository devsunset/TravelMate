import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:travel_mate_app/app/theme.dart';
import 'package:travel_mate_app/app/constants.dart';
import 'package:travel_mate_app/domain/entities/user_profile.dart';
import 'package:travel_mate_app/domain/usecases/get_user_profile.dart';
import 'package:travel_mate_app/presentation/common/report_button_widget.dart';

/// 특정 사용자 프로필 보기 화면. userId로 조회.
class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
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
      final getUserProfile = Provider.of<GetUserProfile>(context, listen: false);
      final profile = await getUserProfile.execute(widget.userId);
      
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
    // Check if the viewed profile is the current user's profile
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    final isMyProfile = currentUserUid == widget.userId;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isMyProfile ? 'My Profile' : '${_userProfile?.nickname ?? 'User'}\'s Profile'),
        backgroundColor: AppColors.primary,
        actions: [
          if (isMyProfile) // Only show edit button if it's the current user's profile
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.go('/profile/edit'); // Navigate to edit profile screen
              },
            ),
          if (!isMyProfile && _userProfile != null) ...[ // Show message and report button for other users if profile is loaded
            IconButton(
              icon: const Icon(Icons.message),
              onPressed: () {
                final currentUserId = FirebaseAuth.instance.currentUser!.uid;
                final otherUserId = widget.userId;
                final chatRoomId = (currentUserId.compareTo(otherUserId) < 0)
                    ? '${currentUserId}_$otherUserId'
                    : '${otherUserId}_$currentUserId';

                context.go('/chat/room/$chatRoomId', extra: _userProfile!.nickname); // Navigate to chat room
              },
            ),
            ReportButtonWidget(entityType: ReportEntityType.user, entityId: widget.userId),
          ],
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
                        _userProfile?.gender != null && _userProfile!.gender!.isNotEmpty &&
                        _userProfile?.ageRange != null && _userProfile!.ageRange!.isNotEmpty
                        ? '${_userProfile!.gender}, ${_userProfile!.ageRange}'
                        : 'No additional info',
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
