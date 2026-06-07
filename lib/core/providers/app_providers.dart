import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/movie_local_datasource.dart';
import '../data/repositories/movie_repository_impl.dart';
import '../domain/repositories/movie_repository.dart';
import '../domain/usecases/get_movies.dart';
import '../domain/usecases/manage_favorites.dart';
import '../domain/usecases/search_movies.dart';

final movieLocalDataSourceProvider = Provider<MovieLocalDataSource>((ref) {
  return MovieLocalDataSourceImpl();
});

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  final dataSource = ref.watch(movieLocalDataSourceProvider);
  return MovieRepositoryImpl(dataSource);
});

final getMoviesProvider = Provider<GetMovies>((ref) {
  return GetMovies(ref.watch(movieRepositoryProvider));
});

final searchMoviesProvider = Provider<SearchMovies>((ref) {
  return SearchMovies(ref.watch(movieRepositoryProvider));
});

final getFavoritesProvider = Provider<GetFavorites>((ref) {
  return GetFavorites(ref.watch(movieRepositoryProvider));
});

final addFavoriteProvider = Provider<AddFavorite>((ref) {
  return AddFavorite(ref.watch(movieRepositoryProvider));
});

final removeFavoriteProvider = Provider<RemoveFavorite>((ref) {
  return RemoveFavorite(ref.watch(movieRepositoryProvider));
});