import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/entities/movie.dart';
import '../../../../core/providers/app_providers.dart';

class FavoritesNotifier extends Notifier<List<Movie>> {
  @override
  List<Movie> build() {
    _loadFavorites();
    return [];
  }

  Future<void> _loadFavorites() async {
    final getFavorites = ref.read(getFavoritesProvider);
    final favorites = await getFavorites();
    state = favorites;
  }

  Future<void> toggleFavorite(Movie movie) async {
    final isFav = state.any((m) => m.id == movie.id);
    if (isFav) {
      final removeFavorite = ref.read(removeFavoriteProvider);
      await removeFavorite(movie.id);
      state = state.where((m) => m.id != movie.id).toList();
    } else {
      final addFavorite = ref.read(addFavoriteProvider);
      await addFavorite(movie);
      state = [...state, movie];
    }
  }

  bool isFavorite(int movieId) {
    return state.any((m) => m.id == movieId);
  }
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, List<Movie>>(FavoritesNotifier.new);