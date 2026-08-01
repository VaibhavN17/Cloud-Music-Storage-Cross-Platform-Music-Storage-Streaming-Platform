/// Adaptive navigation shell.
///
/// On mobile: Bottom navigation bar with mini player docked above it.
/// On tablet: Navigation rail with expanded content.
/// On desktop: Collapsible sidebar with persistent bottom player bar.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../core/extensions/theme_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../features/player/presentation/widgets/mini_player.dart';

class AdaptiveShell extends StatelessWidget {
  const AdaptiveShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  static final _destinations = [
    const _NavDestination(
      icon: Iconsax.home_2,
      selectedIcon: Iconsax.home,
      label: 'Home',
    ),
    const _NavDestination(
      icon: Iconsax.music_library_2,
      selectedIcon: Iconsax.music,
      label: 'Library',
    ),
    const _NavDestination(
      icon: Iconsax.search_normal_1,
      selectedIcon: Iconsax.search_normal,
      label: 'Search',
    ),
    const _NavDestination(
      icon: Iconsax.arrow_down_2,
      selectedIcon: Iconsax.document_download,
      label: 'Downloads',
    ),
    const _NavDestination(
      icon: Iconsax.profile_circle,
      selectedIcon: Iconsax.user,
      label: 'Profile',
    ),
  ];

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop) {
      return _DesktopLayout(
        navigationShell: navigationShell,
        destinations: _destinations,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
      );
    }

    if (context.isTablet) {
      return _TabletLayout(
        navigationShell: navigationShell,
        destinations: _destinations,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
      );
    }

    return _MobileLayout(
      navigationShell: navigationShell,
      destinations: _destinations,
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: _onDestinationSelected,
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// MOBILE LAYOUT
// ────────────────────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.navigationShell,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final StatefulNavigationShell navigationShell;
  final List<_NavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: context.appColors.border,
                  width: 0.5,
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: destinations
                  .map((d) => NavigationDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label: d.label,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// TABLET LAYOUT
// ────────────────────────────────────────────────────────────────────────────

class _TabletLayout extends StatelessWidget {
  const _TabletLayout({
    required this.navigationShell,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final StatefulNavigationShell navigationShell;
  final List<_NavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            destinations: destinations
                .map((d) => NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: Text(d.label),
                    ))
                .toList(),
          ),
          VerticalDivider(
            width: 0.5,
            thickness: 0.5,
            color: context.appColors.border,
          ),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// DESKTOP LAYOUT
// ────────────────────────────────────────────────────────────────────────────

class _DesktopLayout extends StatefulWidget {
  const _DesktopLayout({
    required this.navigationShell,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final StatefulNavigationShell navigationShell;
  final List<_NavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  State<_DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<_DesktopLayout> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: _isExpanded
                ? AppConstants.sidebarWidth
                : AppConstants.sidebarCollapsedWidth,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: context.appColors.border,
                  width: 0.5,
                ),
              ),
            ),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          width: 28,
                          height: 28,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (_isExpanded) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Cloud Music',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      IconButton(
                        icon: Icon(
                          _isExpanded
                              ? Iconsax.sidebar_left
                              : Iconsax.sidebar_right,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _isExpanded = !_isExpanded),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Nav items
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.destinations.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      final dest = widget.destinations[index];
                      final selected = index == widget.selectedIndex;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => widget.onDestinationSelected(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(
                                horizontal: _isExpanded ? 16 : 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    selected ? dest.selectedIcon : dest.icon,
                                    color: selected
                                        ? AppColors.primary
                                        : context.appColors.textSecondary,
                                    size: 22,
                                  ),
                                  if (_isExpanded) ...[
                                    const SizedBox(width: 14),
                                    Text(
                                      dest.label,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: selected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: selected
                                            ? AppColors.primary
                                            : context.appColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(child: widget.navigationShell),
        ],
      ),
      // TODO: Add persistent bottom player bar in Phase 13.
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// DESTINATION MODEL
// ────────────────────────────────────────────────────────────────────────────

class _NavDestination {
  const _NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
