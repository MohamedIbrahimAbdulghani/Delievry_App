import 'package:flutter/material.dart';

class ProductImageGallery extends StatelessWidget {
  final List<String> imageUrls;

  const ProductImageGallery({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 300,
      child: PageView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Image.network(
            imageUrls[index],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[200],
              child: const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
