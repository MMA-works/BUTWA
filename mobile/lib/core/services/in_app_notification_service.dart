import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InAppNotificationService {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  /// Shows a luxury top-sliding neo-banking heads-up notification banner
  static void showNotification(
    BuildContext context, {
    required String title,
    required String message,
    required String type,
    double? amount,
    VoidCallback? onTap,
  }) {
    try {
      // Dismiss any existing notification banner immediately
      _dismissTimer?.cancel();
      _currentEntry?.remove();
      _currentEntry = null;

      // Heavy haptic feedback for real-world banking feel
      HapticFeedback.heavyImpact();

      final overlay = Overlay.maybeOf(context, rootOverlay: true);
      if (overlay == null) return;

      late OverlayEntry entry;
      entry = OverlayEntry(
        builder: (ctx) => _NotificationBannerWidget(
          title: title,
          message: message,
          type: type,
          amount: amount,
          onDismiss: () {
            _dismissTimer?.cancel();
            if (_currentEntry == entry) {
              entry.remove();
              _currentEntry = null;
            }
          },
          onTap: () {
            _dismissTimer?.cancel();
            if (_currentEntry == entry) {
              entry.remove();
              _currentEntry = null;
            }
            if (onTap != null) {
              onTap();
            }
          },
        ),
      );

      _currentEntry = entry;
      overlay.insert(entry);

      // Auto dismiss after 4.5 seconds
      _dismissTimer = Timer(const Duration(milliseconds: 4500), () {
        if (_currentEntry == entry) {
          entry.remove();
          _currentEntry = null;
        }
      });
    } catch (_) {}
  }
}

class _NotificationBannerWidget extends StatefulWidget {
  final String title;
  final String message;
  final String type;
  final double? amount;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const _NotificationBannerWidget({
    required this.title,
    required this.message,
    required this.type,
    this.amount,
    required this.onDismiss,
    required this.onTap,
  });

  @override
  State<_NotificationBannerWidget> createState() => _NotificationBannerWidgetState();
}

class _NotificationBannerWidgetState extends State<_NotificationBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;

    final isReceived = widget.type == 'TRANSFER_RECEIVED' || widget.type == 'CREDIT';
    final isSent = widget.type == 'TRANSFER_SENT' || widget.type == 'DEBIT';
    final isTopup = widget.type == 'TOPUP';

    final Color badgeColor = isReceived
        ? const Color(0xFF10B981)
        : (isSent ? const Color(0xFFF3D602) : const Color(0xFF00D1FF));

    final IconData badgeIcon = isReceived
        ? Icons.arrow_downward_rounded
        : (isSent
            ? Icons.arrow_upward_rounded
            : (isTopup ? Icons.account_balance_wallet_rounded : Icons.notifications_active_rounded));


    return Positioned(
      top: topPadding + 8,
      left: 14,
      right: 14,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: widget.onTap,
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta != null && details.primaryDelta! < -4) {
                  _handleDismiss();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF081C15),
                      Color(0xFF0D281E),
                      Color(0xFF071B14),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isReceived
                        ? const Color(0xFF10B981).withOpacity(0.5)
                        : const Color(0xFFF3D602).withOpacity(0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.45),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: badgeColor.withOpacity(0.2),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Glowing Icon Badge
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: badgeColor, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: badgeColor.withOpacity(0.35),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          badgeIcon,
                          color: badgeColor,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  "JUST NOW",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.message,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12,
                              height: 1.25,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Amount pill if provided
                    if (widget.amount != null && widget.amount! > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isReceived
                              ? const Color(0xFF10B981).withOpacity(0.18)
                              : const Color(0xFFF3D602).withOpacity(0.18),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isReceived ? const Color(0xFF10B981) : const Color(0xFFF3D602),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          "${isReceived ? '+' : '-'}Rs. ${widget.amount!.toStringAsFixed(0)}",
                          style: TextStyle(
                            color: isReceived ? const Color(0xFF10B981) : const Color(0xFFF3D602),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(width: 4),
                    // Close icon
                    GestureDetector(
                      onTap: _handleDismiss,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
