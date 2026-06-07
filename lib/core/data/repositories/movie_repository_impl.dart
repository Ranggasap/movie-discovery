import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_local_datasource.dart';
import '../models/movie_model.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieLocalDataSource dataSource;

  MovieRepositoryImpl(this.dataSource);

  @override
  Future<List<Movie>> getMovies() async {
    return dataSource.getMovies();
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    final movies = await dataSource.getMovies();
    if (query.isEmpty) return movies;
    final lowerQuery = query.toLowerCase();
    return movies
        .where((m) => m.title.toLowerCase().contains(lowerQuery))
        .toList();
  }

  @override
  Future<List<Movie>> getFavorites() async {
    return dataSource.getFavorites();
  }

  @override
  Future<void> addFavorite(Movie movie) async {
    final model = MovieModel(
      id: movie.id,
      title: movie.title,
      overview: movie.overview,
      releaseDate: movie.releaseDate,
      voteAverage: movie.voteAverage,
      runtime: movie.runtime,
      genres: movie.genres,
      posterUrl: movie.posterUrl,
      backdropUrl: movie.backdropUrl,
    );
    await dataSource.addFavorite(model);
  }

  @override
  Future<void> removeFavorite(int movieId) async {
    await dataSource.removeFavorite(movieId);
  }

  @override
  Future<bool> isFavorite(int movieId) async {
    return dataSource.isFavorite(movieId);
  }
}