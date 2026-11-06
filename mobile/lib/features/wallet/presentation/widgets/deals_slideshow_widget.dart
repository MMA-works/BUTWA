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
  // 🌟 3 Signature Batwa Deals: ALL in Dark Green Shades with Radiant Yellow Typography
  final List<DealItem> _deals = const [
    // 🟢 Deal 1: Food & Dining (Deep Emerald Forest & Batwa Yellow)
    DealItem(
      id: 'deal-food-40',
      tag: 'FOOD',
      title: 'Flat 40% OFF on Food Orders',
      subTitle: 'Order on Foodpanda via Batwa & get instant Rs 350 cashback',
      discountPercent: 40,
      voucherCode: 'BATWAFOOD40',
      type: 'FOOD',
      primaryColor: Color(0xFF01180E),
      secondaryColor: Color(0xFF07482D),
      accentColor: Color(0xFFF3D602),
      textColor: Color(0xFFF3D602), // 🌟 Yellow font on Dark Green
      icon: Icons.fastfood_rounded,
      expiryText: 'Ends in 2 days',
      terms: 'Valid on food orders above Rs 700 paid via Batwa QR or Virtual Card.',
    ),

    // 🟢 Deal 2: Electricity & Utility Bills (Deep Pine Emerald & Batwa Yellow)
    DealItem(
      id: 'deal-bill-25',
      tag: 'UTILITY',
      title: '25% Cashback on Electric Bills',
      subTitle: 'Zero fee on K-Electric, LESCO, IESCO & SNGPL with Batwa Pay',
      discountPercent: 25,
      voucherCode: 'POWERFREE25',
      type: 'UTILITY',
      primaryColor: Color(0xFF021D12),
      secondaryColor: Color(0xFF0A5538),
      accentColor: Color(0xFFF3D602),
      textColor: Color(0xFFF3D602), // 🌟 Yellow font on Dark Green
      icon: Icons.bolt_rounded,
      expiryText: 'Valid this week',
      terms: 'Applicable once per user on any electricity or gas bill payment.',
    ),

    // 🟢 Deal 3: Mega Shopping & Brands (Deep Jade Forest & Batwa Yellow)
    DealItem(
      id: 'deal-shop-35',
      tag: 'SHOPPING',
      title: 'Up to 35% OFF on Top Brands',
      subTitle: 'Discounts on Daraz, Khaadi, Outfitters & Tech via Virtual Card',
      discountPercent: 35,
      voucherCode: 'BATWASHOP35',
      type: 'SHOPPING',
      primaryColor: Color(0xFF011A10),
      secondaryColor: Color(0xFF084E32),
      accentColor: Color(0xFFF3D602),
      textColor: Color(0xFFF3D602), // 🌟 Yellow font on Dark Green
      icon: Icons.shopping_bag_rounded,
      expiryText: 'Limited time offer',
      terms: 'Avail discount instantly on checkout with your Batwa Visa Virtual Card.',
    ),
  ];

  static const int _loopMultiplier = 10000;
  late final int _initialPage;
  late final PageController _pageController;
  Timer? _slideshowTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _initialPage = (_loopMultiplier ~/ 2) * _deals.length;
    _currentPage = _initialPage;
    _pageController = PageController(initialPage: _initialPage);
    _startAutoSlideTimer();
    _tryFetchBackendPromotions();
  }

  void _startAutoSlideTimer() {
    _slideshowTimer?.cancel();
    _slideshowTimer = Timer.periodic(const Duration(milliseconds: 2800), (timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
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
          // Header row with Star icon & 'Favorite Deals & Offers'
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 22,
                    color: Color(0xFFF3D602),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Favorite Deals & Offers',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              if (widget.onSeeAll != null)
                GestureDetector(
                  onTap: widget.onSeeAll,
                  behavior: HitTestBehavior.opaque,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'See all',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE5B800),
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.chevron_right_rounded, size: 15, color: Color(0xFFE5B800)),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // 🌟 Rotating Infinite Slideshow Carousel Container
          SizedBox(
            height: 156,
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
                itemCount: _deals.length * _loopMultiplier,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final deal = _deals[index % _deals.length];
                  return _buildDealCard(deal);
                },
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 🌟 Dots Indicator (smoothly tracking normalized current index 0..3)
          Builder(
            builder: (context) {
              final normalizedIndex = _currentPage % _deals.length;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_deals.length, (index) {
                  final isCurrent = index == normalizedIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOutCubic,
                    width: isCurrent ? 22 : 6,
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
              );
            },
          ),
        ],
      ),
    );
  }

  // 🌟 Rich Multi-Stop Gradients in High-Contrast Luxury Dark Green
  List<Color> _getGradientColors(DealItem deal) {
    if (deal.id == 'deal-food-40') {
      // 🟢 Deep Emerald Gemstone (Forest Green Multi-stop)
      return const [
        Color(0xFF01180E),
        Color(0xFF032B1A),
        Color(0xFF07482D),
        Color(0xFF021B10),
      ];
    } else if (deal.id == 'deal-bill-25') {
      // 🟢 Deep Pine & Malachite Emerald (Replaced Yellow per user request)
      return const [
        Color(0xFF021D12),
        Color(0xFF053823),
        Color(0xFF0A5538),
        Color(0xFF022115),
      ];
    } else {
      // 🟢 Luxury Jade Forest
      return const [
        Color(0xFF011910),
        Color(0xFF043522),
        Color(0xFF084E32),
        Color(0xFF021B11),
      ];
    }
  }

  // 🌟 Single Deal Banner Card
  Widget _buildDealCard(DealItem deal) {
    final gradientColors = _getGradientColors(deal);

    return GestureDetector(
      onTap: () => _handleDealTap(deal),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            stops: const [0.0, 0.38, 0.78, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: deal.accentColor.withValues(alpha: 0.42),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: deal.primaryColor.withValues(alpha: 0.7),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: deal.accentColor.withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.6),
          child: Stack(
            children: [
              // 🌟 1. Full-Card Edge-to-Edge Texture Painter (100% of entire box covered)
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: DealCardTexturePainter(
                      accentColor: deal.accentColor,
                    ),
                  ),
                ),
              ),

              // 🌟 2. Watermark Icon in background
              Positioned(
                right: -10,
                bottom: -10,
                child: Opacity(
                  opacity: 0.12,
                  child: Icon(
                    deal.icon,
                    size: 96,
                    color: deal.accentColor,
                  ),
                ),
              ),

              // 🌟 3. Foreground Content with inner padding
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Row: Clean Validity Badge (Tag removed per user request)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: deal.accentColor.withValues(alpha: 0.45),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 11,
                                color: deal.accentColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                deal.expiryText,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: deal.accentColor,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _DealSparkleStar(
                          size: 14,
                          color: deal.accentColor.withValues(alpha: 0.5),
                        ),
                      ],
                    ),

                    // Title & Subtitle (🌟 Yellow font on dark green cards!)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deal.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: deal.textColor,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          deal.subTitle,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: deal.textColor.withValues(alpha: 0.88),
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
                        // Voucher Code Pill (with 1-tap fast copy)
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: deal.voucherCode));
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: Colors.black, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Promo code ${deal.voucherCode} copied!',
                                      style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 12),
                                    ),
                                  ],
                                ),
                                backgroundColor: const Color(0xFFF3D602),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                duration: const Duration(milliseconds: 1400),
                              ),
                            );
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.32),
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(
                                color: deal.accentColor.withValues(alpha: 0.55),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.copy_rounded,
                                  size: 11,
                                  color: deal.accentColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  deal.voucherCode,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                    color: deal.accentColor,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Claim Button
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                          decoration: BoxDecoration(
                            color: deal.accentColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: deal.accentColor.withValues(alpha: 0.35),
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
                                  fontSize: 10.5,
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
              ),
            ],
          ),
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

/// 🌟 Luxury Background Texture Painter for Deals Card (Herringbone Weave + Micro-dots + Specular Glow)
class DealCardTexturePainter extends CustomPainter {
  final Color accentColor;

  const DealCardTexturePainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    // 🌟 1. Full-bleed diagonal geometric micro-chevron weave covering 100% of the canvas
    final linePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.08)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 13.0;
    final maxDist = size.width + size.height * 2;
    for (double x = -size.height * 2; x < maxDist; x += spacing) {
      final path = Path();
      for (double y = 0; y <= size.height + 16; y += 14) {
        path.moveTo(x + y, y);
        path.lineTo(x + y + 7, y + 7);
        path.lineTo(x + y, y + 14);
      }
      canvas.drawPath(path, linePaint);
    }

    // 🌟 2. Full-bleed micro-dot matrix grid covering 100% edge-to-edge
    final dotPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.09)
      ..style = PaintingStyle.fill;

    for (double dx = 6; dx <= size.width; dx += 20) {
      for (double dy = 6; dy <= size.height; dy += 18) {
        canvas.drawCircle(Offset(dx, dy), 1.0, dotPaint);
      }
    }

    // 🌟 3. Ambient specular glow orbs (Top-Right and Bottom-Left)
    final glowPaint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          accentColor.withValues(alpha: 0.18),
          accentColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.85, 20),
        radius: 90,
      ));
    canvas.drawCircle(Offset(size.width * 0.85, 20), 90, glowPaint1);

    final glowPaint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          accentColor.withValues(alpha: 0.10),
          accentColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(20, size.height * 0.85),
        radius: 70,
      ));
    canvas.drawCircle(Offset(20, size.height * 0.85), 70, glowPaint2);
  }

  @override
  bool shouldRepaint(covariant DealCardTexturePainter oldDelegate) =>
      oldDelegate.accentColor != accentColor;
}

/// 🌟 4-pointed Sparkle Star for Deals Cards
class _DealSparkleStar extends StatelessWidget {
  final double size;
  final Color color;

  const _DealSparkleStar({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DealSparklePainter(color: color),
    );
  }
}

class _DealSparklePainter extends CustomPainter {
  final Color color;

  _DealSparklePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final w = size.width / 2;
    final h = size.height / 2;
    const curvature = 0.22;

    final path = Path()
      ..moveTo(center.dx, center.dy - h)
      ..quadraticBezierTo(center.dx + (w * curvature), center.dy - (h * curvature), center.dx + w, center.dy)
      ..quadraticBezierTo(center.dx + (w * curvature), center.dy + (h * curvature), center.dx, center.dy + h)
      ..quadraticBezierTo(center.dx - (w * curvature), center.dy + (h * curvature), center.dx - w, center.dy)
      ..quadraticBezierTo(center.dx - (w * curvature), center.dy - (h * curvature), center.dx, center.dy - h)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DealSparklePainter oldDelegate) => oldDelegate.color != color;
}
