import 'package:mochi_player/core/domain/media/models.dart';

class MediaDetailViewModel {
  final LibraryItem _item;

  MediaDetailViewModel(this._item);

  bool get isMovie => _item is Movie;

  bool get isTVShow => _item is TVShow;

  String get tmdbId => _item.tmdbId;

  String get title => _item.title;

  String get overview {
    return _item.overview ?? '暂无简介';
  }

  String get backdropUrl {
    return _item.backdropUrl ?? '';
  }

  String get posterUrl {
    return _item.posterUrl ?? '';
  }

  String? get logoUrl {
    return _item.logoUrl;
  }

  List<String> get genres {
    return _item.genres;
  }

  double get rating {
    return _item.rating;
  }

  int? get releaseYear {
    return _item.releaseYear;
  }

  String? get certification {
    return _item.certification;
  }

  List<Artist> get cast {
    return _item.cast;
  }

  Movie? get movie => _item is Movie ? _item : null;

  TVShow? get tvShow => _item is TVShow ? _item : null;

  /// 仅 TVShow 有效
  List<Season> get seasons {
    return tvShow?.seasons ?? const [];
  }
}
