/// Generates conservative TMDB search candidates from noisy release names.
///
/// File names often contain ranking prefixes and release descriptors that are
/// useful to users, but make an exact metadata search needlessly unreliable.
abstract final class MetadataSearchTitleVariants {
  static List<String> build(String title) {
    final variants = <String>[];
    final withoutBrackets = _withoutBrackets(title);
    final cleaned = _stripReleaseDecorations(withoutBrackets);

    // For a mixed-language title, a standalone original-language title is
    // usually much less ambiguous than the concatenated release name.
    final englishSegments = RegExp(r"[A-Za-z][A-Za-z0-9\s'-]*[A-Za-z0-9]")
        .allMatches(cleaned)
        .map((match) => match.group(0)!.trim())
        .where((segment) => !RegExp(r'^top\s*\d+$', caseSensitive: false).hasMatch(segment))
        .toList(growable: false);
    for (final segment in englishSegments) {
      _add(variants, segment);
    }

    _add(variants, title);
    _add(variants, withoutBrackets);
    _add(variants, cleaned);

    final zh = RegExp(
      r'[\u4e00-\u9fff\u3400-\u4dbf：，。！？]+',
    ).allMatches(cleaned).map((match) => match.group(0)!).join(' ').trim();
    _add(variants, zh);

    return variants;
  }

  static String _withoutBrackets(String value) {
    return value.replaceAll(RegExp(r'[\[\(（【][^\]\)）】]+[\]\)）】]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String _stripReleaseDecorations(String value) {
    return value
        .replaceFirst(RegExp(r'^(?:韩剧|美剧|日剧|英剧|台剧|国产剧|国剧|电视剧)\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'\btop\s*0*\d+\b', caseSensitive: false), ' ')
        .replaceAll(
          RegExp(r'特别加长版|导演剪辑(?:加长)?版|加长版|(?:数码)?修复版|CC标准收藏版|标准收藏版|(?:\d+)?周年纪念版|纪念版', caseSensitive: false),
          ' ',
        )
        .replaceAll(
          RegExp(
            r"\b(?:director(?:'|&#39;)?s cut|extended(?: cut| edition)?|special edition|anniversary edition|criterion collection|remastered|restored|collector(?:'|&#39;)?s edition|ultimate edition|unrated|theatrical cut)\b",
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(RegExp(r'\b(?:720p|1080p|2160p|4k|uhd)\b', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static void _add(List<String> variants, String value) {
    final normalized = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return;

    final key = _key(normalized);
    if (variants.any((item) => _key(item) == key)) return;
    variants.add(normalized);
  }

  static String _key(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[\s._\-:：，。/\\\\\(\)\[\]【】]+'), '');
  }
}
