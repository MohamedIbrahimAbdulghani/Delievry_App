import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ToastrType { success, error, warning, info }

class CustomToastr {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required ToastrType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return ToastrNotificationWidget(
          title: title,
          message: message,
          type: type,
          duration: duration,
          onDismiss: () {
            entry.remove();
          },
        );
      },
    );

    overlay.insert(entry);
  }

  static void showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(context, title: title, message: message, type: ToastrType.success, duration: duration);
  }

  static void showError(
    BuildContext context, {
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(context, title: title, message: message, type: ToastrType.error, duration: duration);
  }

  static void showWarning(
    BuildContext context, {
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(context, title: title, message: message, type: ToastrType.warning, duration: duration);
  }

  static void showInfo(
    BuildContext context, {
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(context, title: title, message: message, type: ToastrType.info, duration: duration);
  }
}

class ToastrNotificationWidget extends StatefulWidget {
  final String title;
  final String message;
  final ToastrType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const ToastrNotificationWidget({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<ToastrNotificationWidget> createState() => _ToastrNotificationWidgetState();
}

class _ToastrNotificationWidgetState extends State<ToastrNotificationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      reverseDuration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInQuint,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    _animationController.forward();

    // Auto-dismiss timer
    Future.delayed(widget.duration, () {
      if (mounted && !_isDismissed) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (_isDismissed) return;
    setState(() {
      _isDismissed = true;
    });
    _animationController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  Color _getTypeColor() {
    switch (widget.type) {
      case ToastrType.success:
        return const Color(0xFF10B981); // Emerald Green
      case ToastrType.error:
        return AppColors.error;
      case ToastrType.warning:
        return const Color(0xFFFBBF24); // Amber Warning
      case ToastrType.info:
        return AppColors.primary;
    }
  }

  IconData _getTypeIcon() {
    switch (widget.type) {
      case ToastrType.success:
        return Icons.check_circle_rounded;
      case ToastrType.error:
        return Icons.error_rounded;
      case ToastrType.warning:
        return Icons.warning_rounded;
      case ToastrType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor();

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 450),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: typeColor.withOpacity(0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: typeColor.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left color indicator bar
                          Container(
                            width: 6,
                            color: typeColor,
                          ),
                          const SizedBox(width: 16),
                          // Icon
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: typeColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getTypeIcon(),
                                color: typeColor,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Content (Title & Message)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: AppColors.onBackground,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.message,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Dismiss button
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: _dismiss,
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
