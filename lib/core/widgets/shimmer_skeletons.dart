import 'package:flutter/material.dart';
import 'shimmer.dart';

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double? size;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.size,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size ?? width,
      height: size ?? height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class SkeletonLine extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLine({
    super.key,
    required this.width,
    this.height = 15,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class ListSkeleton extends StatelessWidget {
  final int itemCount;
  final bool hasLeading;
  final bool isLeadingCircle;
  final bool hasTrailing;
  final double height;

  const ListSkeleton({
    super.key,
    this.itemCount = 5,
    this.hasLeading = true,
    this.isLeadingCircle = false,
    this.hasTrailing = false,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            height: height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                if (hasLeading) ...[
                  if (isLeadingCircle)
                    const SkeletonBox(size: 50, borderRadius: 25)
                  else
                    const SkeletonBox(size: 50, borderRadius: 12),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SkeletonLine(width: 140),
                      const SizedBox(height: 8),
                      const SkeletonLine(width: 200, height: 12),
                    ],
                  ),
                ),
                if (hasTrailing) ...[
                  const SizedBox(width: 16),
                  const SkeletonBox(width: 40, height: 20, borderRadius: 8),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class RestaurantDetailsSkeleton extends StatelessWidget {
  const RestaurantDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Image Banner placeholder
          const SkeletonBox(width: double.infinity, height: 250, borderRadius: 0),
          // Info header card mock
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLine(width: 200, height: 24),
                const SizedBox(height: 8),
                const SkeletonLine(width: 120, height: 16),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    SkeletonBox(width: 60, height: 20, borderRadius: 6),
                    SizedBox(width: 12),
                    SkeletonBox(width: 80, height: 20, borderRadius: 6),
                  ],
                ),
              ],
            ),
          ),
          // Tabs bar skeleton
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Row(
              children: const [
                Expanded(child: Center(child: SkeletonLine(width: 80, height: 18))),
                Expanded(child: Center(child: SkeletonLine(width: 80, height: 18))),
              ],
            ),
          ),
          const Divider(height: 1),
          // List of meals
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const SkeletonBox(size: 80, borderRadius: 12),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            SkeletonLine(width: 120, height: 16),
                            SizedBox(height: 8),
                            SkeletonLine(width: 180, height: 12),
                            SizedBox(height: 8),
                            SkeletonLine(width: 60, height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProductDetailsSkeleton extends StatelessWidget {
  const ProductDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Big Image Gallery placeholder
          const SkeletonBox(width: double.infinity, height: 300, borderRadius: 0),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    SkeletonLine(width: 200, height: 24),
                    SkeletonLine(width: 60, height: 24),
                  ],
                ),
                const SizedBox(height: 16),
                const SkeletonLine(width: double.infinity, height: 14),
                const SizedBox(height: 8),
                const SkeletonLine(width: double.infinity, height: 14),
                const SizedBox(height: 8),
                const SkeletonLine(width: 180, height: 14),
                const SizedBox(height: 32),
                // Options selector placeholders
                const SkeletonLine(width: 100, height: 18),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    SkeletonBox(width: 100, height: 45, borderRadius: 12),
                    SizedBox(width: 12),
                    SkeletonBox(width: 100, height: 45, borderRadius: 12),
                  ],
                ),
                const SizedBox(height: 32),
                // Special instructions textfield placeholder
                const SkeletonLine(width: 150, height: 18),
                const SizedBox(height: 12),
                const SkeletonBox(width: double.infinity, height: 80, borderRadius: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderDetailsSkeleton extends StatelessWidget {
  const OrderDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Card placeholder
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const SkeletonBox(size: 60, borderRadius: 8),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SkeletonLine(width: 140, height: 18),
                        SizedBox(height: 8),
                        SkeletonLine(width: 80, height: 14),
                      ],
                    ),
                  ),
                  const SkeletonBox(width: 80, height: 25, borderRadius: 12),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Items List Card placeholder
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonLine(width: 100, height: 16),
                  const SizedBox(height: 16),
                  ...List.generate(2, (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: const [
                        SkeletonBox(width: 25, height: 20, borderRadius: 4),
                        SizedBox(width: 12),
                        Expanded(child: SkeletonLine(width: 150, height: 14)),
                        SkeletonLine(width: 50, height: 14),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Payment summary placeholder
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      SkeletonLine(width: 80, height: 14),
                      SkeletonLine(width: 50, height: 14),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      SkeletonLine(width: 100, height: 14),
                      SkeletonLine(width: 50, height: 14),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      SkeletonLine(width: 60, height: 16),
                      SkeletonLine(width: 60, height: 16),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Delivery info placeholder
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonLine(width: 120, height: 16),
                  SizedBox(height: 12),
                  SkeletonLine(width: 60, height: 12),
                  SizedBox(height: 6),
                  SkeletonLine(width: 220, height: 14),
                  SizedBox(height: 16),
                  SkeletonBox(width: double.infinity, height: 50, borderRadius: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        children: [
          // User Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const SkeletonBox(size: 80, borderRadius: 40),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonLine(width: 150, height: 20),
                      SizedBox(height: 8),
                      SkeletonLine(width: 180, height: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Menu items list placeholder
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: List.generate(6, (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: const [
                    SkeletonBox(size: 24, borderRadius: 6),
                    SizedBox(width: 16),
                    Expanded(child: SkeletonLine(width: 140, height: 16)),
                    Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                  ],
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}

class MapTrackingSkeleton extends StatelessWidget {
  const MapTrackingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Stack(
        children: [
          // Map placeholder
          const SkeletonBox(width: double.infinity, height: double.infinity, borderRadius: 0),
          // Floating Back Button
          Positioned(
            top: 40,
            left: 16,
            child: const SkeletonBox(size: 40, borderRadius: 20),
          ),
          // Bottom ETA Panel Mock
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SkeletonBox(size: 50, borderRadius: 25),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            SkeletonLine(width: 120, height: 18),
                            SizedBox(height: 6),
                            SkeletonLine(width: 180, height: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const SkeletonLine(width: 180, height: 14),
                  const SizedBox(height: 6),
                  const SkeletonLine(width: 250, height: 14),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Expanded(child: SkeletonBox(height: 50, borderRadius: 12)),
                      SizedBox(width: 12),
                      SkeletonBox(size: 50, borderRadius: 25),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminDashboardSkeleton extends StatelessWidget {
  const AdminDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grid of stats card placeholders
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          SkeletonLine(width: 100, height: 14),
                          SkeletonBox(size: 20, borderRadius: 4),
                        ],
                      ),
                      const SkeletonLine(width: 60, height: 22),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            // Split rows skeleton
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SkeletonLine(width: 120, height: 18),
                        const SizedBox(height: 24),
                        ...List.generate(5, (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  SkeletonLine(width: 180, height: 14),
                                  SizedBox(height: 6),
                                  SkeletonLine(width: 120, height: 12),
                                ],
                              ),
                              const SkeletonLine(width: 50, height: 14),
                            ],
                          ),
                        )),
                      ],
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
