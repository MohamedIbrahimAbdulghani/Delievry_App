import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String userName;
  final String? userImageUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const ReviewEntity({
    required this.id,
    required this.userName,
    this.userImageUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userName, userImageUrl, rating, comment, createdAt];
}
