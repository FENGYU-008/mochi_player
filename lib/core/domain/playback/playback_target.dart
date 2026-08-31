/// A media location and the request headers required to open it.
class PlaybackTarget {
  final String url;
  final Map<String, String> httpHeaders;

  const PlaybackTarget({required this.url, this.httpHeaders = const {}});
}
