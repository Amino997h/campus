import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/transitions.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/dynamic_user_avatar.dart';
import '../../../profile/models/user_model.dart';
import '../../../profile/data/profile_repository.dart';
import '../../models/chat_conversation_model.dart';
import '../../data/chat_repository.dart';
import '../screens/chat_screen.dart';

class MessagesDrawer extends StatelessWidget {
  const MessagesDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final chatRepo = ChatRepository();
    final profileRepo = ProfileRepository();

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
                    Icons.forum_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'messages',
                    style: GoogleFonts.varelaRound(
                      color: AppColors.primary,
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 22),
                    onPressed: () => Navigator.pop(context),
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
              child: currentUid == null
                  ? const Center(
                      child: Text('Sign in to view messages', style: TextStyle(color: AppColors.textMuted)),
                    )
                  : StreamBuilder<List<ChatConversationModel>>(
                      stream: chatRepo.getUserChatsStream(currentUid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                        }

                        final conversations = (snapshot.data ?? [])
                            .where((chat) => chat.lastMessage.isNotEmpty)
                            .toList();

                        // Sort by newest message
                        conversations.sort((a, b) {
                          if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
                          if (a.lastMessageTime == null) return 1;
                          if (b.lastMessageTime == null) return -1;
                          return b.lastMessageTime!.compareTo(a.lastMessageTime!);
                        });

                        if (conversations.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.mark_chat_unread_outlined,
                                      size: 48,
                                      color: AppColors.textMuted.withValues(alpha: 0.5)),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'No messages yet',
                                    style: TextStyle(
                                        color: AppColors.textDark,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Visit a student profile or search to start a conversation.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          physics: const ClampingScrollPhysics(),
                          itemCount: conversations.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            thickness: 0.5,
                            indent: 68,
                            endIndent: 16,
                            color: AppColors.borderLight,
                          ),
                          itemBuilder: (context, index) {
                            final chat = conversations[index];
                            final otherUid = chat.getOtherUid(currentUid);
                            final isUnread = chat.isUnreadFor(currentUid);
                            final timeFormatted = DateTimeUtils.chatListTime(chat.lastMessageTime);

                            return StreamBuilder<UserModel?>(
                              stream: profileRepo.getUserProfileStream(otherUid),
                              builder: (context, userSnap) {
                                final user = userSnap.data;
                                final studentName = user?.name.isNotEmpty == true ? user!.name : 'Student';
                                final major = user?.major.isNotEmpty == true ? user!.major : 'CS';
                                final photoUrl = user?.photoUrl;

                                return Container(
                                  color: isUnread ? AppColors.primaryLight.withValues(alpha: 0.35) : Colors.transparent,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 6.0,
                                    ),
                                    leading: Stack(
                                      children: [
                                        DynamicUserAvatar(
                                          uid: otherUid,
                                          initialPhoto: photoUrl,
                                          radius: 22,
                                        ),
                                        if (isUnread)
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: Container(
                                              width: 11,
                                              height: 11,
                                              decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.white, width: 2),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            studentName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: isUnread ? FontWeight.w900 : FontWeight.bold,
                                              color: isUnread ? AppColors.navy : AppColors.textDark,
                                            ),
                                          ),
                                        ),
                                        if (timeFormatted.isNotEmpty)
                                          Text(
                                            timeFormatted,
                                            style: TextStyle(
                                              fontSize: 11.0,
                                              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                                              color: isUnread ? AppColors.primary : AppColors.textMuted,
                                            ),
                                          ),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 3.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              chat.lastMessage,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: isUnread ? FontWeight.w700 : FontWeight.normal,
                                                color: isUnread ? AppColors.navy : AppColors.textMuted,
                                              ),
                                            ),
                                          ),
                                          if (isUnread)
                                            Container(
                                              margin: const EdgeInsets.only(left: 6),
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Text(
                                                'NEW',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        SlidePageTransition(
                                          page: ChatScreen(
                                            chatId: chat.chatId,
                                            userName: studentName,
                                            recipientUid: otherUid,
                                            userStatus: 'Online • Campus $major',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
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
