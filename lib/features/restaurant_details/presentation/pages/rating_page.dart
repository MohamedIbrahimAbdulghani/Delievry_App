import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_toastr.dart';
import '../../../../di/injection_container.dart';
import 'package:delievry_app/l10n/app_localizations.dart';
import '../../../notifications/presentation/bloc/notifications_bloc.dart';
import '../../../notifications/presentation/bloc/notifications_event.dart';
import '../../../notifications/presentation/bloc/notifications_state.dart';

class RatingPage extends StatefulWidget {
  final int orderId;
  final int? restaurantId;
  final int? notificationId;

  const RatingPage({
    super.key,
    required this.orderId,
    this.restaurantId,
    this.notificationId,
  });

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> with SingleTickerProviderStateMixin {
  late NotificationsBloc _bloc;
  final _commentController = TextEditingController();
  double _selectedRating = 5.0;
  late AnimationController _successAnimController;
  late Animation<double> _scaleAnimation;
  bool _showSuccessOverlay = false;

  @override
  void initState() {
    super.initState();
    _bloc = sl<NotificationsBloc>();
    _successAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _successAnimController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _successAnimController.dispose();
    super.dispose();
  }

  void _submitRating() {
    _bloc.add(SubmitNotificationRating(
      orderId: widget.orderId,
      restaurantId: widget.restaurantId ?? 0,
      rating: _selectedRating,
      comment: _commentController.text.trim(),
      notificationId: widget.notificationId ?? 0,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<NotificationsBloc, NotificationsState>(
        listener: (context, state) {
          if (state is RatingSuccess) {
            setState(() {
              _showSuccessOverlay = true;
            });
            final router = GoRouter.of(context);
            _successAnimController.forward().then((_) {
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  router.pop(true); // Return success to reload notifications list
                }
              });
            });
          } else if (state is NotificationsError) {
            context.showErrorToast(
              title: 'Rating Error',
              message: state.message,
            );
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              SafeArea(
                child: CustomScrollView(
                  slivers: [
                    // Premium custom back-button header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => context.pop(),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).shadowColor.withAlpha(13),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                ),
                                child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Theme.of(context).colorScheme.onSurface),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Share Your Experience',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            const Spacer(),
                            const SizedBox(width: 38), // placeholder to center text
                          ],
                        ),
                      ),
                    ),
                    
                    // Main Content
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 16),
                            // Delivery bike / thank you icon
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(20),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.thumb_up_alt_outlined,
                                  size: 64,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              AppLocalizations.of(context)?.howWasYourOrder ?? 'How was your order?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)?.feedbackHelpsImprove ?? 'Your feedback helps us and the restaurant improve your next dining experience.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // Golden Star selector card
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).shadowColor.withAlpha(8),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  )
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)?.ratingStars(_selectedRating.toInt()) ?? 'Rating: ${_selectedRating.toInt()} / 5 Stars',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(5, (index) {
                                      final starValue = index + 1.0;
                                      final isSelected = _selectedRating >= starValue;
                                      return AnimatedScale(
                                        scale: isSelected ? 1.1 : 1.0,
                                        duration: const Duration(milliseconds: 150),
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _selectedRating = starValue;
                                            });
                                          },
                                          icon: Icon(
                                            isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                                            color: isSelected ? Colors.amber : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                                            size: 44,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Comment field card
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).shadowColor.withAlpha(8),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)?.writeReviewOptional ?? 'Write a Review (Optional)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _commentController,
                                    maxLines: 4,
                                    style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                                    decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context)?.shareExperience ?? 'Share details of your experience...',
                                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                                      contentPadding: const EdgeInsets.all(16),
                                      filled: true,
                                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            const SizedBox(height: 32),

                            // Submit Button
                            BlocBuilder<NotificationsBloc, NotificationsState>(
                              builder: (context, state) {
                                final isLoading = state is RatingSubmitting;
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: const LinearGradient(
                                      colors: [AppColors.primary, Color(0xFFFF8A65)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withAlpha(76),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      )
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _submitRating,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Submit Feedback',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontFamily: 'Outfit',
                                            ),
                                          ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Animated Success Overlay
              if (_showSuccessOverlay)
                Container(
                  color: Colors.black.withAlpha(178),
                  child: Center(
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 54,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Thank You!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your review has been submitted successfully.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
