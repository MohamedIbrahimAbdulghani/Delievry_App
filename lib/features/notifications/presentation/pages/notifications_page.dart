import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../di/injection_container.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late NotificationsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<NotificationsBloc>()..add(FetchNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _bloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Notifications',
            style: TextStyle(color: AppColors.onBackground, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: AppColors.onBackground),
        ),
        body: BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, state) {
            if (state is NotificationsLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            } else if (state is NotificationsLoaded) {
              if (state.notifications.isEmpty) {
                return _buildEmptyState();
              }
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  _bloc.add(FetchNotifications());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = state.notifications[index];
                    return _buildNotificationCard(notification);
                  },
                ),
              );
            } else if (state is NotificationsError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'No notifications yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onBackground),
          ),
          const SizedBox(height: 8),
          Text(
            'We will notify you when something happens.',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationEntity notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : AppColors.primary.withAlpha(8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: notification.isRead ? Colors.transparent : AppColors.primary.withAlpha(30),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (!notification.isRead) {
              _bloc.add(MarkAsReadEvent(notification.id));
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: notification.isRead ? Colors.grey[100] : AppColors.primary.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    notification.title == 'Order Arrived'
                        ? Icons.sports_motorsports_outlined
                        : Icons.notifications_active_outlined,
                    color: notification.isRead ? Colors.grey[600] : AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.onBackground,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontSize: 14,
                          color: notification.isRead ? AppColors.textSecondary : AppColors.onBackground,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${notification.createdAt.hour.toString().padLeft(2, '0')}:${notification.createdAt.minute.toString().padLeft(2, '0')} • ${notification.createdAt.day}/${notification.createdAt.month}/${notification.createdAt.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[450],
                        ),
                      ),
                      if (notification.restaurantId != null && !notification.isRated) ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => _showRatingBottomSheet(context, notification),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          icon: const Icon(Icons.star_outline, size: 18),
                          label: const Text(
                            'Rate Restaurant',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ] else if (notification.restaurantId != null && notification.isRated) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Rated successfully',
                              style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRatingBottomSheet(BuildContext context, NotificationEntity notification) {
    final commentController = TextEditingController();
    double selectedRating = 5.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Rate Restaurant',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.onBackground),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please rate your order experience with stars and leave a comment.',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = index + 1.0;
                        return IconButton(
                          onPressed: () {
                            setModalState(() {
                              selectedRating = starValue;
                            });
                          },
                          icon: Icon(
                            selectedRating >= starValue ? Icons.star : Icons.star_border,
                            color: selectedRating >= starValue ? Colors.amber : Colors.grey[300],
                            size: 40,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Write your comment here (optional)...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        _bloc.add(SubmitNotificationRating(
                          restaurantId: notification.restaurantId!,
                          rating: selectedRating,
                          comment: commentController.text.trim(),
                          notificationId: notification.id,
                        ));
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Submit Review',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
