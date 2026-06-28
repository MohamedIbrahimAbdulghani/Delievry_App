import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart' as intl;

class RestaurantEntity extends Equatable {
  final int id;
  final String _name;
  final String? nameAr;
  final String? nameEn;
  final String slug;
  final String _city;
  final String? cityAr;
  final String? cityEn;
  final String _address;
  final String? addressAr;
  final String? addressEn;
  final String phone;
  final double deliveryFee;
  final bool isActive;
  final String? imageUrl;
  final bool isFavorite;
  final double rating;
  final int totalReviews;

  const RestaurantEntity({
    required this.id,
    required String name,
    this.nameAr,
    this.nameEn,
    required this.slug,
    required String city,
    this.cityAr,
    this.cityEn,
    required String address,
    this.addressAr,
    this.addressEn,
    required this.phone,
    required this.deliveryFee,
    required this.isActive,
    this.imageUrl,
    this.isFavorite = false,
    this.rating = 4.5,
    this.totalReviews = 0,
  })  : _name = name,
        _city = city,
        _address = address;

  String get name {
    final locale = intl.Intl.getCurrentLocale().split('_').first;
    final val = locale == 'ar' ? nameAr : nameEn;
    if (val != null && val.trim().isNotEmpty) {
      return val;
    }
    if (_name.trim().isNotEmpty) {
      final isAr = locale == 'ar';
      final isRawAscii = RegExp(r'^[\x00-\x7F]*$').hasMatch(_name);
      if (isAr && isRawAscii) {
        return 'مطعم غير مسمى';
      }
      return _name;
    }
    return locale == 'ar' ? 'مطعم غير مسمى' : 'Unnamed Restaurant';
  }

  String get city {
    final locale = intl.Intl.getCurrentLocale().split('_').first;
    final val = locale == 'ar' ? cityAr : cityEn;
    if (val != null && val.trim().isNotEmpty) {
      return val;
    }
    if (_city.trim().isNotEmpty) {
      final isAr = locale == 'ar';
      final isRawAscii = RegExp(r'^[\x00-\x7F]*$').hasMatch(_city);
      if (isAr && isRawAscii) {
        return 'مدينة غير محددة';
      }
      return _city;
    }
    return locale == 'ar' ? 'مدينة غير محددة' : 'Unknown City';
  }

  String get address {
    final locale = intl.Intl.getCurrentLocale().split('_').first;
    final val = locale == 'ar' ? addressAr : addressEn;
    if (val != null && val.trim().isNotEmpty) {
      return val;
    }
    if (_address.trim().isNotEmpty) {
      final isAr = locale == 'ar';
      final isRawAscii = RegExp(r'^[\x00-\x7F]*$').hasMatch(_address);
      if (isAr && isRawAscii) {
        return 'عنوان غير محدد';
      }
      return _address;
    }
    return locale == 'ar' ? 'عنوان غير محدد' : 'Unknown Address';
  }

  RestaurantEntity copyWith({
    int? id,
    String? name,
    String? nameAr,
    String? nameEn,
    String? slug,
    String? city,
    String? cityAr,
    String? cityEn,
    String? address,
    String? addressAr,
    String? addressEn,
    String? phone,
    double? deliveryFee,
    bool? isActive,
    String? imageUrl,
    bool? isFavorite,
    double? rating,
    int? totalReviews,
  }) {
    return RestaurantEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      slug: slug ?? this.slug,
      city: city ?? this.city,
      cityAr: cityAr ?? this.cityAr,
      cityEn: cityEn ?? this.cityEn,
      address: address ?? this.address,
      addressAr: addressAr ?? this.addressAr,
      addressEn: addressEn ?? this.addressEn,
      phone: phone ?? this.phone,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
    );
  }

  @override
  List<Object?> get props => [
        id,
        _name,
        nameAr,
        nameEn,
        slug,
        _city,
        cityAr,
        cityEn,
        _address,
        addressAr,
        addressEn,
        phone,
        deliveryFee,
        isActive,
        imageUrl,
        isFavorite,
        rating,
        totalReviews,
      ];
}
