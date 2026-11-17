import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/post_image_widget.dart';
import '../../models/chat_message_model.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = DateTimeUtils.chatMessageTime(message.createdAt);
    final hasImage = message.hasImage;
    final hasText = message.hasText;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.76,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: hasImage && !hasText ? 4.0 : 12.0,
          vertical: hasImage && !hasText ? 4.0 : 8.0,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1.5),
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16.0),
            topRight: const Radius.circular(16.0),
            bottomLeft: Radius.circular(isMe ? 16.0 : 4.0),
            bottomRight: Radius.circular(isMe ? 4.0 : 16.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (hasImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PostImageWidget(imageSource: message.imageUrl),
              ),
              if (hasText) const SizedBox(height: 6),
            ],
            if (hasText)
              Padding(
                padding: const EdgeInsets.only(bottom: 3.0),
                child: Text(
                  message.text,
                  style: TextStyle(
                    fontSize: 14.2,
                    height: 1.3,
                    color: isMe ? Colors.white : AppColors.textDark,
                  ),
                ),
              ),
            if (timeStr.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w600,
                      color: isMe ? Colors.white.withValues(alpha: 0.8) : AppColors.textMuted,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 3),
                    Icon(
                      Icons.done_all_rounded,
                      size: 13,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
