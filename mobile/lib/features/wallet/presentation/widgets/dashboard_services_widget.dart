import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';
import 'package:batwa_wallet/features/bills/presentation/screens/bills_hub_screen.dart';
import 'package:batwa_wallet/features/cards/presentation/screens/cards_screen.dart';
import 'package:batwa_wallet/features/transfer/presentation/screens/send_money_screen.dart';
import 'package:batwa_wallet/features/vaults/presentation/screens/vaults_screen.dart';
import 'package:batwa_wallet/features/splits/presentation/screens/splits_hub_screen.dart';
import 'package:batwa_wallet/features/qr/presentation/screens/my_qr_screen.dart';

class ServiceItemData {
  final String id;
  final String label;
  final IconData icon;
  final bool isPinned;
  final VoidCallback onTap;

  const ServiceItemData({
    required this.id,
    required this.label,
    required this.icon,
    this.isPinned = false,
    required this.onTap,
  });
}

class DashboardServicesWidget extends StatefulWidget {
  final double userBalance;

  const DashboardServicesWidget({
    super.key,
    this.userBalance = 20600.0,
  });

  @override
  State<DashboardServicesWidget> createState() => _DashboardServicesWidgetState();
}

class _DashboardServicesWidgetState extends State<DashboardServicesWidget> {
  int _selectedCategoryIndex = 0;
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _pinnedServiceIds = {'pay_bills', 'top_up'};

  final List<String> _categories = ['Pay', 'Transfer', 'Cards', 'Invest', 'More'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _togglePin(String serviceId, String label) {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_pinnedServiceIds.contains(serviceId)) {
        _pinnedServiceIds.remove(serviceId);
        _showToast('Unpinned $label from quick services', isSuccess: false);
      } else {
        _pinnedServiceIds.add(serviceId);
        _showToast('📌 Pinned $label to quick services', isSuccess: true);
      }
    });
  }

  void _showToast(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSuccess ? const Color(0xFF10B981) : AppColors.primaryYellow,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess ? Icons.check_rounded : Icons.info_outline_rounded,
                color: Colors.black,
                size: 14,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1B1D28),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<ServiceItemData> _getServicesForCategory(int index) {
    switch (index) {
      case 0: // Pay
        return [
          ServiceItemData(
            id: 'pay_bills',
            label: 'Pay bills',
            icon: Icons.receipt_long_outlined,
            isPinned: _pinnedServiceIds.contains('pay_bills'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BillsHubScreen()),
              );
            },
          ),
          ServiceItemData(
            id: 'top_up',
            label: 'Top-up',
            icon: Icons.smartphone_rounded,
            isPinned: _pinnedServiceIds.contains('top_up'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BillsHubScreen()),
              );
            },
          ),
          ServiceItemData(
            id: 'electricity',
            label: 'Electricity',
            icon: Icons.bolt_rounded,
            isPinned: _pinnedServiceIds.contains('electricity'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BillsHubScreen()),
              );
            },
          ),
          ServiceItemData(
            id: 'gas',
            label: 'Gas',
            icon: Icons.local_fire_department_rounded,
            isPinned: _pinnedServiceIds.contains('gas'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BillsHubScreen()),
              );
            },
          ),
          ServiceItemData(
            id: 'water',
            label: 'Water',
            icon: Icons.water_drop_outlined,
            isPinned: _pinnedServiceIds.contains('water'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BillsHubScreen()),
              );
            },
          ),
          ServiceItemData(
            id: 'internet',
            label: 'Internet',
            icon: Icons.wifi_rounded,
            isPinned: _pinnedServiceIds.contains('internet'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BillsHubScreen()),
              );
            },
          ),
          ServiceItemData(
            id: 'education',
            label: 'Education',
            icon: Icons.school_outlined,
            isPinned: _pinnedServiceIds.contains('education'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BillsHubScreen()),
              );
            },
          ),
          ServiceItemData(
            id: 'govt_fbr',
            label: 'Govt / FBR',
            icon: Icons.account_balance_outlined,
            isPinned: _pinnedServiceIds.contains('govt_fbr'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BillsHubScreen()),
              );
            },
          ),
        ];

      case 1: // Transfer
        return [
          ServiceItemData(
            id: 'raast',
            label: 'Raast Instant',
            icon: Icons.flash_on_rounded,
            isPinned: _pinnedServiceIds.contains('raast'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => SendMoneyScreen(userBalance: widget.userBalance)),
              );
            },
          ),
          ServiceItemData(
            id: 'bank_transfer',
            label: 'Bank Transfer',
            icon: Icons.account_balance_rounded,
            isPinned: _pinnedServiceIds.contains('bank_transfer'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => SendMoneyScreen(userBalance: widget.userBalance)),
              );
            },
          ),
          ServiceItemData(
            id: 'cnic_transfer',
            label: 'CNIC Transfer',
            icon: Icons.badge_outlined,
            isPinned: _pinnedServiceIds.contains('cnic_transfer'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => SendMoneyScreen(userBalance: widget.userBalance)),
              );
            },
          ),
          ServiceItemData(
            id: 'batwa_p2p',
            label: 'Batwa P2P',
            icon: Icons.alternate_email_rounded,
            isPinned: _pinnedServiceIds.contains('batwa_p2p'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => SendMoneyScreen(userBalance: widget.userBalance)),
              );
            },
          ),
          ServiceItemData(
            id: 'split_bills',
            label: 'Split Bills',
            icon: Icons.call_split_rounded,
            isPinned: _pinnedServiceIds.contains('split_bills'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SplitsHubScreen()),
              );
            },
          ),
          ServiceItemData(
            id: 'request_qr',
            label: 'Request / QR',
            icon: Icons.qr_code_2_rounded,
            isPinned: _pinnedServiceIds.contains('request_qr'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyQrScreen()),
              );
            },
          ),
          ServiceItemData(
            id: 'contact_send',
            label: 'Contacts',
            icon: Icons.contacts_outlined,
            isPinned: _pinnedServiceIds.contains('contact_send'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => SendMoneyScreen(userBalance: widget.userBalance)),
              );
            },
          ),
          ServiceItemData(
            id: 'global_remit',
            label: 'Remittance',
            icon: Icons.public_rounded,
            isPinned: _pinnedServiceIds.contains('global_remit'),
            onTap: () {
              _showToast('Global remittance arriving soon!', isSuccess: false);
            },
          ),
        ];

      case 2: // Cards
        return [
          ServiceItemData(
            id: 'virtual_visa',
            label: 'Virtual Visa',
            icon: Icons.credit_card_rounded,
            isPinned: _pinnedServiceIds.contains('virtual_visa'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CardsScreen()),
              );
            },
          ),
          ServiceItemData(
            id: 'order_card',
            label: 'Order Physical',
            icon: Icons.local_shipping_outlined,
            isPinned: _pinnedServiceIds.contains('order_card'),
            onTap: () {
              _showToast('Physical card delivery request submitted!', isSuccess: true);
            },
          ),
          ServiceItemData(
            id: 'card_limits',
            label: 'Card Limits',
            icon: Icons.speed_rounded,
            isPinned: _pinnedServiceIds.contains('card_limits'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CardsScreen()),
              );
            },
          ),
          ServiceItemData(
            id: 'card_security',
            label: 'Card Security',
            icon: Icons.security_rounded,
            isPinned: _pinnedServiceIds.contains('card_security'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CardsScreen()),
              );
            },
          ),
        ];

      case 3: // Invest
        return [
          ServiceItemData(
            id: 'digital_gold',
            label: 'Digital Gold',
            icon: Icons.monetization_on_outlined,
            isPinned: _pinnedServiceIds.contains('digital_gold'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VaultsScreen()),
              );
            },
          ),
          ServiceItemData(
            id: 'savings_vaults',
            label: 'Savings Vaults',
            icon: Icons.savings_outlined,
            isPinned: _pinnedServiceIds.contains('savings_vaults'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VaultsScreen()),
              );
            },
          ),
          ServiceItemData(
            id: 'fixed_deposit',
            label: 'Fixed Deposit',
            icon: Icons.account_balance_wallet_outlined,
            isPinned: _pinnedServiceIds.contains('fixed_deposit'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VaultsScreen()),
              );
            },
          ),
          ServiceItemData(
            id: 'mutual_funds',
            label: 'Profit Returns',
            icon: Icons.trending_up_rounded,
            isPinned: _pinnedServiceIds.contains('mutual_funds'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VaultsScreen()),
              );
            },
          ),
        ];

      case 4: // More
      default:
        return [
          ..._getServicesForCategory(0),
          ..._getServicesForCategory(1),
          ..._getServicesForCategory(2),
          ..._getServicesForCategory(3),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allCategoryServices = _getServicesForCategory(_selectedCategoryIndex);

    // Apply search filter if search is active
    final displayedServices = _searchQuery.isEmpty
        ? allCategoryServices
        : allCategoryServices.where((s) => s.label.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🌟 1. Top Section Header (Services & "Long-press to pin")
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Services',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Long-press to pin',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white54 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 🌟 2. Category Capsule Filter Strip + Search Icon
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: List.generate(_categories.length, (idx) {
                        final isSelected = _selectedCategoryIndex == idx && !_isSearchOpen;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _selectedCategoryIndex = idx;
                                _isSearchOpen = false;
                                _searchQuery = '';
                                _searchController.clear();
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark ? const Color(0xFFF3D602) : const Color(0xFF07482D))
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _categories[idx],
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected
                                      ? (isDark ? const Color(0xFF07482D) : Colors.white)
                                      : (isDark ? Colors.white60 : AppColors.textSecondary),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                // Search Icon button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _isSearchOpen = !_isSearchOpen;
                      if (!_isSearchOpen) {
                        _searchQuery = '';
                        _searchController.clear();
                      }
                    });
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _isSearchOpen
                          ? const Color(0xFFF3D602)
                          : (isDark ? const Color(0xFF132A20) : const Color(0xFFE8F5EE)),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isSearchOpen
                            ? const Color(0xFFF3D602)
                            : (isDark ? const Color(0xFF1E4333) : const Color(0xFFD0EBDD)),
                        width: 1.0,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _isSearchOpen ? Icons.close_rounded : Icons.search_rounded,
                        size: 17,
                        color: _isSearchOpen
                            ? const Color(0xFF07482D)
                            : (isDark ? const Color(0xFFF3D602) : const Color(0xFF07482D)),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Optional Search Input Bar
            if (_isSearchOpen) ...[
              const SizedBox(height: 10),
              Container(
                height: 38,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E222D) : const Color(0xFFF4F6F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search billers, utilities, transfers...',
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : AppColors.textSecondary,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textSecondary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // 🌟 3. Services 4-Column Grid
            if (displayedServices.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No services found matching "$_searchQuery"',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayedServices.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (context, idx) {
                  final service = displayedServices[idx];
                  return _buildServiceSquircleItem(
                    service: service,
                    isDark: isDark,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceSquircleItem({
    required ServiceItemData service,
    required bool isDark,
  }) {
    // Batwa Brand Theme: Subtle Luxury Emerald container with Signature Dark Green Icon
    final bgColor = isDark ? const Color(0xFF132A20) : const Color(0xFFE8F5EE);
    final borderColor = isDark ? const Color(0xFF1E4333) : const Color(0xFFD0EBDD);
    final iconColor = isDark ? const Color(0xFFF3D602) : const Color(0xFF07482D); // Signature Batwa Dark Green

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        service.onTap();
      },
      onLongPress: () {
        _togglePin(service.id, service.label);
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Squircle rounded box
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF07482D).withValues(alpha: isDark ? 0.08 : 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    service.icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
              ),

              // Small pin badge on corner (Batwa Dark Green with Electric Yellow checkmark)
              if (service.isPinned)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: const Color(0xFF07482D),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.3),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_rounded,
                        color: Color(0xFFF3D602),
                        size: 9.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 7),

          // Label
          Text(
            service.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1B1D28),
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
