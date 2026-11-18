import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/image_utils.dart';
import '../../data/profile_repository.dart';
import '../../models/user_model.dart';

class VerificationSettingsScreen extends StatefulWidget {
  final UserModel user;

  const VerificationSettingsScreen({super.key, required this.user});

  @override
  State<VerificationSettingsScreen> createState() => _VerificationSettingsScreenState();
}

class _VerificationSettingsScreenState extends State<VerificationSettingsScreen> {
  final ProfileRepository _profileRepo = ProfileRepository();
  final TextEditingController _emailController = TextEditingController();

  int _selectedTargetLevel = 2; // 2 or 3
  String _selectedRole = 'student'; // 'student' or 'professor'
  String? _documentBase64;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.user.academicEmail.isNotEmpty
        ? widget.user.academicEmail
        : widget.user.email;
    _selectedRole = widget.user.verificationRole;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    final imageBase64 = await ImageUtils.pickImageFromGallery(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );
    if (imageBase64 != null) {
      setState(() {
        _documentBase64 = imageBase64;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_selectedTargetLevel == 2) {
      final email = _emailController.text.trim();
      if (email.isEmpty || !email.contains('@')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a valid academic email (.edu / .dz)'),
            backgroundColor: AppColors.primary,
          ),
        );
        return;
      }
    } else if (_selectedTargetLevel == 3) {
      if (_documentBase64 == null && widget.user.verificationDocUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please upload a valid student/faculty certificate or ID card.'),
            backgroundColor: AppColors.primary,
          ),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      await _profileRepo.submitVerificationRequest(
        uid: widget.user.uid,
        requestedLevel: _selectedTargetLevel,
        role: _selectedRole,
        academicEmail: _emailController.text.trim(),
        documentBase64: _documentBase64 ?? widget.user.verificationDocUrl,
      );

      // للتجربة المباشرة: تفعيل المستوى فوراً ليرى المستخدم النتيجة والحلقة فوراً
      await _profileRepo.approveVerification(
        uid: widget.user.uid,
        level: _selectedTargetLevel,
        role: _selectedRole,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_selectedTargetLevel == 2
              ? 'Academic email verified successfully!'
              : 'Official $_selectedRole verification approved!'),
          backgroundColor: AppColors.navy,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: $e'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.navy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Academic Verification',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1.0, color: AppColors.borderLight),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        children: [
          // البطاقة التوضيحية الحالية
          _buildCurrentStatusCard(),
          const SizedBox(height: 24.0),

          const Text(
            'SELECT VERIFICATION TIER',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12.0),

          // اختيار المستوى الثاني (إيميل جامعي)
          _buildTierOptionCard(
            tier: 2,
            title: 'Level 2 • Campus Email',
            subtitle: 'Verify using your institutional or university email domain (.edu / .dz)',
            ringColorDesc: 'Navy Ring',
            ringColor: AppColors.navy,
            icon: Icons.mark_email_read_rounded,
          ),
          const SizedBox(height: 12.0),

          // اختيار المستوى الثالث (وثيقة رسمية سنوية)
          _buildTierOptionCard(
            tier: 3,
            title: 'Level 3 • Formally Enrolled',
            subtitle: 'Upload your annual enrollment certificate or official faculty card',
            ringColorDesc: _selectedRole == 'professor' ? 'Academic Gold Ring' : 'Emerald Green Ring',
            ringColor: _selectedRole == 'professor'
                ? const Color(0xFFC59B27)
                : const Color(0xFF0D9488),
            icon: Icons.verified_user_rounded,
          ),
          const SizedBox(height: 24.0),

          // قسم تعبئة البيانات حسب المستوى المختار
          if (_selectedTargetLevel == 2) ...[
            const Text(
              'INSTITUTIONAL EMAIL',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'e.g. name@univ-mascara.dz or student@mit.edu',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                prefixIcon: Icon(Icons.school_rounded, color: AppColors.navy, size: 20),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: AppColors.navy, width: 1.5),
                ),
              ),
            ),
          ] else if (_selectedTargetLevel == 3) ...[
            const Text(
              'ACADEMIC ROLE',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  child: _buildRoleSelector(
                    role: 'student',
                    label: 'University Student',
                    icon: Icons.school_outlined,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: _buildRoleSelector(
                    role: 'professor',
                    label: 'Professor / Doctor',
                    icon: Icons.co_present_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18.0),

            const Text(
              'PROOF DOCUMENT (CERTIFICATE OR ID)',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8.0),
            InkWell(
              borderRadius: BorderRadius.circular(14.0),
              onTap: _pickDocument,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(
                    color: _documentBase64 != null ? AppColors.navy : AppColors.borderLight,
                    width: _documentBase64 != null ? 1.5 : 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _documentBase64 != null
                          ? Icons.check_circle_rounded
                          : Icons.cloud_upload_outlined,
                      size: 34.0,
                      color: _documentBase64 != null ? AppColors.navy : AppColors.textMuted,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      _documentBase64 != null
                          ? 'Document attached successfully'
                          : 'Tap to upload Certificate or Student/Faculty ID Card',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        color: _documentBase64 != null ? AppColors.navy : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    const Text(
                      'Supports JPG, PNG with full academic confidentiality',
                      style: TextStyle(fontSize: 11.0, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 36.0),

          // زر تقديم وتفعيل التحقق
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.0),
              ),
              elevation: 0,
            ),
            onPressed: _isSubmitting ? null : _handleSubmit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Confirm & Apply Verification',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                  ),
          ),
          const SizedBox(height: 30.0),
        ],
      ),
    );
  }

  Widget _buildCurrentStatusCard() {
    final level = widget.user.verificationLevel;
    final role = widget.user.verificationRole;

    String levelName = 'Level 1 • Standard Account';
    String ringDesc = 'Pink Ring (Default)';
    Color badgeColor = AppColors.primary;

    if (level == 2) {
      levelName = 'Level 2 • Institutional Verified';
      ringDesc = 'Campus Navy Ring';
      badgeColor = AppColors.navy;
    } else if (level == 3) {
      if (role == 'professor') {
        levelName = 'Level 3 • Certified Professor';
        ringDesc = 'Academic Gold Ring';
        badgeColor = const Color(0xFFC59B27);
      } else {
        levelName = 'Level 3 • Formally Enrolled Student';
        ringDesc = 'Emerald Green Ring';
        badgeColor = const Color(0xFF0D9488);
      }
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shield_rounded, color: badgeColor, size: 24.0),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Standing',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2.0),
                Text(
                  levelName,
                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: AppColors.navy),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'Profile Ring: $ringDesc',
                  style: TextStyle(fontSize: 11.5, color: badgeColor, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierOptionCard({
    required int tier,
    required String title,
    required String subtitle,
    required String ringColorDesc,
    Color? ringColor,
    Gradient? ringGradient,
    required IconData icon,
  }) {
    final isSelected = _selectedTargetLevel == tier;

    return InkWell(
      borderRadius: BorderRadius.circular(14.0),
      onTap: () {
        setState(() {
          _selectedTargetLevel = tier;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : AppColors.surface,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: isSelected ? AppColors.navy : AppColors.borderLight,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32.0,
              height: 32.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ringColor,
                gradient: ringGradient,
              ),
              child: Center(
                child: Container(
                  width: 24.0,
                  height: 24.0,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Icon(icon, size: 14.0, color: AppColors.navy),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: AppColors.navy.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          ringColorDesc,
                          style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold, color: AppColors.navy),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3.0),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted, height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? AppColors.navy : AppColors.textMuted,
              size: 20.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelector({
    required String role,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;

    return InkWell(
      borderRadius: BorderRadius.circular(12.0),
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.navy.withValues(alpha: 0.06) : AppColors.surface,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? AppColors.navy : AppColors.borderLight,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18.0,
              color: isSelected ? AppColors.navy : AppColors.textMuted,
            ),
            const SizedBox(width: 8.0),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.navy : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
