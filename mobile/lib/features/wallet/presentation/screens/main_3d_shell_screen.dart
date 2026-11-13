import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batwa_wallet/core/services/app_update_service.dart';
import 'package:batwa_wallet/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:batwa_wallet/features/auth/presentation/bloc/auth_state.dart';
import 'package:batwa_wallet/features/auth/presentation/screens/login_screen.dart';
import 'package:batwa_wallet/features/wallet/presentation/screens/dashboard_screen.dart';
import 'package:batwa_wallet/features/wallet/presentation/screens/drawer_underlay_screen.dart';
import 'package:batwa_wallet/features/cards/presentation/screens/cards_screen.dart';
import 'package:batwa_wallet/features/analytics/presentation/screens/analytics_dashboard_screen.dart';
import 'package:batwa_wallet/features/security/presentation/screens/security_settings_screen.dart';

class Main3DShellScreen extends StatefulWidget {
  const Main3DShellScreen({super.key});

  @override
  State<Main3DShellScreen> createState() => _Main3DShellScreenState();
}

class _Main3DShellScreenState extends State<Main3DShellScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _selectedDrawerIndex = 0;
  bool _canDrag = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppUpdateService.promptIfUpdateAvailable(context);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _openDrawer() {
    if (!_animationController.isAnimating) {
      _animationController.animateTo(
        1.0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _closeDrawer() {
    if (!_animationController.isAnimating && _animationController.value > 0) {
      _animationController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _toggleDrawer() {
    if (_animationController.value > 0.4) {
      _closeDrawer();
    } else {
      _openDrawer();
    }
  }

  void _handleDrawerSelection(int index) {
    setState(() => _selectedDrawerIndex = index);
    _closeDrawer();

    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SecuritySettingsScreen()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CardsScreen()));
    } else if (index == 3 || index == 4) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsDashboardScreen()));
    } else if (index == 5) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SecuritySettingsScreen()));
    }
  }

  void _handleHorizontalDragStart(DragStartDetails details) {
    if (_animationController.isAnimating) return;
    // Allow swipe initiation from the left side (< 80px) or if drawer is already open
    if (_animationController.value < 0.05 && details.globalPosition.dx < 80) {
      _canDrag = true;
    } else if (_animationController.value > 0.8) {
      _canDrag = true;
    } else {
      _canDrag = false;
    }
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_canDrag || _animationController.isAnimating) return;
    final delta = details.primaryDelta ?? 0;

    if (delta > 5 && _animationController.value < 0.5) {
      _canDrag = false;
      _openDrawer();
    } else if (delta < -5 && _animationController.value > 0.5) {
      _canDrag = false;
      _closeDrawer();
    }
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    if (!_canDrag) return;
    _canDrag = false;
    final velocity = details.primaryVelocity ?? 0;
    if (velocity > 80) {
      _openDrawer();
    } else if (velocity < -80) {
      _closeDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1118) : const Color(0xFFF1F3F6),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen(clearFields: true)),
              (route) => false,
            );
          }
        },
        child: GestureDetector(
          onHorizontalDragStart: _handleHorizontalDragStart,
          onHorizontalDragUpdate: _handleHorizontalDragUpdate,
          onHorizontalDragEnd: _handleHorizontalDragEnd,
          behavior: HitTestBehavior.translucent,
          child: Stack(
          children: [
            // 🌟 LAYER 0: Underlay Navigation Drawer (Lazy-rendered only when opening)
            AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                final isVisible = _animationController.value > 0.001;
                if (!isVisible) return const SizedBox.shrink();

                return IgnorePointer(
                  ignoring: _animationController.value < 0.6,
                  child: Transform.translate(
                    offset: Offset((_animation.value - 1.0) * 30, 0),
                    child: RepaintBoundary(
                      child: DrawerUnderlayScreen(
                        selectedIndex: _selectedDrawerIndex,
                        onItemSelected: _handleDrawerSelection,
                        onClose: _closeDrawer,
                      ),
                    ),
                  ),
                );
              },
            ),

            // 🌟 LAYER 1: Foreground Sliding Canvas (Slides 100% Completely Off-Screen)
            AnimatedBuilder(
              animation: _animation,
              child: RepaintBoundary(
                child: DashboardScreen(
                  onMenuTap: _toggleDrawer,
                ),
              ),
              builder: (context, cachedDashboard) {
                final val = _animation.value;
                if (val <= 0.001) {
                  // Direct 0ms zero-compositing pass-through!
                  return cachedDashboard!;
                }

                final isDrawerOpen = val > 0.98;
                final slideX = val * (size.width + 20);
                final scale = 1.0 - (val * 0.05);

                return Transform(
                  transform: Matrix4.identity()
                    ..translate(slideX, 0.0, 0.0)
                    ..scale(scale),
                  alignment: Alignment.centerLeft,
                  child: IgnorePointer(
                    ignoring: isDrawerOpen,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(val * 24.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: (isDark ? 0.4 : 0.15) * val),
                            blurRadius: 20 * val,
                            offset: Offset(-4 * val, 6 * val),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(val * 24.0),
                        clipBehavior: Clip.antiAlias,
                        child: cachedDashboard!,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      ),
    );
  }
}
