import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/photo_model.dart';

class SavedService extends ChangeNotifier {
  static final SavedService instance = SavedService._internal();

  SavedService._internal();

  final Map<int, PhotoModel> _savedPhotos = {};

  bool _isInitialized = false;

  List<PhotoModel> get savedPhotos => _savedPhotos.values.toList();

  bool isSaved(int photoId) {
    return _savedPhotos.containsKey(photoId);
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _isInitialized = true;
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    final key = 'saved_photos_${user.uid}';
    final savedData = prefs.getStringList(key) ?? [];

    _savedPhotos.clear();

    for (final item in savedData) {
      final json = jsonDecode(item) as Map<String, dynamic>;
      final photo = PhotoModel.fromJson(json);
      _savedPhotos[photo.id] = photo;
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> toggleSave(PhotoModel photo) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();

    final key = 'saved_photos_${user.uid}';

    if (_savedPhotos.containsKey(photo.id)) {
      _savedPhotos.remove(photo.id);
    } else {
      _savedPhotos[photo.id] = photo;
    }

    final data = _savedPhotos.values
        .map(
          (photo) => jsonEncode({
            'id': photo.id,
            'width': photo.width,
            'height': photo.height,
            'photographer': photo.photographer,
            'src': {
              'medium': photo.photoUrl,
              'original': photo.originalUrl,
            },
          }),
        )
        .toList();

    await prefs.setStringList(key, data);

    notifyListeners();
  }

  Future<void> clearForLogout() async {
    _savedPhotos.clear();
    _isInitialized = false;
    notifyListeners();
  }
}