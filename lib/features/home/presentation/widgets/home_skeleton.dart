import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar Skeleton
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Banners Skeleton
          Container(
            height: 180,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          // Categories Skeleton
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: SkeletonLine(width: 100),
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    SkeletonBox(size: 60),
                    SizedBox(height: 8),
                    SkeletonLine(width: 50),
                  ],
                ),
              ),
            ),
          ),
          // Restaurants Skeleton
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: SkeletonLine(width: 150),
          ),
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.only(right: 16),
                child: SkeletonBox(width: 280, height: 250),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double? size;

  const SkeletonBox({super.key, this.width, this.height, this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size ?? width,
      height: size ?? height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class SkeletonLine extends StatelessWidget {
  final double width;

  const SkeletonLine({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 15,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
