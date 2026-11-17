import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/transitions.dart';
import '../../data/profile_repository.dart';
import '../screens/edit_profile_screen.dart';

class ProfileActionBar extends StatefulWidget {
  final bool isMe;
  final bool initialIsFollowing;
  final String uid;
  final String name;
  final ProfileRepository profileRepo;
  final Function(bool nowFollowing)? onFollowChanged;

  const ProfileActionBar({
    super.key,
    required this.isMe,
    required this.initialIsFollowing,
    required this.uid,
    required this.name,
    required this.profileRepo,
    this.onFollowChanged,
  });

  @override
  State<ProfileActionBar> createState() => _ProfileActionBarState();
}

class _ProfileActionBarState extends State<ProfileActionBar> {
  late bool _isFollowing;

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

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: _isFollowing ? const Color(0xFFF3F5F9) : AppColors.primary,
        foregroundColor: _isFollowing ? AppColors.navy : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
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
        size: 18,
      ),
      label: Text(
        _isFollowing ? 'Following' : 'Follow',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
      ),
    );
  }
}
