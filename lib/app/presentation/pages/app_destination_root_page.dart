import 'package:flutter/material.dart';

import 'package:mochi_player/app/presentation/navigation/app_destination.dart';
import 'package:mochi_player/core/ui/app_ui.dart';
import 'package:mochi_player/features/home/presentation/widgets/home_content.dart';
import 'package:mochi_player/features/library/presentation/pages/file_browser_page.dart';
import 'package:mochi_player/features/library/presentation/pages/library_page.dart';
import 'package:mochi_player/features/settings/presentation/pages/settings_page.dart';

class AppDestinationRootPage extends StatelessWidget {
  const AppDestinationRootPage({super.key, required this.destination});

  final AppDestination destination;

  @override
  Widget build(BuildContext context) {
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
  const _DestinationPageFrame({required this.destination, required this.child});

  final AppDestination destination;
  final Widget child;

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
