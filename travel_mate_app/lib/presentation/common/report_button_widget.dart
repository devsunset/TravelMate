import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:travel_mate_app/app/theme.dart';

/// 신고 대상 종류(사용자, 게시글, 일정, 댓글).
enum ReportEntityType { user, post, itinerary, comment }

/// 신고 버튼 위젯. 탭 시 신고 작성 화면으로 이동.
class ReportButtonWidget extends StatelessWidget {
  final ReportEntityType entityType;
  final String entityId;
  final String? reporterUserId;

  const ReportButtonWidget({
    Key? key,
    required this.entityType,
    required this.entityId,
    this.reporterUserId,
  }) : super(key: key);

  void _showReportDialog(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('신고하려면 로그인하세요.')),
      );
      return;
    }

    context.go(
      '/report',
      extra: {
        'entityType': entityType,
        'entityId': entityId,
        'reporterUserId': currentUser.uid,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.flag),
      color: AppColors.grey,
      onPressed: () => _showReportDialog(context),
    );
  }
}
