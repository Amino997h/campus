import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/transitions.dart';
import '../../../presence/data/presence_service.dart';
import '../../../auth/data/auth_repository.dart';
import '../../data/profile_repository.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ProfileRepository _profileRepo = ProfileRepository();
  final AuthRepository _authRepo = AuthRepository();
  final PresenceService _presenceService = PresenceService();

  bool _notificationsEnabled = true;
  bool _emailAlerts = false;
  bool _campusFeedOnly = true;
  bool _showOnlineStatus = true;
  bool _isLoadingStatus = true;

  @override
  void initState() {
    super.initState();
    _loadOnlinePreference();
  }

  Future<void> _loadOnlinePreference() async {
    final uid = _authRepo.currentUser?.uid;
    if (uid != null) {
      try {
        final user = await _profileRepo.getUserProfile(uid);
        if (mounted && user != null) {
          setState(() {
            _showOnlineStatus = user.showOnlineStatus;
            _isLoadingStatus = false;
          });
          return;
        }
      } catch (_) {}
    }
    if (mounted) setState(() => _isLoadingStatus = false);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authRepo.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navy),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'settings',
          style: GoogleFonts.varelaRound(
            color: AppColors.navy,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
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
      body: ListView(
        children: [
          const SizedBox(height: 12),

          // ACCOUNT & PROFILE SECTION
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'ACCOUNT & PROFILE',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ListTile(
            leading: const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.avatarBg,
              child: Icon(Icons.person, size: 18, color: AppColors.navy),
            ),
            title: Text(
              currentUser?.displayName ?? 'Campus Student',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            subtitle: Text(
              currentUser?.email ?? 'student@campus.edu',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
          ListTile(
            leading: const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.avatarBg,
              child: Icon(Icons.edit, size: 18, color: AppColors.navy),
            ),
            title: const Text('Edit Profile', style: TextStyle(color: AppColors.textDark)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
            onTap: () {
              Navigator.push(context, SlidePageTransition(page: const EditProfileScreen()));
            },
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Divider(color: AppColors.borderLight),
          ),

          // PREFERENCES
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'PREFERENCES & PRIVACY',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SwitchListTile(
            value: _showOnlineStatus,
            activeThumbColor: AppColors.primary,
            title: const Text('Show Online Status',
                style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
            subtitle: const Text('Display pink online indicator when you are active on the app'),
            onChanged: _isLoadingStatus
                ? null
                : (val) {
                    setState(() => _showOnlineStatus = val);
                    _presenceService.setShowOnlineStatus(val);
                  },
          ),
          SwitchListTile(
            value: _notificationsEnabled,
            activeThumbColor: AppColors.primary,
            title: const Text('Push Notifications', style: TextStyle(color: AppColors.textDark)),
            subtitle: const Text('Alerts about posts, comments and likes'),
            onChanged: (val) {
              setState(() {
                _notificationsEnabled = val;
              });
            },
          ),
          SwitchListTile(
            value: _emailAlerts,
            activeThumbColor: AppColors.primary,
            title: const Text('Email Updates', style: TextStyle(color: AppColors.textDark)),
            subtitle: const Text('Weekly digest of campus highlights'),
            onChanged: (val) {
              setState(() {
                _emailAlerts = val;
              });
            },
          ),
          SwitchListTile(
            value: _campusFeedOnly,
            activeThumbColor: AppColors.primary,
            title: const Text('Campus Feed Only', style: TextStyle(color: AppColors.textDark)),
            subtitle: const Text('Prioritize posts from your registered department'),
            onChanged: (val) {
              setState(() {
                _campusFeedOnly = val;
              });
            },
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Divider(color: AppColors.borderLight),
          ),

          // SESSION & LOGOUT
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'SESSION',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ListTile(
            leading: const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.avatarBg,
              child: Icon(Icons.logout, size: 18, color: AppColors.primary),
            ),
            title: const Text('Log Out', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            onTap: () async {
              await _presenceService.setOnline(false);
              await _authRepo.signOut();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
