import '../entities/movie.dart';

abstract class MovieRepository {
  Future<List<Movie>> getMovies();
  Future<List<Movie>> searchMovies(String query);
  Future<List<Movie>> getFavorites();
  Future<void> addFavorite(Movie movie);
  Future<void> removeFavorite(int movieId);
  Future<bool> isFavorite(int movieId);
}