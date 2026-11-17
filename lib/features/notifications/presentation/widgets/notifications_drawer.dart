import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/transitions.dart';
import '../../../posts/presentation/screens/post_details_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../models/notification_model.dart';
import '../../data/notification_repository.dart';
import 'notification_tile.dart';

class NotificationsDrawer extends StatelessWidget {
  const NotificationsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final notifRepo = NotificationRepository();
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_active_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'notifications',
                    style: GoogleFonts.varelaRound(
                      color: AppColors.primary,
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  StreamBuilder<bool>(
                    stream: notifRepo.hasUnreadNotificationsStream(currentUid),
                    builder: (context, snapshot) {
                      final hasUnread = snapshot.data ?? false;
                      return Tooltip(
                        message: 'تعليم الكل كمقروء',
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            backgroundColor: hasUnread
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onPressed: hasUnread
                              ? () async {
                                  await notifRepo.markAllNotificationsAsRead(currentUid);
                                }
                              : null,
                          icon: Icon(
                            Icons.done_all_rounded,
                            size: 18.0,
                            color: hasUnread ? AppColors.primary : AppColors.textMuted,
                          ),
                          label: Text(
                            'مقروء',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              color: hasUnread ? AppColors.primary : AppColors.textMuted,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1.0,
              thickness: 1.0,
              indent: 8,
              endIndent: 8,
              color: AppColors.borderLight,
            ),
            Expanded(
              child: currentUid.isEmpty
                  ? const Center(
                      child: Text('Sign in to view notifications',
                          style: TextStyle(color: AppColors.textMuted)),
                    )
                  : StreamBuilder<List<NotificationModel>>(
                      stream: notifRepo.getMyNotificationsStream(currentUid),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Error loading notifications: ${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: AppColors.primary, fontSize: 12),
                              ),
                            ),
                          );
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(color: AppColors.primary));
                        }

                        final notifications = (snapshot.data ?? []).toList();

                        // Sort newest first
                        notifications.sort((a, b) {
                          if (a.createdAt == null && b.createdAt == null) return 0;
                          if (a.createdAt == null) return 1;
                          if (b.createdAt == null) return -1;
                          return b.createdAt!.compareTo(a.createdAt!);
                        });

                        if (notifications.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.notifications_off_outlined,
                                      size: 48,
                                      color: AppColors.textMuted.withValues(alpha: 0.5)),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'No notifications yet',
                                    style: TextStyle(
                                        color: AppColors.textDark,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'When people like your posts, comment, or follow you, updates will appear here.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: notifications.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            thickness: 0.5,
                            indent: 64,
                            endIndent: 16,
                            color: AppColors.borderLight,
                          ),
                          itemBuilder: (context, index) {
                            final item = notifications[index];
                            final relatedId = item.relatedId;
                            final type = item.type;

                            return NotificationTile(
                              notification: item,
                              onTap: () {
                                notifRepo.markNotificationAsRead(item.id);
                                Navigator.pop(context);

                                if (type == 'follow' && relatedId.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    SlidePageTransition(
                                      page: ProfileScreen(viewUid: relatedId),
                                    ),
                                  );
                                } else if ((type == 'like' || type == 'comment' || type == 'post') &&
                                    relatedId.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    SlidePageTransition(
                                      page: PostDetailsScreen(
                                        postId: relatedId,
                                        content: item.subtitle,
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
