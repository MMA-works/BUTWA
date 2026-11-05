import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';

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
  static const Color _darkGreenEnd = Color(0xFF084E35);
  static const Color _accentEmerald = Color(0xFF10B981);
  static const Color _darkNavy = Color(0xFF1B1D28);

  final List<Map<String, dynamic>> _notifications = [
    // --- TODAY ---
    {
      'id': 'notif_1',
      'actor': 'Zainab Khan',
      'action': 'sent you PKR 5,000.00 via Raast Instant Direct',
      'tag': 'RAAST',
      'amount': '+PKR 5,000.00',
      'isCredit': true,
      'time': '1h ago',
      'dateGroup': 'TODAY',
      'isDirect': true,
      'isRead': false,
      'avatarInitials': 'ZK',
      'avatarColor': const Color(0xFF042B1D),
      'badgeIcon': Icons.alternate_email_rounded,
      'badgeColor': _brandYellow,
      'badgeIconColor': _darkNavy,
    },
    {
      'id': 'notif_2',
      'actor': 'Careem Rewards',
      'action': 'unlocked a new 30% Cashback Goal on your Virtual Card',
      'tag': 'GOAL',
      'amount': '30% CASHBACK',
      'isCredit': null,
      'time': '4h ago',
      'dateGroup': 'TODAY',
      'isDirect': false,
      'isRead': false,
      'avatarInitials': 'CR',
      'avatarColor': const Color(0xFF063C28),
      'badgeIcon': Icons.auto_awesome_rounded,
      'badgeColor': _brandYellow,
      'badgeIconColor': _darkNavy,
    },
    {
      'id': 'notif_3',
      'actor': 'Daniel Mayers',
      'action': 'settled a split request for Dinner Bill #1302',
      'tag': 'SPLIT PO#1302',
      'amount': '+PKR 1,250.00',
      'isCredit': true,
      'time': '08:42',
      'dateGroup': 'TODAY',
      'isDirect': true,
      'isRead': true,
      'avatarInitials': 'DM',
      'avatarColor': const Color(0xFF084E35),
      'badgeIcon': Icons.check_rounded,
      'badgeColor': _accentEmerald,
      'badgeIconColor': Colors.white,
    },

    // --- YESTERDAY ---
    {
      'id': 'notif_4',
      'actor': 'Spotify Premium',
      'action': 'debited PKR 15.00 for auto-renewal subscription rule',
      'tag': 'AUTO-DEBIT',
      'amount': '-PKR 15.00',
      'isCredit': false,
      'time': 'Yesterday • 18:21',
      'dateGroup': 'YESTERDAY',
      'isDirect': true,
      'isRead': true,
      'avatarInitials': 'SP',
      'avatarColor': const Color(0xFF042B1D),
      'badgeIcon': Icons.arrow_upward_rounded,
      'badgeColor': _brandYellow,
      'badgeIconColor': _darkNavy,
    },
    {
      'id': 'notif_5',
      'actor': 'Security Guard',
      'action': 'verified new Web Portal sign-in from Islamabad (Windows 11)',
      'tag': 'SECURITY',
      'amount': 'TRUSTED',
      'isCredit': null,
      'time': 'Yesterday • 12:00',
      'dateGroup': 'YESTERDAY',
      'isDirect': true,
      'isRead': true,
      'avatarInitials': 'SG',
      'avatarColor': const Color(0xFF063C28),
      'badgeIcon': Icons.shield_rounded,
      'badgeColor': _accentEmerald,
      'badgeIconColor': Colors.white,
    },
    {
      'id': 'notif_6',
      'actor': 'K-Electric Bill Hub',
      'action': 'Zero Fee electricity bill campaign is live this week',
      'tag': 'BILL HUB',
      'amount': '0% FEE',
      'isCredit': null,
      'time': 'Yesterday • 09:15',
      'dateGroup': 'YESTERDAY',
      'isDirect': false,
      'isRead': true,
      'avatarInitials': 'KE',
      'avatarColor': const Color(0xFF084E35),
      'badgeIcon': Icons.bolt_rounded,
      'badgeColor': _brandYellow,
      'badgeIconColor': _darkNavy,
    },

    // --- EARLIER ---
    {
      'id': 'notif_7',
      'actor': 'Meezan Bank Top-Up',
      'action': 'loaded PKR 20,000.00 into primary wallet account',
      'tag': '1LINK LOAD',
      'amount': '+PKR 20,000.00',
      'isCredit': true,
      'time': '3 days ago',
      'dateGroup': 'EARLIER',
      'isDirect': true,
      'isRead': true,
      'avatarInitials': 'MB',
      'avatarColor': const Color(0xFF042B1D),
      'badgeIcon': Icons.arrow_downward_rounded,
      'badgeColor': _accentEmerald,
      'badgeIconColor': Colors.white,
    },
    {
      'id': 'notif_8',
      'actor': 'Hamza Qureshi',
      'action': 'invited you to Split Vault "Murree Trip 2026"',
      'tag': 'FINANCE TEAM',
      'amount': 'INVITE',
      'isCredit': null,
      'time': '4 days ago',
      'dateGroup': 'EARLIER',
      'isDirect': true,
      'isRead': true,
      'avatarInitials': 'HQ',
      'avatarColor': const Color(0xFF063C28),
      'badgeIcon': Icons.add_rounded,
      'badgeColor': _brandYellow,
      'badgeIconColor': _darkNavy,
    },
  ];

  void _markAllAsRead() {
    HapticFeedback.lightImpact();
    setState(() {
      for (var n in _notifications) {
        n['isRead'] = true;
      }
    });
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
                // 🟢 TIER 2: SIGNATURE DARK GREEN BOX HERO CARD
                // =========================================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          _darkGreenStart,
                          _darkGreenMid,
                          _darkGreenEnd,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _accentEmerald.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _darkGreenStart.withValues(alpha: 0.4),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // 3D Illustrated Bell with subtle halo
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                            border: Border.all(
                              color: _brandYellow.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/notification_3d_bell.png',
                              width: 44,
                              height: 44,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.notifications_active_rounded,
                                color: _brandYellow,
                                size: 30,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        // Center Status Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: _brandYellow,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'REAL-TIME ACTIVITY HUB',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: _brandYellow,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                unreadCount > 0
                                    ? '$unreadCount New Pending Alerts'
                                    : 'All Caught Up & Verified',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Raast instant direct & biometric audit stream',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Mini Verified Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: _brandYellow,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: _brandYellow.withValues(alpha: 0.35),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: _darkNavy,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

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
