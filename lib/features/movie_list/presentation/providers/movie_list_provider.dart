import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/entities/movie.dart';
import '../../../../core/providers/app_providers.dart';

enum MovieListStatus { initial, loading, success, error }

enum SortOption { rating, titleAZ, newest, oldest }

class MovieListState {
  final List<Movie> movies;
  final List<Movie> displayedMovies;
  final MovieListStatus status;
  final String? errorMessage;
  final bool hasMore;
  final int currentPage;
  final String? selectedGenre;
  final SortOption sortOption;

  static const int pageSize = 10;

  const MovieListState({
    this.movies = const [],
    this.displayedMovies = const [],
    this.status = MovieListStatus.initial,
    this.errorMessage,
    this.hasMore = true,
    this.currentPage = 0,
    this.selectedGenre,
    this.sortOption = SortOption.rating,
  });

  MovieListState copyWith({
    List<Movie>? movies,
    List<Movie>? displayedMovies,
    MovieListStatus? status,
    String? errorMessage,
    bool? hasMore,
    int? currentPage,
    String? selectedGenre,
    SortOption? sortOption,
    bool clearGenre = false,
  }) {
    return MovieListState(
      movies: movies ?? this.movies,
      displayedMovies: displayedMovies ?? this.displayedMovies,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      selectedGenre: clearGenre ? null : selectedGenre ?? this.selectedGenre,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  List<String> get allGenres {
    final genres = movies.expand((m) => m.genres).toSet().toList();
    genres.sort();
    return genres;
  }
}

class MovieListNotifier extends Notifier<MovieListState> {
  @override
  MovieListState build() => const MovieListState();

  Future<void> loadMovies() async {
    state = state.copyWith(status: MovieListStatus.loading);
    try {
      final getMovies = ref.read(getMoviesProvider);
      final movies = await getMovies();
      final filtered = _applyFilterAndSort(
        movies,
        state.selectedGenre,
        state.sortOption,
      );
      final initial = filtered.take(MovieListState.pageSize).toList();
      state = state.copyWith(
        movies: movies,
        displayedMovies: initial,
        status: MovieListStatus.success,
        currentPage: 1,
        hasMore: filtered.length > MovieListState.pageSize,
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
    final filtered = _applyFilterAndSort(
      state.movies,
      state.selectedGenre,
      state.sortOption,
    );
    final nextPage = state.currentPage + 1;
    final end = nextPage * MovieListState.pageSize;
    final next = filtered.take(end).toList();
    state = state.copyWith(
      displayedMovies: next,
      currentPage: nextPage,
      hasMore: end < filtered.length,
    );
  }

  void setGenre(String? genre) {
    final filtered = _applyFilterAndSort(
      state.movies,
      genre,
      state.sortOption,
    );
    final initial = filtered.take(MovieListState.pageSize).toList();
    state = state.copyWith(
      displayedMovies: initial,
      currentPage: 1,
      hasMore: filtered.length > MovieListState.pageSize,
      selectedGenre: genre,
      clearGenre: genre == null,
    );
  }

  void setSort(SortOption sort) {
    final filtered = _applyFilterAndSort(
      state.movies,
      state.selectedGenre,
      sort,
    );
    final initial = filtered.take(MovieListState.pageSize).toList();
    state = state.copyWith(
      displayedMovies: initial,
      currentPage: 1,
      hasMore: filtered.length > MovieListState.pageSize,
      sortOption: sort,
    );
  }

  Future<void> refresh() async {
    state = const MovieListState();
    await loadMovies();
  }

  List<Movie> _applyFilterAndSort(
    List<Movie> movies,
    String? genre,
    SortOption sort,
  ) {
    var result = genre != null
        ? movies.where((m) => m.genres.contains(genre)).toList()
        : List<Movie>.from(movies);

    switch (sort) {
      case SortOption.rating:
        result.sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
      case SortOption.titleAZ:
        result.sort((a, b) => a.title.compareTo(b.title));
      case SortOption.newest:
        result.sort((a, b) => b.releaseDate.compareTo(a.releaseDate));
      case SortOption.oldest:
        result.sort((a, b) => a.releaseDate.compareTo(b.releaseDate));
    }

    return result;
  }
}

final movieListProvider =
    NotifierProvider<MovieListNotifier, MovieListState>(MovieListNotifier.new);