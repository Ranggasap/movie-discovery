import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie_model.dart';

abstract class MovieLocalDataSource {
  Future<List<MovieModel>> getMovies();
  Future<List<MovieModel>> getFavorites();
  Future<void> addFavorite(MovieModel movie);
  Future<void> removeFavorite(int movieId);
  Future<bool> isFavorite(int movieId);
}

class MovieLocalDataSourceImpl implements MovieLocalDataSource {
  static const _favoritesKey = 'favorite_movies';

  @override
  Future<List<MovieModel>> getMovies() async {
    final raw = await rootBundle.loadString('assets/data/movies.json');
    final List<dynamic> jsonList = json.decode(raw) as List;
    return jsonList
        .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MovieModel>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStrings = prefs.getStringList(_favoritesKey) ?? [];
    return jsonStrings
        .map((s) => MovieModel.fromJson(json.decode(s) as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addFavorite(MovieModel movie) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStrings = prefs.getStringList(_favoritesKey) ?? [];
    final updated = [...jsonStrings, json.encode(movie.toJson())];
    await prefs.setStringList(_favoritesKey, updated);
  }

  @override
  Future<void> removeFavorite(int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStrings = prefs.getStringList(_favoritesKey) ?? [];
    final updated = jsonStrings.where((s) {
      final decoded = json.decode(s) as Map<String, dynamic>;
      return decoded['id'] != movieId;
    }).toList();
    await prefs.setStringList(_favoritesKey, updated);
  }

  @override
  Future<bool> isFavorite(int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStrings = prefs.getStringList(_favoritesKey) ?? [];
    return jsonStrings.any((s) {
      final decoded = json.decode(s) as Map<String, dynamic>;
      return decoded['id'] == movieId;
    });
  }
}