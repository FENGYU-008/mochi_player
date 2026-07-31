import 'artist.dart';

/// A library item that can be rendered and opened by the shared media UI.
abstract interface class LibraryItem {
  String get tmdbId;
  String get title;
  String? get originalTitle;
  int? get releaseYear;
  String? get posterUrl;
  String? get backdropUrl;
  String? get logoUrl;
  String? get overview;
  String? get certification;
  double get rating;
  List<String> get genres;
  List<Artist> get cast;
}
