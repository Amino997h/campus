import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/profile_repository.dart';

class AddProjectDialog extends StatefulWidget {
  final String uid;
  final ProfileRepository profileRepo;

  const AddProjectDialog({
    super.key,
    required this.uid,
    required this.profileRepo,
  });

  @override
  State<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String? _validateGitHubUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a GitHub repository URL';
    }
    final clean = value.trim();
    if (!clean.startsWith('http://') && !clean.startsWith('https://')) {
      return 'URL must start with https://';
    }
    final uri = Uri.tryParse(clean);
    if (uri == null || (!uri.host.contains('github.com') && !uri.host.contains('gitlab.com'))) {
      return 'Please enter a valid GitHub repository URL (github.com/...)';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await widget.profileRepo.addProject(
        uid: widget.uid,
        title: _titleController.text.trim(),
        githubUrl: _urlController.text.trim(),
        description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project added successfully 🎉'),
            backgroundColor: AppColors.navy,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding project: $e'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.code_rounded,
                        color: AppColors.primary,
                        size: 24.0,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Project / Repo',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navy,
                            ),
                          ),
                          Text(
                            'Showcase your GitHub project or repo',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),

                // Project Title
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Project Title *',
                    hintText: 'e.g. Smart Campus App (Graduation Project)',
                    hintStyle: const TextStyle(fontSize: 12.0, color: AppColors.textMuted),
                    labelStyle: const TextStyle(color: AppColors.navy, fontSize: 13.0),
                    prefixIcon: const Icon(Icons.title_rounded, color: AppColors.navy, size: 20.0),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
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
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a short project title';
                    }
                    if (val.trim().length > 60) {
                      return 'Title cannot exceed 60 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14.0),

                // GitHub Repo URL
                TextFormField(
                  controller: _urlController,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    labelText: 'GitHub Repository URL *',
                    hintText: 'https://github.com/username/repo-name',
                    hintStyle: const TextStyle(fontSize: 12.0, color: AppColors.textMuted),
                    labelStyle: const TextStyle(color: AppColors.navy, fontSize: 13.0),
                    prefixIcon: const Icon(Icons.link_rounded, color: AppColors.primary, size: 20.0),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
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
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                  validator: _validateGitHubUrl,
                ),
                const SizedBox(height: 14.0),

                // Description
                TextFormField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Description / Tech Stack (Optional)',
                    hintText: 'e.g. Flutter app with Firebase & Node.js API',
                    hintStyle: const TextStyle(fontSize: 12.0, color: AppColors.textMuted),
                    labelStyle: const TextStyle(color: AppColors.navy, fontSize: 13.0),
                    prefixIcon: const Icon(Icons.notes_rounded, color: AppColors.navy, size: 20.0),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
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
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 22.0),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20.0,
                                height: 20.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Add Project',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
