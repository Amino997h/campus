import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_colors.dart';

class ImageUtils {
  static final ImagePicker _picker = ImagePicker();

  /// Picks an image from the given [source] and returns its Base64 data URI string.
  static Future<String?> pickImage({
    required ImageSource source,
    int maxWidth = 1024,
    int maxHeight = 1024,
    int imageQuality = 85,
  }) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (file != null) {
        final bytes = await file.readAsBytes();
        return 'data:image/jpeg;base64,${base64Encode(bytes)}';
      }
    } catch (_) {}
    return null;
  }

  /// Convenience method for picking an image from gallery.
  static Future<String?> pickImageFromGallery({
    int maxWidth = 1024,
    int maxHeight = 1024,
    int imageQuality = 85,
  }) {
    return pickImage(
      source: ImageSource.gallery,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
  }

  /// Convenience method for picking an image from camera.
  static Future<String?> pickImageFromCamera({
    int maxWidth = 1024,
    int maxHeight = 1024,
    int imageQuality = 85,
  }) {
    return pickImage(
      source: ImageSource.camera,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
  }

  /// Displays a bottom sheet allowing user to choose camera or gallery.
  static Future<void> showImageSourcePicker(
    BuildContext context, {
    required Function(String base64Image) onImagePicked,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library_rounded, color: AppColors.primary),
              title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () async {
                Navigator.pop(bottomSheetContext);
                final img = await pickImageFromGallery();
                if (img != null) {
                  onImagePicked(img);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_rounded, color: AppColors.navy),
              title: const Text('Take a Photo', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () async {
                Navigator.pop(bottomSheetContext);
                final img = await pickImageFromCamera();
                if (img != null) {
                  onImagePicked(img);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Decodes a base64 string or data URI to Uint8List bytes.
  static Uint8List? decodeBase64(String source) {
    try {
      final base64String = source.contains(',') ? source.split(',').last : source;
      return base64Decode(base64String);
    } catch (_) {
      return null;
    }
  }
}
