import 'dart:convert';
import 'package:flutter/material.dart';

class PostImageWidget extends StatelessWidget {
  final String imageSource;
  final BoxFit fit;

  const PostImageWidget({
    super.key,
    required this.imageSource,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageSource.isEmpty) return const SizedBox.shrink();

    return imageSource.startsWith('data:image')
        ? _buildMemoryImage()
        : _buildNetworkImage();
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.grey.shade100,
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildMemoryImage() {
    try {
      final base64String = imageSource.split(',').last;
      final bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        width: double.infinity,
        fit: fit,
        gaplessPlayback: true,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return _buildPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildNetworkImage() {
    return Image.network(
      imageSource,
      width: double.infinity,
      fit: fit,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return _buildPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    );
  }
}

