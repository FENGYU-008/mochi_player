import 'package:flutter/material.dart';
import 'package:mochi_player/app/presentation/navigation/app_destination.dart';
import 'package:mochi_player/app/presentation/widgets/sidebar.dart';
import 'package:mochi_player/core/ui/app_ui.dart';
import 'package:mochi_player/features/home/application/trending_media_provider.dart';
import 'package:mochi_player/features/home/presentation/widgets/home_content.dart';
import 'package:mochi_player/features/library/application/media_library_provider.dart';
import 'package:mochi_player/features/library/presentation/pages/file_browser_page.dart';
import 'package:mochi_player/features/library/presentation/pages/library_page.dart';
import 'package:mochi_player/features/settings/application/app_settings_provider.dart';
import 'package:mochi_player/features/settings/presentation/pages/settings_page.dart';
import 'package:provider/provider.dart';

class AppShellPage extends StatefulWidget {
  const AppShellPage({super.key});

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  final Map<AppDestination, GlobalKey<NavigatorState>> _navigatorKeys = {
    for (final destination in AppDestination.values)
      destination: GlobalKey<NavigatorState>(),
  };
  final Set<AppDestination> _visitedDestinations = {AppDestination.home};
  AppDestination _selectedDestination = AppDestination.home;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeApp());
  }

  Future<void> _initializeApp() async {
    final settingsProvider = context.read<AppSettingsProvider>();
    final libraryProvider = context.read<MediaLibraryProvider>();
    final trendingProvider = context.read<TrendingMediaProvider>();

    await libraryProvider.loadFromDatabase();
    if (settingsProvider.hasTmdbApiKey) {
      await trendingProvider.fetch();
    }
  }

  void _selectDestination(AppDestination destination) {
    if (destination == _selectedDestination) {
      _navigatorKeys[destination]?.currentState?.popUntil(
        (route) => route.isFirst,
      );
      return;
    }

    _navigatorKeys[_selectedDestination]?.currentState?.popUntil(
      (route) => route.isFirst,
    );
    setState(() {
      _selectedDestination = destination;
      _visitedDestinations.add(destination);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedDestination: _selectedDestination,
            onDestinationSelected: _selectDestination,
          ),
          Expanded(
            child: ColoredBox(
              color: theme.scaffoldBackgroundColor,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: IndexedStack(
                      index: _selectedDestination.index,
                      children: AppDestination.values.map((destination) {
                        if (!_visitedDestinations.contains(destination)) {
                          return const SizedBox.shrink();
                        }

                        return TickerMode(
                          enabled: destination == _selectedDestination,
                          child: Navigator(
                            key: _navigatorKeys[destination],
                            onGenerateRoute: (settings) =>
                                MaterialPageRoute<void>(
                                  settings: RouteSettings(
                                    name: 'content-${destination.name}',
                                  ),
                                  builder: (context) =>
                                      _buildDestinationPage(destination),
                                ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Selector<MediaLibraryProvider, _LibraryActivityState>(
                    selector: (context, provider) => _LibraryActivityState(
                      message: provider.libraryActivityMessage,
                      progress: provider.scrapeProgress,
                    ),
                    builder: (context, activity, child) {
                      final message = activity.message;
                      if (message == null) return const SizedBox.shrink();

                      return Positioned(
                        top: AppHeader.height + 10,
                        left: AppSpacing.page,
                        right: AppSpacing.page,
                        child: AppActivityBanner(
                          message: message,
                          progress: activity.progress,
                          tone: AppActivityBannerTone.progress,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationPage(AppDestination destination) {
    return switch (destination) {
      AppDestination.home => const _HomeDestinationPage(),
      AppDestination.movies => const _DestinationPageFrame(
        destination: AppDestination.movies,
        child: LibraryPage(category: LibraryCategory.movies),
      ),
      AppDestination.series => const _DestinationPageFrame(
        destination: AppDestination.series,
        child: LibraryPage(category: LibraryCategory.series),
      ),
      AppDestination.fileBrowser => const FileBrowserPage(),
      AppDestination.favorites => const _DestinationPageFrame(
        destination: AppDestination.favorites,
        child: LibraryPage(category: LibraryCategory.favorites),
      ),
      AppDestination.settings => const SettingsPage(),
    };
  }
}

class _HomeDestinationPage extends StatefulWidget {
  const _HomeDestinationPage();

  @override
  State<_HomeDestinationPage> createState() => _HomeDestinationPageState();
}

class _HomeDestinationPageState extends State<_HomeDestinationPage> {
  double _scrollOffset = 0;

  @override
  Widget build(BuildContext context) {
    final headerOpacity = (_scrollOffset / 200).clamp(0.0, 1.0);

    return Stack(
      children: [
        Positioned.fill(
          child: HomeContent(
            onScroll: (offset) {
              if (offset == _scrollOffset) return;
              setState(() => _scrollOffset = offset);
            },
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: AppHeader.height,
          child: AppHeader(
            title: AppDestination.home.title,
            opacity: headerOpacity,
            ignoreWhenTransparent: true,
          ),
        ),
      ],
    );
  }
}

class _DestinationPageFrame extends StatelessWidget {
  final AppDestination destination;
  final Widget child;

  const _DestinationPageFrame({required this.destination, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: child),
        if (destination.showsHeader)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: AppHeader.height,
            child: AppHeader(title: destination.title),
          ),
      ],
    );
  }
}

class _LibraryActivityState {
  final String? message;
  final double? progress;

  const _LibraryActivityState({required this.message, required this.progress});

  @override
  bool operator ==(Object other) {
    return other is _LibraryActivityState &&
        other.message == message &&
        other.progress == progress;
  }

  @override
  int get hashCode => Object.hash(message, progress);
}
