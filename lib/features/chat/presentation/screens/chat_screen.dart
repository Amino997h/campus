import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/transitions.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../core/widgets/dynamic_user_avatar.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../models/chat_message_model.dart';
import '../../data/chat_repository.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_field.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String userName;
  final String userStatus;
  final String recipientUid;

  const ChatScreen({
    super.key,
    required this.chatId,
    this.userName = 'Campus Student',
    this.userStatus = 'Active now',
    this.recipientUid = '',
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatRepository _chatRepo = ChatRepository();
  bool _isSendingImage = false;

  @override
  void initState() {
    super.initState();
    _markAsRead();
  }

  void _markAsRead() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _chatRepo.markChatAsRead(widget.chatId, uid);
    }
  }

  void _sendMessage({String? imageUrl}) {
    final text = _messageController.text.trim();
    if (text.isEmpty && imageUrl == null) return;

    _chatRepo.sendMessage(
      chatId: widget.chatId,
      recipientName: widget.userName,
      recipientUid: widget.recipientUid,
      text: text,
      imageUrl: imageUrl,
    );

    _messageController.clear();
  }

  Future<void> _pickImageAndSend() {
    return ImageUtils.showImageSourcePicker(
      context,
      onImagePicked: (base64Image) async {
        setState(() => _isSendingImage = true);
        try {
          _sendMessage(imageUrl: base64Image);
        } finally {
          if (mounted) setState(() => _isSendingImage = false);
        }
      },
    );
  }

  void _showChatOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetCtx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: AppColors.primary),
              title: Text('Delete Conversation',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              onTap: () async {
                Navigator.pop(bottomSheetCtx);
                final confirm = await UIHelpers.showConfirmDialog(
                  context,
                  title: 'Delete Conversation',
                  content: 'Are you sure you want to delete this conversation and all its messages? This action cannot be undone.',
                  confirmLabel: 'Delete',
                  confirmColor: AppColors.primary,
                );

                if (confirm) {
                  await _chatRepo.deleteChat(widget.chatId);
                  if (mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.navy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: GestureDetector(
          onTap: widget.recipientUid.isNotEmpty
              ? () {
                  Navigator.push(
                    context,
                    SlidePageTransition(
                      page: ProfileScreen(viewUid: widget.recipientUid),
                    ),
                  );
                }
              : null,
          child: Row(
            children: [
              DynamicUserAvatar(
                uid: widget.recipientUid,
                radius: 19,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userName,
                      style: const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      widget.userStatus,
                      style: TextStyle(
                        fontSize: 11.0,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert_rounded, color: AppColors.navy),
            onPressed: _showChatOptionsMenu,
          ),
          const SizedBox(width: 6),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1.0,
            thickness: 1.0,
            indent: 8,
            endIndent: 8,
            color: AppColors.borderLight,
          ),
        ),
      ),
      body: Column(
        children: [
          if (_isSendingImage)
            LinearProgressIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.borderLight,
              minHeight: 2.5,
            ),
          Expanded(
            child: StreamBuilder<List<ChatMessageModel>>(
              stream: _chatRepo.getChatMessagesStream(widget.chatId),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet. Send a message to start chatting!',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.isMe(currentUid);
                    final timestamp = message.createdAt;

                    bool showDateHeader = false;
                    if (timestamp != null) {
                      if (index == messages.length - 1) {
                        showDateHeader = true;
                      } else {
                        final prevTime = messages[index + 1].createdAt;
                        if (prevTime != null && !DateTimeUtils.isSameDay(timestamp, prevTime)) {
                          showDateHeader = true;
                        }
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showDateHeader && timestamp != null)
                          Center(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 14.0),
                              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 5.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E7EE),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                DateTimeUtils.chatDateSeparator(timestamp),
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.navy,
                                ),
                              ),
                            ),
                          ),
                        ChatBubble(
                          message: message,
                          isMe: isMe,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          ChatInputField(
            controller: _messageController,
            onPickImage: _pickImageAndSend,
            onSendMessage: _sendMessage,
          ),
        ],
      ),
    );
  }
}
