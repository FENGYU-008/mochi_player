abstract final class TmdbImageUrl {
  static const _posterBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const _backdropBaseUrl = 'https://image.tmdb.org/t/p/w1280';
  static const _profileBaseUrl = 'https://image.tmdb.org/t/p/w185';
  static const _logoBaseUrl = 'https://image.tmdb.org/t/p/w500';

  static String? poster(String? path) => _build(_posterBaseUrl, path);
  static String? backdrop(String? path) => _build(_backdropBaseUrl, path);
  static String? profile(String? path) => _build(_profileBaseUrl, path);
  static String? logo(String? path) => _build(_logoBaseUrl, path);

  static String? _build(String baseUrl, String? path) {
    if (path == null || path.isEmpty) return null;
    return '$baseUrl$path';
  }
}
