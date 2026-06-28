import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart' as intl;

class MealEntity extends Equatable {
  final int id;
  final int restaurantId;
  final String _name;
  final String? nameAr;
  final String? nameEn;
  final String slug;
  final String _description;
  final String? descriptionAr;
  final String? descriptionEn;
  final double price;
  final String _category;
  final String? categoryAr;
  final String? categoryEn;
  final bool isAvailable;
  final String? imageUrl;

  const MealEntity({
    required this.id,
    required this.restaurantId,
    required String name,
    this.nameAr,
    this.nameEn,
    required this.slug,
    required String description,
    this.descriptionAr,
    this.descriptionEn,
    required this.price,
    required String category,
    this.categoryAr,
    this.categoryEn,
    required this.isAvailable,
    this.imageUrl,
  })  : _name = name,
        _description = description,
        _category = category;

  String get name {
    final locale = intl.Intl.getCurrentLocale().split('_').first;
    final val = locale == 'ar' ? nameAr : nameEn;
    if (val != null && val.trim().isNotEmpty) {
      return val;
    }
    if (_name.trim().isNotEmpty) {
      // Clean fallback: If the database value is English (default seed) and we are in Arabic, return standard placeholder
      final isAr = locale == 'ar';
      // Basic check: if it's ascii but we want arabic, it means we don't have translation!
      final isRawAscii = RegExp(r'^[\x00-\x7F]*$').hasMatch(_name);
      if (isAr && isRawAscii) {
        return 'اسم غير متوفر';
      }
      return _name;
    }
    return locale == 'ar' ? 'اسم غير متوفر' : 'Name not available';
  }

  String get description {
    final locale = intl.Intl.getCurrentLocale().split('_').first;
    final val = locale == 'ar' ? descriptionAr : descriptionEn;
    if (val != null && val.trim().isNotEmpty) {
      return val;
    }
    if (_description.trim().isNotEmpty) {
      final isAr = locale == 'ar';
      final isRawAscii = RegExp(r'^[\x00-\x7F]*$').hasMatch(_description);
      if (isAr && isRawAscii) {
        return 'الوصف غير متوفر';
      }
      return _description;
    }
    return locale == 'ar' ? 'الوصف غير متوفر' : 'Description not available';
  }

  String get category {
    final locale = intl.Intl.getCurrentLocale().split('_').first;
    final val = locale == 'ar' ? categoryAr : categoryEn;
    if (val != null && val.trim().isNotEmpty) {
      return val;
    }
    if (_category.trim().isNotEmpty) {
      final isAr = locale == 'ar';
      final isRawAscii = RegExp(r'^[\x00-\x7F]*$').hasMatch(_category);
      if (isAr && isRawAscii) {
        return 'غير مصنف';
      }
      return _category;
    }
    return locale == 'ar' ? 'غير مصنف' : 'Uncategorized';
  }

  @override
  List<Object?> get props => [
        id,
        restaurantId,
        _name,
        nameAr,
        nameEn,
        slug,
        _description,
        descriptionAr,
        descriptionEn,
        price,
        _category,
        categoryAr,
        categoryEn,
        isAvailable,
        imageUrl,
      ];
}
