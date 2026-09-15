import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:veil_mobile/app/router.dart';
import 'package:veil_mobile/shared/constants/app_strings.dart';

/// Shell layout with app bar, body, and bottom navigation.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.actions,
    this.cinemaMode = false,
    this.hideAppBar = false,
    this.hideBottomNavigation = false,
    this.showBackButton = false,
  });

  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final List<Widget>? actions;

  /// Immersive shell: dark backdrop, light app bar, body extends behind nav.
  final bool cinemaMode;

  /// Hides the app bar/title (Player immersive playback).
  final bool hideAppBar;

  /// Hides bottom navigation (Player immersive playback).
  final bool hideBottomNavigation;

  /// Shows a back button when the route can pop (nested settings screens).
  final bool showBackButton;

  static final _destinations = [
    _NavDestination(
      label: AppStrings.navHome,
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      route: AppRoutes.home,
    ),
    _NavDestination(
      label: AppStrings.navLibrary,
      icon: Icons.folder_outlined,
      selectedIcon: Icons.folder,
      route: AppRoutes.library,
    ),
    _NavDestination(
      label: AppStrings.navPlayer,
      icon: Icons.play_circle_outline,
      selectedIcon: Icons.play_circle,
      route: AppRoutes.player,
    ),
    _NavDestination(
      label: AppStrings.navBuilder,
      icon: Icons.build_outlined,
      selectedIcon: Icons.build,
      route: AppRoutes.trackBuilder,
    ),
    _NavDestination(
      label: AppStrings.navSettings,
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      route: AppRoutes.settings,
    ),
  ];

  int _selectedIndexForPath(String path) {
    for (var i = 0; i < _destinations.length; i++) {
      final route = _destinations[i].route;
      if (route == AppRoutes.home) {
        if (path == route) {
          return i;
        }
      } else if (path == route || path.startsWith('$route/')) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = _selectedIndexForPath(location);

    return Scaffold(
      extendBody: cinemaMode || hideBottomNavigation,
      backgroundColor: cinemaMode ? Colors.black : null,
      appBar: hideAppBar
          ? null
          : cinemaMode
          ? AppBar(
              title: Text(title),
              actions: actions,
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
            )
          : AppBar(
              title: Text(title),
              actions: actions,
              leading: showBackButton && context.canPop()
                  ? BackButton(onPressed: () => context.pop())
                  : null,
              automaticallyImplyLeading: showBackButton,
            ),
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: hideBottomNavigation
          ? null
          : NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                final route = _destinations[index].route;
                if (route != location) {
                  context.go(route);
                }
              },
              destinations: [
                for (final dest in _destinations)
                  NavigationDestination(
                    icon: Icon(dest.icon),
                    selectedIcon: Icon(dest.selectedIcon),
                    label: dest.label,
                  ),
              ],
            ),
    );
  }
}

class _NavDestination {
  const _NavDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
}
