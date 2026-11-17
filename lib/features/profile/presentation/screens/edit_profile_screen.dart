import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/campus_majors.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../data/profile_repository.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileRepository _profileRepo = ProfileRepository();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  String _selectedMajor = CampusMajors.list.first;
  String? _photoUrl;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  Future<void> _loadCurrentProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userModel = await _profileRepo.getUserProfile(user.uid);
      if (userModel != null && mounted) {
        setState(() {
          _nameController.text = userModel.name.isNotEmpty ? userModel.name : (user.displayName ?? '');
          _usernameController.text = userModel.username;
          _bioController.text = userModel.bio;
          _photoUrl = userModel.photoUrl;
          if (userModel.major.isNotEmpty && CampusMajors.list.contains(userModel.major)) {
            _selectedMajor = userModel.major;
          }
        });
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final base64Image = await ImageUtils.pickImageFromGallery(
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (base64Image != null && mounted) {
      setState(() {
        _photoUrl = base64Image;
      });
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim().replaceAll('@', '');
    final bio = _bioController.text.trim();

    if (name.isEmpty || username.isEmpty) {
      UIHelpers.showSnackBar(context, 'Name and username cannot be empty');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      final available = await _profileRepo.isUsernameAvailable(
        username,
        excludeUid: currentUid,
      );

      if (!available) {
        if (mounted) {
          setState(() => _isSaving = false);
          UIHelpers.showSnackBar(context, 'Username @$username is already taken. Please choose another.');
        }
        return;
      }

      await _profileRepo.updateProfile(
        name: name,
        username: username,
        major: _selectedMajor,
        bio: bio,
        photoUrl: _photoUrl,
      );

      if (mounted) {
        Navigator.pop(context);
        UIHelpers.showSnackBar(
          context,
          'Profile updated successfully!',
          backgroundColor: AppColors.primary,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        UIHelpers.showSnackBar(context, 'Error updating profile: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.navy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'edit profile',
          style: GoogleFonts.varelaRound(
            color: AppColors.navy,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                elevation: 0,
              ),
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
            ),
          ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          children: [
            // Avatar picker
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  UserAvatar(
                    photoUrl: _photoUrl,
                    radius: 55.0,
                    defaultIcon: Icons.person_rounded,
                  ),
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Full Name Field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: const TextStyle(color: AppColors.navy),
                prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.navy),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Username Field
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: const TextStyle(color: AppColors.navy),
                prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.navy),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Major Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedMajor,
              decoration: InputDecoration(
                labelText: 'Major / Field of Study',
                labelStyle: const TextStyle(color: AppColors.navy),
                prefixIcon: const Icon(Icons.school_rounded, color: AppColors.navy),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              items: CampusMajors.list.map((m) {
                return DropdownMenuItem<String>(
                  value: m,
                  child: Text(m, style: const TextStyle(fontSize: 13.5)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedMajor = val);
                }
              },
            ),
            const SizedBox(height: 16),

            // Bio Field
            TextField(
              controller: _bioController,
              maxLines: 3,
              maxLength: 200,
              decoration: InputDecoration(
                labelText: 'Bio',
                alignLabelWithHint: true,
                labelStyle: const TextStyle(color: AppColors.navy),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 45),
                  child: Icon(Icons.info_outline_rounded, color: AppColors.navy),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
