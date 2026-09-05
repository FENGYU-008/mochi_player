class TmdbSearchMatcher {
  const TmdbSearchMatcher();

  /// The search plan supplies one complete, cleaned title. TMDB's own search
  /// ranking is authoritative for that request; do not rescore fragments.
  Map<String, dynamic>? findBest(List<dynamic> results, String query, {required bool isTV}) {
    for (final item in results) {
      if (item is Map<String, dynamic>) return item;
    }
    return null;
  }
}
