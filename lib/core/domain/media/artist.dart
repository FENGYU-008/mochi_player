/// 演员 Domain Model
class Artist {
  final String? tmdbId;
  final String name;
  final String? character;
  final String? profileUrl;

  const Artist({
    this.tmdbId,
    required this.name,
    this.character,
    this.profileUrl,
  });
}
