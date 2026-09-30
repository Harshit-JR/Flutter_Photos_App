import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/pexels_config.dart';
import '../models/photo_model.dart';

class PexelsService {
  static const String baseUrl = 'https://api.pexels.com/v1';

  Future<List<PhotoModel>> getCuratedPhotos({
    required int page,
    int perPage = 20,
  }) async {
    if (PexelsConfig.apiKey.isEmpty ||
        PexelsConfig.apiKey == 'PASTE_YOUR_PEXELS_API_KEY_HERE') {
      throw Exception('Pexels API key is missing.');
    }

    final uri = Uri.parse(
      '$baseUrl/curated?page=$page&per_page=$perPage',
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': PexelsConfig.apiKey,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Pexels request failed: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    final photos = data['photos'] as List<dynamic>;

    return photos
        .map(
          (photo) => PhotoModel.fromJson(
            photo as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<PhotoModel>> searchPhotos({
  required String query,
  int page = 1,
  int perPage = 20,
}) async {
  if (PexelsConfig.apiKey.isEmpty ||
      PexelsConfig.apiKey == 'PASTE_YOUR_PEXELS_API_KEY_HERE') {
    throw Exception('Pexels API key is missing.');
  }

  final uri = Uri.parse(
    '$baseUrl/search?query=${Uri.encodeComponent(query)}'
    '&page=$page&per_page=$perPage',
  );

  final response = await http.get(
    uri,
    headers: {
      'Authorization': PexelsConfig.apiKey,
    },
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Pexels search failed: ${response.statusCode}',
    );
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;

  final photos = data['photos'] as List<dynamic>;

  return photos
      .map(
        (photo) => PhotoModel.fromJson(
          photo as Map<String, dynamic>,
        ),
      )
      .toList();
}
}