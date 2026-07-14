import 'package:mochi_player/core/domain/media/models.dart';

class MediaDetailViewModel {
  final dynamic _item;
  final bool isMovie;
  final bool isTVShow;

  MediaDetailViewModel(this._item)
    : isMovie = _item is Movie,
      isTVShow = _item is TVShow,
      assert(_item is Movie || _item is TVShow, 'Item must be Movie or TVShow');

  String get tmdbId {
    if (isMovie) return (_item as Movie).tmdbId;
    return (_item as TVShow).tmdbId;
  }

  String get title {
    if (isMovie) return (_item as Movie).title;
    return (_item as TVShow).title;
  }

  String get overview {
    String? s;
    if (isMovie) s = (_item as Movie).overview;
    if (isTVShow) s = (_item as TVShow).overview;
    return s ?? "暂无简介";
  }

  String get backdropUrl {
    String? url;
    if (isMovie) url = (_item as Movie).backdropUrl;
    if (isTVShow) url = (_item as TVShow).backdropUrl;
    return url ?? "";
  }

  String get posterUrl {
    String? url;
    if (isMovie) url = (_item as Movie).posterUrl;
    if (isTVShow) url = (_item as TVShow).posterUrl;
    return url ?? "";
  }

  String? get logoUrl {
    if (isMovie) return (_item as Movie).logoUrl;
    if (isTVShow) return (_item as TVShow).logoUrl;
    return null;
  }

  List<String> get genres {
    if (isMovie) return (_item as Movie).genres;
    if (isTVShow) return (_item as TVShow).genres;
    return [];
  }

  double get rating {
    if (isMovie) return (_item as Movie).rating;
    return (_item as TVShow).rating;
  }

  int? get releaseYear {
    if (isMovie) return (_item as Movie).releaseYear;
    return (_item as TVShow).releaseYear;
  }

  String? get certification {
    if (isMovie) return (_item as Movie).certification;
    return (_item as TVShow).certification;
  }

  List<Artist> get cast {
    if (isMovie) return (_item as Movie).cast;
    if (isTVShow) return (_item as TVShow).cast;
    return [];
  }

  /// 原始对象，用于把 TVShow 传给 EpisodeList
  dynamic get originalItem => _item;

  /// 仅 TVShow 有效
  List<Season> get seasons {
    if (isTVShow) return (_item as TVShow).seasons;
    return [];
  }
}
