import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/entities/movie.dart';
import '../../../../core/providers/app_providers.dart';

enum MovieListStatus { initial, loading, success, error }

class MovieListState {
  final List<Movie> movies;
  final List<Movie> displayedMovies;
  final MovieListStatus status;
  final String? errorMessage;
  final bool hasMore;
  final int currentPage;

  static const int pageSize = 10;

  const MovieListState({
    this.movies = const [],
    this.displayedMovies = const [],
    this.status = MovieListStatus.initial,
    this.errorMessage,
    this.hasMore = true,
    this.currentPage = 0,
  });

  MovieListState copyWith({
    List<Movie>? movies,
    List<Movie>? displayedMovies,
    MovieListStatus? status,
    String? errorMessage,
    bool? hasMore,
    int? currentPage,
  }) {
    return MovieListState(
      movies: movies ?? this.movies,
      displayedMovies: displayedMovies ?? this.displayedMovies,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class MovieListNotifier extends Notifier<MovieListState> {
  @override
  MovieListState build() {
    return const MovieListState();
  }

  Future<void> loadMovies() async {
    state = state.copyWith(status: MovieListStatus.loading);
    try {
      final getMovies = ref.read(getMoviesProvider);
      final movies = await getMovies();
      final initial = movies.take(MovieListState.pageSize).toList();
      state = state.copyWith(
        movies: movies,
        displayedMovies: initial,
        status: MovieListStatus.success,
        currentPage: 1,
        hasMore: movies.length > MovieListState.pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        status: MovieListStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.status == MovieListStatus.loading) return;
    final nextPage = state.currentPage + 1;
    final end = nextPage * MovieListState.pageSize;
    final next = state.movies.take(end).toList();
    state = state.copyWith(
      displayedMovies: next,
      currentPage: nextPage,
      hasMore: end < state.movies.length,
    );
  }

  Future<void> refresh() async {
    state = const MovieListState();
    await loadMovies();
  }
}

final movieListProvider =
    NotifierProvider<MovieListNotifier, MovieListState>(MovieListNotifier.new);