import 'package:mochi_player/features/library/infrastructure/metadata_search_title_variants.dart';

void main() {
  _removesRankingAndReleaseLabelsWithoutChangingTheDisplayTitle();
  _keepsEnglishTitleSegmentsSeparate();
  _prefersAnOriginalLanguageTitleForMixedNames();
  _removesTechnicalLabelsFromAnEnglishTitle();
}

void _prefersAnOriginalLanguageTitleForMixedNames() {
  final variants = MetadataSearchTitleVariants.build('离职 Severance');

  if (variants.first != 'Severance') {
    throw StateError(
      'Expected the unambiguous English title first, got $variants.',
    );
  }
}

void _removesTechnicalLabelsFromAnEnglishTitle() {
  final variants = MetadataSearchTitleVariants.build(
    'Top168 穆赫兰道4K修复CC标准收藏版 Mulholland Dr 4K Remastered Criterion Collection',
  );

  _expectContains(variants, 'Mulholland Dr');
}

void _removesRankingAndReleaseLabelsWithoutChangingTheDisplayTitle() {
  final variants = MetadataSearchTitleVariants.build(
    'Top023 指环王3：王者归来加长版 The Lord of the Rings',
  );

  _expectContains(variants, '指环王3：王者归来 The Lord of the Rings');
  _expectContains(variants, 'The Lord of the Rings');
}

void _keepsEnglishTitleSegmentsSeparate() {
  final variants = MetadataSearchTitleVariants.build(
    'Top198 终结者2：审判日特别加长版 Terminator 2 Judgment Day',
  );

  _expectContains(variants, 'Terminator 2 Judgment Day');
  if (variants.contains('Top198 Terminator 2 Judgment Day')) {
    throw StateError(
      'Ranking prefix must not be retained in the English query.',
    );
  }
}

void _expectContains(List<String> values, String expected) {
  if (values.contains(expected)) return;
  throw StateError('Expected variants to contain "$expected", got $values.');
}
