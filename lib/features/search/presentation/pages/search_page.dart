import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/entities/movie.dart';
import '../../../detail/presentation/pages/detail_page.dart';
import '../providers/search_provider.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(searchProvider.notifier).search(query);
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchProvider.notifier).clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: _buildSearchBar(state),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildSearchBar(SearchState state) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search movies...',
          border: InputBorder.none,
          suffixIcon: state.query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : null,
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildBody(SearchState state) {
    switch (state.status) {
      case SearchStatus.initial:
        return _buildInitialState();

      case SearchStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case SearchStatus.empty:
        return _buildEmptyState(state.query);

      case SearchStatus.error:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text('Something went wrong'),
            ],
          ),
        );

      case SearchStatus.success:
        return _buildResults(state.results);
    }
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_filter_outlined,
            size: 72,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 16),
          Text(
            'Find your next watch',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search by movie title',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 72,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 16),
          Text(
            'No results for "$query"',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different keyword',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(List<Movie> movies) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return _SearchMovieCard(movie: movie);
      },
    );
  }
}

class _SearchMovieCard extends StatelessWidget {
  final Movie movie;

  const _SearchMovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailPage(movie: movie)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                movie.posterUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: Colors.grey[900],
                  child: const Icon(
                    Icons.movie,
                    size: 48,
                    color: Colors.white24,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 160,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: [0.0, 0.6, 1.0],
                      colors: [
                        Colors.black,
                        Colors.black54,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        movie.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 12,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            movie.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            movie.releaseYear,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}