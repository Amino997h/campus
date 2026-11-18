import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../data/post_repository.dart';
import '../../../profile/models/project_model.dart';
import '../../../profile/data/profile_repository.dart';
import '../widgets/select_project_bottom_sheet.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final PostRepository _postRepo = PostRepository();
  final ProfileRepository _profileRepo = ProfileRepository();

  ProjectModel? _selectedProject;
  String? _base64Image;
  Uint8List? _imageBytes;
  bool _isPosting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final img = await ImageUtils.pickImageFromGallery(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (img != null) {
        final bytes = ImageUtils.decodeBase64(img);
        setState(() {
          _base64Image = img;
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        UIHelpers.showSnackBar(
          context,
          'Could not pick image: $e',
          backgroundColor: AppColors.primary,
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _imageBytes = null;
      _base64Image = null;
    });
  }

  void _removeProject() {
    setState(() {
      _selectedProject = null;
    });
  }

  void _openSelectProjectSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (ctx) => SelectProjectBottomSheet(
        profileRepo: _profileRepo,
        onProjectSelected: (project) {
          setState(() {
            _selectedProject = project;
          });
        },
      ),
    );
  }

  Future<void> _handlePost() async {
    final text = _contentController.text.trim();
    if (text.isEmpty && _base64Image == null && _selectedProject == null) return;

    setState(() {
      _isPosting = true;
    });

    try {
      await _postRepo.createPost(
        text: text,
        imageUrl: _base64Image,
        projectRefId: _selectedProject?.id,
        projectRefTitle: _selectedProject?.title,
        projectRefUrl: _selectedProject?.githubUrl,
      );
      if (mounted) {
        Navigator.pop(context);
        UIHelpers.showSnackBar(
          context,
          'Post published to campus!',
          backgroundColor: AppColors.primary,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
        Navigator.pop(context);
      }
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
          icon: Icon(Icons.close_rounded, color: AppColors.navy),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'create post',
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
              onPressed: _isPosting ? null : _handlePost,
              child: _isPosting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Post',
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _contentController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(fontSize: 16.0, height: 1.4, color: AppColors.textDark),
                    decoration: const InputDecoration(
                      hintText: "what's on your mind?",
                      hintStyle: TextStyle(
                        fontSize: 16.0,
                        color: AppColors.textMuted,
                      ),
                      border: InputBorder.none,
                    ),
                  ),

                  // معاينة المشروع المرجعي المختار مع إمكانية إزالته
                  if (_selectedProject != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36.0,
                            height: 36.0,
                            decoration: BoxDecoration(
                              color: AppColors.navy.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Center(
                              child: Icon(Icons.code_rounded, color: AppColors.navy, size: 18.0),
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        _selectedProject!.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.navy,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6.0),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: AppColors.searchBarBg,
                                        borderRadius: BorderRadius.circular(6.0),
                                        border: Border.all(
                                          color: AppColors.borderLight,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: const Text(
                                        'Project',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          color: AppColors.textMuted,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  _selectedProject!.githubUrl,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11.0, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                            onPressed: _removeProject,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                  ],

                  // معاينة الصورة المختارة مع إمكانية حذفها
                  if (_imageBytes != null) ...[
                    const SizedBox(height: 16),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.memory(
                            _imageBytes!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: _removeImage,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.black.withValues(alpha: 0.6),
                              child: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const Divider(
            height: 1.0,
            thickness: 1.0,
            color: AppColors.borderLight,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  iconSize: 26.0,
                  icon: Icon(Icons.add_photo_alternate_rounded, color: AppColors.primary),
                  tooltip: 'إضافة صورة',
                  onPressed: _pickImage,
                ),
                IconButton(
                  iconSize: 24.0,
                  icon: Icon(
                    Icons.code_rounded,
                    color: _selectedProject != null ? AppColors.primary : AppColors.navy,
                  ),
                  tooltip: 'ربط مشروع تخرج / GitHub كمرجع',
                  onPressed: _openSelectProjectSheet,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedProject != null
                        ? 'مرتبط بمشروع: ${_selectedProject!.title}'
                        : (_imageBytes != null ? 'تم إرفاق صورة' : 'أضف صورة أو اربط مشروعاً'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: _selectedProject != null ? AppColors.primary : AppColors.textMuted,
                      fontWeight: _selectedProject != null ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
