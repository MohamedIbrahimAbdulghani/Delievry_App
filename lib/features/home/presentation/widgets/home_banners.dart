import 'package:flutter/material.dart';
import '../../domain/entities/banner_entity.dart';
import 'package:delievry_app/l10n/app_localizations.dart';

class HomeBanners extends StatelessWidget {
  final List<BannerEntity> banners;

  const HomeBanners({super.key, required this.banners});

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 180,
      child: PageView.builder(
        itemCount: banners.length,
        itemBuilder: (context, index) {
          final banner = banners[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(banner.imageUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withAlpha(77),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (banner.title != null)
                    Text(
                      _getBannerTitle(context, banner.title!),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (banner.description != null)
                    Text(
                      _getBannerDescription(context, banner.description!),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  String _getBannerTitle(BuildContext context, String title) {
    if (Localizations.localeOf(context).languageCode == 'ar') {
      if (title.toLowerCase() == 'special offer') return AppLocalizations.of(context)?.specialOffer ?? 'عرض خاص';
      if (title.toLowerCase() == 'new pizza') return 'بيتزا جديدة';
    }
    return title;
  }

  String _getBannerDescription(BuildContext context, String desc) {
    if (Localizations.localeOf(context).languageCode == 'ar') {
      if (desc.toLowerCase() == 'get 50% off on your first order') return AppLocalizations.of(context)?.get50Off ?? 'احصل على خصم 50% على طلبك الأول';
      if (desc.toLowerCase() == 'try our new italian pizza') return 'جرب البيتزا الإيطالية الجديدة';
    }
    return desc;
  }
}
