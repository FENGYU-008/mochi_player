import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../models/domain/models.dart';
import '../../view_models/media_detail_view_model.dart';
import '../horizontal_scroll_view.dart';

class CastList extends StatefulWidget {
  final MediaDetailViewModel viewModel;

  const CastList({super.key, required this.viewModel});

  @override
  State<CastList> createState() => _CastListState();
}

class _CastListState extends State<CastList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.viewModel.cast.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32), // Spacing before Cast title
        Text(
          "Cast",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: HorizontalScrollView(
            controller: _scrollController,
            bottomPadding: 58,
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.viewModel.cast.length,
              separatorBuilder: (_, __) => const SizedBox(width: 20),
              itemBuilder: (context, index) =>
                  _buildCastItem(widget.viewModel.cast[index]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCastItem(Artist artist) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[200],
            image: artist.profileUrl != null
                ? DecorationImage(
                    image: CachedNetworkImageProvider(artist.profileUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: artist.profileUrl == null
              ? const Icon(Icons.person, color: Colors.grey, size: 40)
              : null,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 90,
          child: Text(
            artist.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ),
        SizedBox(
          width: 90,
          child: Text(
            artist.character ?? "",
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
