import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/entity/entities.dart';
import '../../providers/media_library_provider.dart';
import '../widgets/poster_card.dart';

class SectionViewPage extends StatelessWidget {
  final String title;
  final List<MediaFileEntity> items;

  const SectionViewPage({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.read<MediaLibraryProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            centerTitle: true,
            title: Text(
              title,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            leading: const Center(child: _BackButton()),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: theme.dividerColor, height: 1),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(30),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                double width = constraints.crossAxisExtent;
                const double desiredItemWidth = 180;
                int crossAxisCount = (width / desiredItemWidth).floor();
                if (crossAxisCount < 3) crossAxisCount = 3;

                return SliverGrid.builder(
                  itemCount: items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 30,
                  ),
                  itemBuilder: (context, index) {
                    return PosterCard(file: items[index], provider: provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatefulWidget {
  const _BackButton();

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _isHovering = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.textTheme.bodyMedium!.color!;
    final hoverColor = iconColor.withAlpha(25);
    final pressedColor = iconColor.withAlpha(51);
    const defaultColor = Colors.transparent;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () => Navigator.pop(context),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: _isPressed ? Duration.zero : const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _isPressed ? pressedColor : (_isHovering ? hoverColor : defaultColor),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(Icons.arrow_back_ios_new, size: 18, color: iconColor),
        ),
      ),
    );
  }
}
