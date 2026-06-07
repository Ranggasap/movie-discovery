class Movie {
  final int id;
  final String title;
  final String overview;
  final String releaseDate;
  final double voteAverage;
  final int runtime;
  final List<String> genres;
  final String posterUrl;
  final String backdropUrl;

  const Movie({
      required this.id,
      required this.title,
      required this.overview,
      required this.releaseDate,
      required this.voteAverage,
      required this.runtime,
      required this.genres,
      required this.posterUrl,
      required this.backdropUrl,
  });

  String get releaseYear => releaseDate.split('-').first;
}