import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_discovery/core/data/datasources/movie_local_datasource.dart';
import 'package:movie_discovery/core/data/models/movie_model.dart';
import 'package:movie_discovery/core/data/repositories/movie_repository_impl.dart';
import 'package:movie_discovery/core/domain/entities/movie.dart';

class MockMovieLocalDataSource extends Mock implements MovieLocalDataSource {}

const tMovieModel = MovieModel(
  id: 1,
  title: 'Inception',
  overview: 'A dream within a dream.',
  releaseDate: '2010-07-16',
  voteAverage: 8.8,
  runtime: 148,
  genres: ['Action', 'Sci-Fi'],
  posterUrl: 'https://picsum.photos/seed/inception/500/750',
  backdropUrl: 'https://picsum.photos/seed/inception-bd/1280/720',
);

const tMovieList = [tMovieModel];

void main() {
  late MovieRepositoryImpl repository;
  late MockMovieLocalDataSource mockDataSource;

  setUpAll(() {
    registerFallbackValue(tMovieModel);
  });

  setUp(() {
    mockDataSource = MockMovieLocalDataSource();
    repository = MovieRepositoryImpl(mockDataSource);
  });

  group('getMovies', () {
    test(
      'should return list of movies when datasource succeeds',
      () async {
        when(() => mockDataSource.getMovies())
            .thenAnswer((_) async => tMovieList);

        final result = await repository.getMovies();

        expect(result, isA<List<Movie>>());
        expect(result.length, 1);
        expect(result.first.title, 'Inception');
        verify(() => mockDataSource.getMovies()).called(1);
      },
    );

    test(
      'should throw exception when datasource fails',
      () async {
        when(() => mockDataSource.getMovies())
            .thenThrow(Exception('Failed to load movies'));

        expect(
          () async => repository.getMovies(),
          throwsException,
        );
        verify(() => mockDataSource.getMovies()).called(1);
      },
    );
  });

  group('searchMovies', () {
    test(
      'should return filtered movies matching query',
      () async {
        when(() => mockDataSource.getMovies())
            .thenAnswer((_) async => tMovieList);

        final result = await repository.searchMovies('Inception');

        expect(result.length, 1);
        expect(result.first.title, 'Inception');
      },
    );

    test(
      'should return empty list when no movies match query',
      () async {
        when(() => mockDataSource.getMovies())
            .thenAnswer((_) async => tMovieList);

        final result = await repository.searchMovies('NonExistentMovie');

        expect(result, isEmpty);
      },
    );

    test(
      'should return all movies when query is empty',
      () async {
        when(() => mockDataSource.getMovies())
            .thenAnswer((_) async => tMovieList);

        final result = await repository.searchMovies('');

        expect(result.length, tMovieList.length);
      },
    );
  });

  group('favorites', () {
    test(
      'should call addFavorite on datasource with correct model',
      () async {
        when(() => mockDataSource.addFavorite(any()))
            .thenAnswer((_) async {});

        await repository.addFavorite(tMovieModel);

        verify(() => mockDataSource.addFavorite(any())).called(1);
      },
    );

    test(
      'should return favorites from datasource',
      () async {
        when(() => mockDataSource.getFavorites())
            .thenAnswer((_) async => tMovieList);

        final result = await repository.getFavorites();

        expect(result.length, 1);
        expect(result.first.title, 'Inception');
      },
    );

    test(
      'should call removeFavorite with correct id',
      () async {
        when(() => mockDataSource.removeFavorite(any()))
            .thenAnswer((_) async {});

        await repository.removeFavorite(1);

        verify(() => mockDataSource.removeFavorite(1)).called(1);
      },
    );
  });
}