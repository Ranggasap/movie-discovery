import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class GetFavorites {
  final MovieRepository repository;
  GetFavorites(this.repository);
  Future<List<Movie>> call() => repository.getFavorites();
}

class AddFavorite {
  final MovieRepository repository;
  AddFavorite(this.repository);
  Future<void> call(Movie movie) => repository.addFavorite(movie);
}

class RemoveFavorite {
  final MovieRepository repository;
  RemoveFavorite(this.repository);
  Future<void> call(int movieId) => repository.removeFavorite(movieId);
}

class CheckIsFavorite {
  final MovieRepository repository;
  CheckIsFavorite(this.repository);
  Future<bool> call(int movieId) => repository.isFavorite(movieId);
}