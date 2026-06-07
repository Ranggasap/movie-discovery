import 'package:flutter/material.dart';
import '../../../../core/domain/entities/movie.dart';

class DetailPage extends StatelessWidget {
  final Movie movie;
  const DetailPage({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(movie.title)),
      body: const Center(child: Text('Coming soon')),
    );
  }
}