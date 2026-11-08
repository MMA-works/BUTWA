import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/core/network/api_client.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Active Tab: 0 = 'Direct Activity', 1 = 'Overall Updates'
  int _selectedTabIndex = 0;

  // Signature Theme Colors
  static const Color _brandYellow = Color(0xFFF3D602);
  static const Color _darkGreenStart = Color(0xFF042B1D);
  static const Color _darkGreenMid = Color(0xFF063C28);
  static const Color _accentEmerald = Color(0xFF10B981);
  static const Color _darkNavy = Color(0xFF1B1D28);

  List<Map<String, dynamic>> _notifications = [
    {
      'id': 'system_welcome',
      'actor': 'Batwa Security Center',
      'action': 'Protected by SBP licensed 256-bit AES encryption & Biometric Vault.',
      'tag': 'VERIFIED',
      'amount': 'SBP EMI',
      'isCredit': null,
      'time': 'Just now',
      'dateGroup': 'TODAY',
      'isDirect': true,
      'isRead': true,
      'avatarInitials': 'BW',
      'avatarColor': const Color(0xFF042B1D),
      'badgeIcon': Icons.verified_user_rounded,
      'badgeColor': _accentEmerald,
      'badgeIconColor': Colors.white,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchBackendNotifications();
  }

  Future<void> _fetchBackendNotifications() async {
    try {
      final res = await ApiClient().client.get('/notifications');
      if (res.statusCode == 200 && res.data != null) {
        final rawList = res.data is Map ? (res.data['data'] as List? ?? []) : (res.data as List? ?? []);
        final List<Map<String, dynamic>> mapped = [];

        for (final item in rawList) {
          final id = item['id']?.toString() ?? UniqueKey().toString();
          final type = item['type']?.toString() ?? 'SYSTEM';
          final title = item['title']?.toString() ?? 'Activity Alert';
          final message = item['message']?.toString() ?? '';
          final amountNum = double.tryParse(item['amount']?.toString() ?? '');
          final isRead = item['read'] == true || item['isRead'] == true;
          final createdAtStr = item['createdAt']?.toString();
          DateTime dt = DateTime.now();
          if (createdAtStr != null) {
            dt = DateTime.tryParse(createdAtStr) ?? DateTime.now();
          }

          final now = DateTime.now();
          final diff = now.difference(dt);
          String timeStr;
          String dateGroup;

          if (diff.inMinutes < 1) {
            timeStr = 'Just now';
          } else if (diff.inMinutes < 60) {
            timeStr = '${diff.inMinutes}m ago';
          } else if (diff.inHours < 24 && dt.day == now.day) {
            timeStr = '${diff.inHours}h ago';
          } else {
            timeStr = DateFormat('MMM d • HH:mm').format(dt);
          }

          if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
            dateGroup = 'TODAY';
          } else if (now.difference(DateTime(dt.year, dt.month, dt.day)).inDays == 1) {
            dateGroup = 'YESTERDAY';
          } else {
            dateGroup = 'EARLIER';
          }

          final isReceived = type == 'TRANSFER_RECEIVED' || type == 'CREDIT';
          final isSent = type == 'TRANSFER_SENT' || type == 'DEBIT';
          final isTopup = type == 'TOPUP';
          final isBill = type == 'BILL_PAYMENT';
          final bool isCredit = isReceived || isTopup;

          String amountFormatted = '';
          if (amountNum != null && amountNum > 0) {
            amountFormatted = '${isCredit ? '+' : '-'}PKR ${amountNum.toStringAsFixed(2)}';
          } else {
            amountFormatted = type;
          }

          String actor = title;
          if (title.contains('!')) {
            actor = title.replaceAll('!', '').replaceAll('🎉', '').replaceAll('💰', '').replaceAll('💸', '').replaceAll('⚡', '').trim();
          }

          IconData badgeIcon = Icons.notifications_active_rounded;
          if (isReceived) {
            badgeIcon = Icons.arrow_downward_rounded;
          } else if (isSent) {
            badgeIcon = Icons.arrow_upward_rounded;
          } else if (isTopup) {
            badgeIcon = Icons.account_balance_wallet_rounded;
          } else if (isBill) {
            badgeIcon = Icons.receipt_long_rounded;
          }

          Color badgeColor = isCredit ? _accentEmerald : _brandYellow;
          Color badgeIconColor = isCredit ? Colors.white : _darkNavy;

          String initials = 'BW';
          if (actor.isNotEmpty) {
            final parts = actor.split(' ');
            if (parts.length >= 2) {
              initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
            } else {
              initials = actor.substring(0, actor.length >= 2 ? 2 : 1).toUpperCase();
            }
          }

          mapped.add({
            'id': id,
            'actor': actor,
            'action': message,
            'tag': isReceived ? 'RAAST' : (isTopup ? 'TOP-UP' : (isBill ? 'BILL' : 'TRANSFER')),
            'amount': amountFormatted,
            'isCredit': isCredit,
            'time': timeStr,
            'dateGroup': dateGroup,
            'isDirect': true,
            'isRead': isRead,
            'avatarInitials': initials,
            'avatarColor': const Color(0xFF042B1D),
            'badgeIcon': badgeIcon,
            'badgeColor': badgeColor,
            'badgeIconColor': badgeIconColor,
          });
        }

        if (mounted && mapped.isNotEmpty) {
          setState(() {
            _notifications = mapped;
          });
        }

        try {
          await ApiClient().client.post('/notifications/read-all');
        } catch (_) {}
      }
    } catch (_) {}
  }

  void _markAllAsRead() async {
    HapticFeedback.lightImpact();
    setState(() {
      for (var n in _notifications) {
        n['isRead'] = true;
      }
    });
    try {
      await ApiClient().client.post('/notifications/read-all');
    } catch (_) {}
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: _brandYellow, size: 20),
              SizedBox(width: 10),
              Text('All notifications marked as read!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          backgroundColor: _darkGreenStart,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: _brandYellow, width: 1),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final displayedList = _notifications.where((n) {
      if (_selectedTabIndex == 0) return n['isDirect'] == true;
      return true;
    }).toList();

    final unreadCount = displayedList.where((n) => n['isRead'] == false).length;

    // Grouping by dateGroup
    final groups = <String, List<Map<String, dynamic>>>{};
    for (var n in displayedList) {
      final g = n['dateGroup'] as String;
      groups.putIfAbsent(g, () => []).add(n);
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // =========================================================
          // 🌟 1. RADIANT BRAND YELLOW GRADIENT TOP BANNER
          // =========================================================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                          _brandYellow.withValues(alpha: 0.25),
                          _brandYellow.withValues(alpha: 0.12),
                          const Color(0xFF0C0E14).withValues(alpha: 0.0),
                        ]
                      : [
                          _brandYellow,
                          const Color(0xFFF4D916),
                          const Color(0xFFF7E248),
                          const Color(0xFFFAEE88).withValues(alpha: 0.85),
                          const Color(0xFFFCF7CA).withValues(alpha: 0.35),
                          const Color(0xFFF8F9FA).withValues(alpha: 0.0),
                        ],
                  stops: const [0.0, 0.35, 0.65, 0.82, 0.93, 1.0],
                ),
              ),
            ),
          ),

          // =========================================================
          // 📱 2. FOREGROUND CONTENT SCROLLABLE
          // =========================================================
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: _fetchBackendNotifications,
              color: _brandYellow,
              backgroundColor: _darkGreenStart,
              child: ListView(
              padding: const EdgeInsets.only(bottom: 40),
              physics: const BouncingScrollPhysics(),
              children: [
                // Top Custom Header Row
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Circular Back Button
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFECEFF2),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: _darkNavy,
                              size: 20,
                            ),
                          ),
                        ),
                      ),

                      // Screen Title + Unread Badge
                      Row(
                        children: [
                          const Text(
                            'Notifications',
                            style: TextStyle(
                              color: _darkNavy,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              letterSpacing: -0.4,
                            ),
                          ),
                          if (unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _darkNavy,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$unreadCount NEW',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: _brandYellow,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Mark All Read Button
                      GestureDetector(
                        onTap: _markAllAsRead,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFECEFF2),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.done_all_rounded,
                              color: _darkGreenStart,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // =========================================================
                // 🔘 FILTER CAPSULES (Direct Activity vs Overall Updates)
                // =========================================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: const Color(0xFFECEFF2),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildCapsuleTab(
                            title: 'Direct Activity',
                            count: _notifications.where((n) => n['isDirect'] == true).length,
                            isSelected: _selectedTabIndex == 0,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedTabIndex = 0);
                            },
                          ),
                        ),
                        Expanded(
                          child: _buildCapsuleTab(
                            title: 'Overall Updates',
                            count: _notifications.length,
                            isSelected: _selectedTabIndex == 1,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedTabIndex = 1);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),



                // =========================================================
                // ⚪ TIER 3: CRISP WHITE CARD CONTAINER FOR NOTIFICATIONS
                // =========================================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF131722) : Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: isDark ? Colors.white12 : const Color(0xFFECEFF2),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                    child: displayedList.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 36),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/notification_3d_bell.png',
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.notifications_none_rounded,
                                      size: 54,
                                      color: _brandYellow,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'No Notifications Yet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: _darkNavy,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'You are all caught up in this view.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final groupEntry in groups.entries) ...[
                                _buildDateHeader(groupEntry.key),
                                const SizedBox(height: 10),
                                for (int i = 0; i < groupEntry.value.length; i++) ...[
                                  _buildNotificationItem(groupEntry.value[i], isDark),
                                  if (i < groupEntry.value.length - 1)
                                    const Divider(
                                      height: 16,
                                      thickness: 0.8,
                                      color: Color(0xFFF0F3F6),
                                    ),
                                ],
                                const SizedBox(height: 14),
                              ],
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      ),
    );
  }

  // --- Filter Pill Tab ---
  Widget _buildCapsuleTab({
    required String title,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? _brandYellow : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _brandYellow.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? _darkNavy : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _darkNavy.withValues(alpha: 0.15)
                      : const Color(0xFFECEFF2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? _darkNavy : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Section Date Header ---
  Widget _buildDateHeader(String title) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: _brandYellow,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFECEFF2),
          ),
        ),
      ],
    );
  }

  // --- Notification Tile (Swipeable) ---
  Widget _buildNotificationItem(Map<String, dynamic> notif, bool isDark) {
    final isRead = notif['isRead'] as bool;
    final isCredit = notif['isCredit'] as bool?;

    return Dismissible(
      key: Key(notif['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
      ),
      onDismissed: (_) {
        setState(() => _notifications.removeWhere((n) => n['id'] == notif['id']));
      },
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => notif['isRead'] = true);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Circle in Signature Dark Green Box + Yellow mini badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_darkGreenStart, _darkGreenMid],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: !isRead ? _brandYellow : _accentEmerald.withValues(alpha: 0.4),
                        width: !isRead ? 1.8 : 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _darkGreenStart.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        notif['avatarInitials'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: notif['badgeColor'] as Color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Center(
                        child: Icon(
                          notif['badgeIcon'] as IconData,
                          size: 10,
                          color: notif['badgeIconColor'] as Color,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 12),

              // Title, Subtitle, Time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notif['actor'] as String,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: isRead ? FontWeight.w700 : FontWeight.w900,
                              color: _darkNavy,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          notif['time'] as String,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: !isRead ? _accentEmerald : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notif['action'] as String,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF4B5563),
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Tag Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F6F8),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFECEFF2)),
                          ),
                          child: Text(
                            notif['tag'] as String,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Amount Pill
                        if (notif['amount'] != null)
                          Text(
                            notif['amount'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: isCredit == true
                                  ? _accentEmerald
                                  : (isCredit == false ? const Color(0xFFDC2626) : _darkNavy),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Unread Yellow Indicator Dot
              if (!isRead) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    color: _brandYellow,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _brandYellow,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
