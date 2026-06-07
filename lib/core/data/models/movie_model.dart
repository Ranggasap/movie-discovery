import '../../domain/entities/movie.dart';

class MovieModel extends Movie {
  const MovieModel({
    required super.id,
    required super.title,
    required super.overview,
    required super.releaseDate,
    required super.voteAverage,
    required super.runtime,
    required super.genres,
    required super.posterUrl,
    required super.backdropUrl,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int,
      title: json['title'] as String,
      overview: json['overview'] as String,
      releaseDate: json['release_date'] as String,
      voteAverage: (json['vote_average'] as num).toDouble(),
      runtime: json['runtime'] as int,
      genres: List<String>.from(json['genres'] as List),
      posterUrl: json['poster_url'] as String,
      backdropUrl: json['backdrop_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'release_date': releaseDate,
      'vote_average': voteAverage,
      'runtime': runtime,
      'genres': genres,
      'poster_url': posterUrl,
      'backdrop_url': backdropUrl,
    };
  }
}