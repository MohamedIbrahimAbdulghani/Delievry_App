import 'package:equatable/equatable.dart';

class BannerEntity extends Equatable {
  final String id;
  final String imageUrl;
  final String? title;
  final String? description;

  const BannerEntity({
    required this.id,
    required this.imageUrl,
    this.title,
    this.description,
  });

  @override
  List<Object?> get props => [id, imageUrl, title, description];
}
