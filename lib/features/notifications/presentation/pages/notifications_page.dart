import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/shimmer_skeletons.dart';
import '../../../../di/injection_container.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';
import '../../domain/entities/notification_entity.dart';
import 'package:delievry_app/l10n/app_localizations.dart';

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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          title: Text(
            AppLocalizations.of(context)?.notifications ?? 'Notifications',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
          ),
          iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
          actions: [
            BlocBuilder<NotificationsBloc, NotificationsState>(
              bloc: _bloc,
              builder: (context, state) {
                if (state is NotificationsLoaded && state.notifications.any((n) => !n.isRead)) {
                  return TextButton(
                    onPressed: () {
                      _bloc.add(MarkAllAsReadEvent());
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text(
                      'Mark All as Read',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, state) {
            if (state is NotificationsLoading) {
              return const ListSkeleton(itemCount: 5, isLeadingCircle: true, height: 100);
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
          Text(
            AppLocalizations.of(context)?.noNotifications ?? 'No notifications yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)?.youHaveNoNotifications ?? 'We will notify you when something happens.',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  String _getTranslatedTitle(BuildContext context, String title) {
    if (title == 'Order Delivered') return AppLocalizations.of(context)?.orderDelivered ?? title;
    if (title == 'Order Submitted') return AppLocalizations.of(context)?.orderSubmitted ?? title;
    if (title == 'Order Cancelled') return AppLocalizations.of(context)?.orderCancelled ?? title;
    return title;
  }

  String _getTranslatedBody(BuildContext context, String body) {
    if (body.contains('Your order has arrived successfully')) {
      return AppLocalizations.of(context)?.notificationDeliveredBody ?? body;
    }
    return body;
  }

  Widget _buildNotificationCard(NotificationEntity notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? Theme.of(context).colorScheme.surface : AppColors.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Theme.of(context).shadowColor.withOpacity(0.04),
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
            if (notification.orderId != null && !notification.isRated) {
              context.push(
                '/rate-order/${notification.orderId}',
                extra: {
                  'restaurantId': notification.restaurantId,
                  'notificationId': notification.id,
                },
              ).then((value) {
                if (value == true) {
                  _bloc.add(FetchNotifications());
                }
              });
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
                              _getTranslatedTitle(context, notification.title),
                              style: TextStyle(
                                fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface,
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
                        _getTranslatedBody(context, notification.body),
                        style: TextStyle(
                          fontSize: 14,
                          color: notification.isRead ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6) : Theme.of(context).colorScheme.onSurface,
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
                      if (notification.orderId != null && !notification.isRated) ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            context.push(
                              '/rate-order/${notification.orderId}',
                              extra: {
                                'restaurantId': notification.restaurantId,
                                'notificationId': notification.id,
                              },
                            ).then((value) {
                              if (value == true) {
                                _bloc.add(FetchNotifications());
                              }
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          icon: const Icon(Icons.star_outline, size: 18),
                          label: Text(
                            AppLocalizations.of(context)?.rateRestaurant ?? 'Rate Restaurant',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ] else if (notification.orderId != null && notification.isRated) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              AppLocalizations.of(context)?.ratedSuccessfully ?? 'Rated successfully',
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

}
