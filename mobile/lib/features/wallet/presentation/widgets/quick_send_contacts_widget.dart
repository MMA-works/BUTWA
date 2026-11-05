import 'package:flutter/material.dart';
import 'package:batwa_wallet/core/constants/app_colors.dart';

class QuickSendContactsWidget extends StatelessWidget {
  final Function(String name, String tag)? onContactSelected;
  final VoidCallback? onSeeAll;

  const QuickSendContactsWidget({
    super.key,
    this.onContactSelected,
    this.onSeeAll,
  });

  static const List<Map<String, dynamic>> _contacts = [
    {'name': 'Azle', 'tag': 'azle', 'color': Color(0xFFEC4899), 'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=80'},
    {'name': 'Chaoir', 'tag': 'chaoir', 'color': Color(0xFF06B6D4), 'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&auto=format&fit=crop&q=80'},
    {'name': 'Fandit', 'tag': 'fandit', 'color': Color(0xFF10B981), 'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&auto=format&fit=crop&q=80'},
    {'name': 'Happy', 'tag': 'happy', 'color': Color(0xFFEF4444), 'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&auto=format&fit=crop&q=80'},
    {'name': 'Noyu', 'tag': 'noyu', 'color': Color(0xFFF59E0B), 'avatar': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=100&auto=format&fit=crop&q=80'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 18,
                    color: AppColors.primaryYellow,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Favourites',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: const Row(
                  children: [
                    Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryMustard,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.primaryMustard,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _contacts.length + 1,
              separatorBuilder: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Center(
                  child: Container(
                    width: 14,
                    height: 1.5,
                    color: isDark ? AppColors.darkCardBorder : AppColors.lightDivider,
                  ),
                ),
              ),
              itemBuilder: (context, index) {
                if (index == 0) {
                  // 🌟 "+ Add" Quick Favorite button
                  return GestureDetector(
                    onTap: onSeeAll,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? const Color(0xFF1E212D) : const Color(0xFFFFFBE6),
                            border: Border.all(
                              color: AppColors.primaryYellow,
                              width: 1.5,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add_rounded,
                              color: Color(0xFF1B1D28),
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final contact = _contacts[index - 1];
                return GestureDetector(
                  onTap: () => onContactSelected?.call(contact['name'], contact['tag']),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: contact['color'] as Color,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  (contact['color'] as Color).withValues(alpha: 0.85),
                                  contact['color'] as Color,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                contact['name'][0],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contact['name'] as String,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
