class TmdbSearchMatcher {
  const TmdbSearchMatcher();

  Map<String, dynamic>? findBest(
    List<dynamic> results,
    String query, {
    required bool isTV,
  }) {
    Map<String, dynamic>? best;
    var bestScore = double.negativeInfinity;
    for (final item in results.whereType<Map<String, dynamic>>()) {
      final score = _score(item, query, isTV: isTV);
      if (score > bestScore) {
        best = item;
        bestScore = score;
      }
    }
    return best;
  }

  double _score(Map<String, dynamic> item, String query, {required bool isTV}) {
    final title = (isTV ? item['name'] : item['title'])?.toString() ?? '';
    final originalTitle =
        (isTV ? item['original_name'] : item['original_title'])?.toString() ??
        '';
    final queryKey = _normalize(query);
    final titleScore = _titleSimilarity(queryKey, _normalize(title));
    final originalTitleScore = _titleSimilarity(
      queryKey,
      _normalize(originalTitle),
    );
    var score = titleScore > originalTitleScore
        ? titleScore + originalTitleScore * 0.15
        : originalTitleScore + titleScore * 0.15;
    if (item['poster_path'] != null) score += 3;
    final popularity = (item['popularity'] as num?)?.toDouble() ?? 0;
    return score + popularity.clamp(0, 80) / 20;
  }

  double _titleSimilarity(String query, String candidate) {
    if (query.isEmpty || candidate.isEmpty) return 0;
    if (query == candidate) return 120;
    if (candidate.contains(query) || query.contains(candidate)) {
      final shortest = query.length < candidate.length
          ? query.length
          : candidate.length;
      final longest = query.length > candidate.length
          ? query.length
          : candidate.length;
      final ratio = shortest / longest;
      if (ratio >= 0.65) return 76;
      if (ratio >= 0.4) return 48;
      return 18;
    }
    final queryTokens = _tokenize(query);
    final candidateTokens = _tokenize(candidate);
    if (queryTokens.isEmpty || candidateTokens.isEmpty) return 0;
    final union = queryTokens.union(candidateTokens).length;
    if (union == 0) return 0;
    return queryTokens.intersection(candidateTokens).length / union * 55;
  }

  String _normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[\u3000\s._\-:：，。/\\\(\)\[\]【】]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  Set<String> _tokenize(String value) {
    final tokens = value
        .split(' ')
        .map((token) => token.trim())
        .where((token) => token.isNotEmpty);
    final cjk = RegExp(r'[\u4e00-\u9fff\u3400-\u4dbf]+')
        .allMatches(value)
        .map((match) => match.group(0)!)
        .where((token) => token.isNotEmpty);
    return {...tokens, ...cjk};
  }
}
