import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/transitions.dart';
import '../../../chat/data/chat_repository.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../data/profile_repository.dart';
import '../screens/edit_profile_screen.dart';

class ProfileActionBar extends StatefulWidget {
  final bool isMe;
  final bool initialIsFollowing;
  final String uid;
  final String name;
  final String major;
  final ProfileRepository profileRepo;
  final Function(bool nowFollowing)? onFollowChanged;

  const ProfileActionBar({
    super.key,
    required this.isMe,
    required this.initialIsFollowing,
    required this.uid,
    required this.name,
    this.major = '',
    required this.profileRepo,
    this.onFollowChanged,
  });

  @override
  State<ProfileActionBar> createState() => _ProfileActionBarState();
}

class _ProfileActionBarState extends State<ProfileActionBar> {
  late bool _isFollowing;
  bool _isOpeningChat = false;
  final ChatRepository _chatRepo = ChatRepository();

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.initialIsFollowing;
  }

  @override
  void didUpdateWidget(covariant ProfileActionBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIsFollowing != _isFollowing) {
      _isFollowing = widget.initialIsFollowing;
    }
  }

  Future<void> _handleFollowToggle() async {
    // 1. تحديث تفاؤلي فوري حصرياً داخل الزر نفسه
    final previousState = _isFollowing;
    setState(() {
      _isFollowing = !_isFollowing;
    });

    // 2. إبلاغ العداد فقط للتحديث المنعزل دون عمل setState على الشاشة
    widget.onFollowChanged?.call(_isFollowing);

    // 3. إرسال الطلب لـ Firestore في الخلفية
    try {
      final nowFollowing = await widget.profileRepo.toggleFollow(widget.uid);
      if (mounted && nowFollowing != _isFollowing) {
        setState(() {
          _isFollowing = nowFollowing;
        });
      }
    } catch (_) {
      // تراجع محلي في حالة حدوث خطأ في الشبكة
      if (mounted) {
        setState(() {
          _isFollowing = previousState;
        });
        widget.onFollowChanged?.call(previousState);
      }
    }
  }

  Future<void> _handleDirectMessage() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null || currentUid.isEmpty || currentUid == 'guest') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please sign in to send direct messages.'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    if (currentUid == widget.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You cannot message yourself.'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    if (_isOpeningChat) return;

    setState(() {
      _isOpeningChat = true;
    });

    try {
      final chatId = await _chatRepo.getOrCreateChatId(
        currentUid: currentUid,
        recipientUid: widget.uid,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        SlidePageTransition(
          page: ChatScreen(
            chatId: chatId,
            userName: widget.name,
            recipientUid: widget.uid,
            userStatus: widget.major.isNotEmpty
                ? 'Campus Student • ${widget.major}'
                : 'Campus Student',
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open chat: $e'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningChat = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isMe) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.fromLTRB(28.0, 10.0, 28.0, 10.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 0,
        ),
        onPressed: () {
          Navigator.push(
            context,
            SlidePageTransition(page: const EditProfileScreen()),
          );
        },
        child: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // زر المراسلة الخاصة (Message Icon Pill Button) إلى اليمين
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20.0),
            onTap: _isOpeningChat ? null : _handleDirectMessage,
            child: Container(
              height: 38.0,
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: AppColors.borderLight,
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isOpeningChat
                      ? SizedBox(
                          width: 14.0,
                          height: 14.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.navy),
                          ),
                        )
                      : Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 16.0,
                          color: AppColors.navy,
                        ),
                  const SizedBox(width: 6.0),
                  Text(
                    'Message',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10.0),
        // زر الاشتراك / المتابعة (Follow / Following Button)
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: _isFollowing ? const Color(0xFFF3F5F9) : AppColors.primary,
            foregroundColor: _isFollowing ? AppColors.navy : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 9.0),
            minimumSize: const Size(0, 38.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: BorderSide(
                color: _isFollowing ? AppColors.borderLight : AppColors.primary,
              ),
            ),
            elevation: 0,
          ),
          onPressed: _handleFollowToggle,
          icon: Icon(
            _isFollowing ? Icons.check_rounded : Icons.person_add_rounded,
            size: 16,
          ),
          label: Text(
            _isFollowing ? 'Following' : 'Follow',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
          ),
        ),
      ],
    );
  }
}
