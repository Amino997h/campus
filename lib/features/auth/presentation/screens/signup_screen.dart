import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/campus_majors.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../data/auth_repository.dart';
import '../../../profile/data/profile_repository.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final AuthRepository _authRepo = AuthRepository();
  final ProfileRepository _profileRepo = ProfileRepository();

  String _selectedMajor = CampusMajors.list.first;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim().replaceAll('@', '');
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      UIHelpers.showSnackBar(context, 'Please fill all required fields');
      return;
    }

    if (password != confirmPassword) {
      UIHelpers.showSnackBar(context, 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // 1. التحقق من توفر اسم المستخدم
    final isAvailable = await _profileRepo.isUsernameAvailable(username);
    if (!isAvailable) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        UIHelpers.showSnackBar(
          context,
          'Username already taken. Please choose another!',
          backgroundColor: Colors.redAccent,
        );
      }
      return;
    }

    // 2. تسجيل الحساب
    final error = await _authRepo.signUp(
      email: email,
      password: password,
      name: name,
      username: username,
      major: _selectedMajor,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (error == null) {
      UIHelpers.showSnackBar(
        context,
        'Account created successfully! Welcome to Campus.',
        backgroundColor: AppColors.primary,
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      UIHelpers.showSnackBar(
        context,
        error,
        backgroundColor: Colors.redAccent,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'campus',
          style: GoogleFonts.varelaRound(
            color: AppColors.primary,
            fontSize: 26.0,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                'Create Account',
                style: GoogleFonts.varelaRound(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'Join students and faculty across your campus',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.0,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Full Name
            const Text(
              'Full Name',
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                hintText: 'e.g. Amine Bouzouada',
                hintStyle: const TextStyle(fontSize: 13.0, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.person_outline, color: AppColors.navy, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Username
            const Text(
              'Unique Username',
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                prefixText: '@',
                prefixStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                hintText: 'amine',
                hintStyle: const TextStyle(fontSize: 13.0, color: AppColors.textMuted),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Dropdown List of Majors
            const Text(
              'Major / Department',
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedMajor,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.navy),
                  items: CampusMajors.list.map((String major) {
                    return DropdownMenuItem<String>(
                      value: major,
                      child: Text(
                        major,
                        style: const TextStyle(fontSize: 13.5, color: AppColors.textDark),
                      ),
                    );
                  }).toList(),
                  onChanged: (newVal) {
                    if (newVal != null) {
                      setState(() {
                        _selectedMajor = newVal;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // University Email
            const Text(
              'University Email',
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                hintText: 'student@university.edu',
                hintStyle: const TextStyle(fontSize: 13.0, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.navy, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Password
            const Text(
              'Password',
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                hintText: 'Create a password',
                hintStyle: const TextStyle(fontSize: 13.0, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.navy, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Confirm Password
            const Text(
              'Confirm Password',
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                hintText: 'Re-enter password',
                hintStyle: const TextStyle(fontSize: 13.0, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.lock_reset, color: AppColors.navy, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                elevation: 0,
              ),
              onPressed: _isLoading ? null : _handleSignUp,
              child: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Sign Up & Setup Profile',
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account? ',
                  style: TextStyle(
                    fontSize: 13.0,
                    color: AppColors.textMuted,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
