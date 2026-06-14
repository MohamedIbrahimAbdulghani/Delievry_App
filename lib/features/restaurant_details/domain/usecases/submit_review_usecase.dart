import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/restaurant_repository.dart';

class SubmitReviewUseCase {
  final RestaurantRepository repository;

  SubmitReviewUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required int orderId,
    required double rating,
    required String comment,
    int? notificationId,
  }) async {
    return await repository.submitReview(
      orderId: orderId,
      rating: rating,
      comment: comment,
      notificationId: notificationId,
    );
  }
}
