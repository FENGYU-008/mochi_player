import 'package:flutter_test/flutter_test.dart';
import 'package:mochi_player/core/infrastructure/tmdb/tmdb_search_matcher.dart';

void main() {
  const matcher = TmdbSearchMatcher();

  test('prefers an exact title over a more popular partial match', () {
    final exact = {
      'id': 1,
      'title': 'Dune',
      'original_title': 'Dune',
      'popularity': 1,
    };
    final popularPartial = {
      'id': 2,
      'title': 'Dune: Part Two',
      'original_title': 'Dune: Part Two',
      'poster_path': '/poster.jpg',
      'popularity': 80,
    };

    expect(
      matcher.findBest([popularPartial, exact], 'Dune', isTV: false),
      same(exact),
    );
  });

  test('uses TV title fields when matching shows', () {
    final result = {
      'id': 3,
      'name': '进击的巨人',
      'original_name': 'Attack on Titan',
    };

    expect(
      matcher.findBest([result], 'Attack on Titan', isTV: true),
      same(result),
    );
  });
}
