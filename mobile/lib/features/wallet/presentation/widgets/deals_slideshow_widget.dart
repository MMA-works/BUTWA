import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/core/network/api_client.dart';
import 'package:batwa_wallet/features/bills/presentation/screens/bills_hub_screen.dart';
import 'package:batwa_wallet/features/qr/presentation/screens/qr_scanner_screen.dart';
import 'package:batwa_wallet/features/cards/presentation/screens/cards_screen.dart';

/// 🌟 Model representing an active promotional deal / discount
class DealItem {
  final String id;
  final String tag;
  final String title;
  final String subTitle;
  final int discountPercent;
  final String voucherCode;
  final String type; // 'FOOD', 'UTILITY', 'SHOPPING'
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color textColor;
  final IconData icon;
  final String expiryText;
  final String terms;

  const DealItem({
    required this.id,
    required this.tag,
    required this.title,
    required this.subTitle,
    required this.discountPercent,
    required this.voucherCode,
    required this.type,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.textColor,
    required this.icon,
    required this.expiryText,
    required this.terms,
  });
}

/// 🌟 Dynamic Auto-Rotating Deals & Discounts Slideshow (2-3s interval)
class DealsSlideshowWidget extends StatefulWidget {
  final VoidCallback? onSeeAll;

  const DealsSlideshowWidget({
    super.key,
    this.onSeeAll,
  });

  @override
  State<DealsSlideshowWidget> createState() => _DealsSlideshowWidgetState();
}

class _DealsSlideshowWidgetState extends State<DealsSlideshowWidget> {
  late final PageController _pageController;
  Timer? _slideshowTimer;
  int _currentPage = 0;

  // 3 Signature Batwa Deals matching the official brand palette
  final List<DealItem> _deals = const [
    // 🟡 Deal 1: Food & Dining (Signature Forest Green & Brand Yellow)
    DealItem(
      id: 'deal-food-40',
      tag: '🔥 HOT DEAL • FOODPANDA',
      title: 'Flat 40% OFF on Food Orders',
      subTitle: 'Order on Foodpanda via Batwa & get instant Rs 350 cashback',
      discountPercent: 40,
      voucherCode: 'BATWAFOOD40',
      type: 'FOOD',
      primaryColor: Color(0xFF031E14),
      secondaryColor: Color(0xFF073826),
      accentColor: Color(0xFFF3D602),
      textColor: Colors.white,
      icon: Icons.fastfood_rounded,
      expiryText: 'Ends in 2 days',
      terms: 'Valid on food orders above Rs 700 paid via Batwa QR or Virtual Card.',
    ),

    // ⚡ Deal 2: Electricity & Utility Bills (Signature Brand Yellow & Dark Forest)
    DealItem(
      id: 'deal-bill-25',
      tag: '⚡ SUPER CASHBACK • BILLS',
      title: '25% Cashback on Electric Bills',
      subTitle: 'Zero fee on K-Electric, LESCO, IESCO & SNGPL with Batwa Pay',
      discountPercent: 25,
      voucherCode: 'POWERFREE25',
      type: 'UTILITY',
      primaryColor: Color(0xFFF3D602),
      secondaryColor: Color(0xFFE5B800),
      accentColor: Color(0xFF031E14),
      textColor: Color(0xFF031E14),
      icon: Icons.bolt_rounded,
      expiryText: 'Valid this week',
      terms: 'Applicable once per user on any electricity or gas bill payment.',
    ),

    // 🛍️ Deal 3: Mega Shopping & Brands (Signature Emerald & Cyan Teal)
    DealItem(
      id: 'deal-shop-35',
      tag: '🛍️ MEGA SAVINGS • SHOPPING',
      title: 'Up to 35% OFF on Top Brands',
      subTitle: 'Discounts on Daraz, Khaadi, Outfitters & Tech via Virtual Card',
      discountPercent: 35,
      voucherCode: 'BATWASHOP35',
      type: 'SHOPPING',
      primaryColor: Color(0xFF04281B),
      secondaryColor: Color(0xFF0A4430),
      accentColor: Color(0xFF00D2D3),
      textColor: Colors.white,
      icon: Icons.shopping_bag_rounded,
      expiryText: 'Limited time offer',
      terms: 'Avail discount instantly on checkout with your Batwa Visa Virtual Card.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlideTimer();
    _tryFetchBackendPromotions();
  }

  void _startAutoSlideTimer() {
    _slideshowTimer?.cancel();
    _slideshowTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _deals.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  Future<void> _tryFetchBackendPromotions() async {
    try {
      final response = await ApiClient().client.get('/promotions/active');
      if (response.statusCode == 200 && response.data != null) {
        // Backend promotions active
      }
    } catch (_) {
      // Graceful fallback to signature client-side deals
    }
  }

  @override
  void dispose() {
    _slideshowTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _handleDealTap(DealItem deal) {
    HapticFeedback.lightImpact();
    _showDealModalSheet(context, deal);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with Fire icon & 'Special Deals'
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3D602).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.local_fire_department_rounded,
                        size: 17,
                        color: Color(0xFFE59800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Exclusive Deals & Offers',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),

              // Auto-play pulse badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.35),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 3,
                      backgroundColor: Color(0xFF10B981),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Live Deals',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 🌟 Rotating Slideshow Carousel Container
          SizedBox(
            height: 154,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification) {
                  _slideshowTimer?.cancel();
                } else if (notification is ScrollEndNotification) {
                  _startAutoSlideTimer();
                }
                return false;
              },
              child: PageView.builder(
                controller: _pageController,
                itemCount: _deals.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final deal = _deals[index];
                  return _buildDealCard(deal);
                },
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 🌟 Dots Indicator (3 dots: active is elongated pill in Brand Yellow)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_deals.length, (index) {
              final isCurrent = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOutCubic,
                width: isCurrent ? 20 : 6,
                height: 5,
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? const Color(0xFFF3D602)
                      : (isDark ? Colors.white24 : Colors.black12),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // 🌟 Single Deal Banner Card
  Widget _buildDealCard(DealItem deal) {
    return GestureDetector(
      onTap: () => _handleDealTap(deal),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              deal.primaryColor,
              deal.secondaryColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: deal.primaryColor.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Watermark Icon in background
            Positioned(
              right: -10,
              bottom: -10,
              child: Opacity(
                opacity: 0.12,
                child: Icon(
                  deal.icon,
                  size: 96,
                  color: deal.textColor,
                ),
              ),
            ),

            // Content Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Tag & Expiry
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: deal.accentColor.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: deal.accentColor.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        deal.tag,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: deal.accentColor,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),

                    // Expiry Pill
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 11,
                          color: deal.textColor.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          deal.expiryText,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: deal.textColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Title & Subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deal.title,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        color: deal.textColor,
                        letterSpacing: -0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      deal.subTitle,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: deal.textColor.withValues(alpha: 0.82),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),

                // Bottom Row: Voucher Code & Claim Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Voucher Code Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: deal.accentColor.withValues(alpha: 0.4),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.confirmation_number_outlined,
                            size: 11,
                            color: deal.accentColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            deal.voucherCode,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: deal.accentColor,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Claim Button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                      decoration: BoxDecoration(
                        color: deal.accentColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: deal.accentColor.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Claim Deal',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: deal.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 11,
                            color: deal.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🌟 Interactive Deal Details & Voucher Claim Modal Sheet
  void _showDealModalSheet(BuildContext context, DealItem deal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Header Row
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [deal.primaryColor, deal.secondaryColor],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(deal.icon, color: deal.accentColor, size: 24),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${deal.discountPercent}% Instant Discount',
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          deal.tag,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE59800),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                deal.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                deal.subTitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 18),

              // Voucher Code Container with 1-tap Copy
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3D602).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFF3D602).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Voucher Promo Code',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          deal.voucherCode,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: Color(0xFF031E14),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: deal.voucherCode));
                        HapticFeedback.mediumImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Colors.black, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Promo code ${deal.voucherCode} copied!',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFFF3D602),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 14),
                      label: const Text('Copy'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF031E14),
                        foregroundColor: const Color(0xFFF3D602),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Terms snippet
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 13, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      deal.terms,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Colors.grey,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Direct Action CTA Button based on deal type
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (deal.type == 'UTILITY') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const BillsHubScreen()),
                      );
                    } else if (deal.type == 'FOOD') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const QrScannerScreen()),
                      );
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CardsScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3D602),
                    foregroundColor: const Color(0xFF031E14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    deal.type == 'UTILITY'
                        ? 'Pay Utility Bill Now'
                        : (deal.type == 'FOOD' ? 'Scan & Pay at Merchant' : 'View Virtual Card Details'),
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
