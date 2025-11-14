import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/utils/device_size.dart';

class NotificationHelper {
  static void showNotification(
    BuildContext context,
    String message, {
    bool isSuccess = true,
    Duration duration = const Duration(seconds: 6),
  }) {
    final overlay = Overlay.of(context);
    final backgroundColor = isSuccess ? Colors.green : Colors.red;
    final isDesktop = !context.isMobile;

    late OverlayEntry overlayEntry;

    // bikin entry overlay dengan posisi responsif
    overlayEntry = OverlayEntry(
      builder: (context) => _buildNotificationWrapper(
        context: context,
        message: message,
        backgroundColor: backgroundColor,
        duration: duration,
        isDesktop: isDesktop,
        onDismiss: () {
          if (overlayEntry.mounted) {
            overlayEntry.remove();
          }
        },
      ),
    );

    // masukin ke overlay
    overlay.insert(overlayEntry);

    // auto remove setelah durasi
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  static Widget _buildNotificationWrapper({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    required Duration duration,
    required bool isDesktop,
    required VoidCallback onDismiss,
  }) {
    if (isDesktop) {
      // Desktop: pojok kanan bawah
      return Positioned(
        bottom: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: AnimatedSlideNotification(
            message: message,
            backgroundColor: backgroundColor,
            duration: duration,
            onDismiss: onDismiss,
            isDesktop: true,
          ),
        ),
      );
    } else {
      // Mobile: atas
      return Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: AnimatedSlideNotification(
            message: message,
            backgroundColor: backgroundColor,
            duration: duration,
            onDismiss: onDismiss,
            isDesktop: false,
          ),
        ),
      );
    }
  }

  // Method untuk backward compatibility
  static void showTopNotification(
    BuildContext context,
    String message, {
    bool isSuccess = true,
    Duration duration = const Duration(seconds: 6),
  }) {
    showNotification(
      context,
      message,
      isSuccess: isSuccess,
      duration: duration,
    );
  }
}

class AnimatedSlideNotification extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Duration duration;
  final VoidCallback onDismiss;
  final bool isDesktop;

  const AnimatedSlideNotification({
    super.key,
    required this.message,
    required this.backgroundColor,
    required this.duration,
    required this.onDismiss,
    required this.isDesktop,
  });

  @override
  State<AnimatedSlideNotification> createState() =>
      _AnimatedSlideNotificationState();
}

class _AnimatedSlideNotificationState extends State<AnimatedSlideNotification>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Animasi slide berbeda untuk desktop vs mobile
    _offsetAnimation = Tween<Offset>(
      begin: widget.isDesktop
          ? const Offset(1.2, 0) // Slide dari kanan untuk desktop
          : const Offset(0, -1.2), // Slide dari atas untuk mobile
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _slideController.forward();
    _fadeController.forward();

    // auto dismiss dengan animasi keluar yang lebih smooth
    Future.delayed(widget.duration - const Duration(milliseconds: 400), () {
      if (mounted && !_isDismissed) {
        _dismissNotification();
      }
    });
  }

  void _dismissNotification() {
    if (_isDismissed) return;
    _isDismissed = true;

    _fadeController.reverse().then((_) {
      if (mounted) {
        _slideController.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTap: _dismissNotification,
            onPanUpdate: (details) {
              // Swipe untuk dismiss - berbeda untuk desktop vs mobile
              if (widget.isDesktop) {
                // Desktop: swipe ke kanan untuk dismiss
                if (details.delta.dx > 5) {
                  _dismissNotification();
                }
              } else {
                // Mobile: swipe ke atas untuk dismiss
                if (details.delta.dy < -5) {
                  _dismissNotification();
                }
              }
            },
            child: Container(
              constraints: BoxConstraints(
                maxWidth: widget.isDesktop ? 350 : double.infinity,
                minWidth: widget.isDesktop ? 300 : 0,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.backgroundColor,
                    widget.backgroundColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.backgroundColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize:
                    widget.isDesktop ? MainAxisSize.min : MainAxisSize.max,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.backgroundColor == Colors.green
                          ? Icons.check_circle_outline_rounded
                          : Icons.error_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                      maxLines: widget.isDesktop ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.close_rounded,
                    color: Colors.white.withOpacity(0.8),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
