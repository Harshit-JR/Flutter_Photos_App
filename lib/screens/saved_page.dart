import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../services/saved_service.dart';
import '../widgets/photo_card.dart';
import 'photo_detail_page.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  final SavedService _savedService = SavedService.instance;

  @override
  void initState() {
    super.initState();

    _savedService.addListener(_onSavedChanged);
  }

  @override
  void dispose() {
    _savedService.removeListener(_onSavedChanged);
    super.dispose();
  }

  void _onSavedChanged() {
    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final savedPhotos = _savedService.savedPhotos;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Saved',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: savedPhotos.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bookmark_border_rounded,
                    size: 56,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No saved photos yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Save photos you love and find them here.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : MasonryGridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemCount: savedPhotos.length,
              itemBuilder: (context, index) {
                final photo = savedPhotos[index];

                return PhotoCard(
                  photo: photo,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoDetailPage(
                          photo: photo,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}