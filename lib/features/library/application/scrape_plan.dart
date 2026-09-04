import 'package:mochi_player/features/library/application/scrape_candidate.dart';

/// An ordered, observable set of provider requests for one local candidate.
///
/// This is deliberately data-only: it decides neither which provider result
/// wins nor how metadata is written to the database.
class ScrapePlan {
  const ScrapePlan(this.attempts);

  final List<ScrapeSearchAttempt> attempts;
}

class ScrapeSearchAttempt {
  const ScrapeSearchAttempt({required this.query, this.year});

  final String query;
  final int? year;
}

/// The sole home of the automatic title-search rule.
///
/// Rule: search the complete cleaned local title with its parsed year. Only
/// when that request returns no result, retry the same title without a year.
class ScrapePlanFactory {
  const ScrapePlanFactory();

  ScrapePlan createTitleSearchPlan(ScrapeCandidate candidate) {
    final query = candidate.title.trim();
    if (query.isEmpty) return const ScrapePlan([]);

    return ScrapePlan([
      ScrapeSearchAttempt(query: query, year: candidate.year),
      if (candidate.year != null) ScrapeSearchAttempt(query: query),
    ]);
  }
}
