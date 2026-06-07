import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/entities/movie.dart';
import '../../../../core/providers/app_providers.dart';

enum SearchStatus { initial, loading, success, error, empty }

class SearchState {
  final List<Movie> results;
  final SearchStatus status;
  final String query;

  const SearchState({
    this.results = const [],
    this.status = SearchStatus.initial,
    this.query = '',
  });

  SearchState copyWith({
    List<Movie>? results,
    SearchStatus? status,
    String? query,
  }) {
    return SearchState(
      results: results ?? this.results,
      status: status ?? this.status,
      query: query ?? this.query,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  Timer? _debounceTimer;

  @override
  SearchState build() => const SearchState();

  Future<void> search(String query) async {
    _debounceTimer?.cancel();
    state = state.copyWith(query: query, status: SearchStatus.loading);

    if (query.isEmpty) {
      state = state.copyWith(
        status: SearchStatus.initial,
        results: [],
      );
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      state = state.copyWith(status: SearchStatus.loading);
      try {
        final searchMovies = ref.read(searchMoviesProvider);
        final results = await searchMovies(query);
        state = state.copyWith(
          results: results,
          status:
              results.isEmpty ? SearchStatus.empty : SearchStatus.success,
        );
      } catch (e) {
        state = state.copyWith(status: SearchStatus.error);
      }
    });
  }

  void clear() {
    _debounceTimer?.cancel();
    state = const SearchState();
  }
}

final searchProvider =
    NotifierProvider<SearchNotifier, SearchState>(SearchNotifier.new);