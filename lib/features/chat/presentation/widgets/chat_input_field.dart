import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onPickImage;
  final VoidCallback onSendMessage;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onPickImage,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.borderLight,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.add_photo_alternate_rounded, color: AppColors.navy),
              onPressed: onPickImage,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 10.0,
                  ),
                  hintText: 'Type a message...',
                  hintStyle: const TextStyle(fontSize: 13.0, color: AppColors.textMuted),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(
                      color: AppColors.borderLight,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                onSubmitted: (_) => onSendMessage(),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(Icons.send_rounded, color: AppColors.primary),
              onPressed: onSendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
