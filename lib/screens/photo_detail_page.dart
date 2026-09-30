import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/photo_model.dart';
import '../services/saved_service.dart';

class PhotoDetailPage extends StatefulWidget {
  final PhotoModel photo;

  const PhotoDetailPage({
    super.key,
    required this.photo,
  });

  @override
  State<PhotoDetailPage> createState() => _PhotoDetailPageState();
}

class _PhotoDetailPageState extends State<PhotoDetailPage>
    with SingleTickerProviderStateMixin {
  final SavedService _savedService = SavedService.instance;

  bool _isSaved = false;
  late final AnimationController _saveController;
late final Animation<double> _saveScaleAnimation;

  @override
  void initState() {
    super.initState();

    _isSaved = _savedService.isSaved(widget.photo.id);

    _saveController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 300),
);

_saveScaleAnimation = TweenSequence<double>([
  TweenSequenceItem(
    tween: Tween(begin: 1.0, end: 1.18),
    weight: 50,
  ),
  TweenSequenceItem(
    tween: Tween(begin: 1.18, end: 1.0),
    weight: 50,
  ),
]).animate(
  CurvedAnimation(
    parent: _saveController,
    curve: Curves.easeOut,
  ),
);

    _savedService.addListener(_updateSavedState);
  }

  @override
void dispose() {
  _savedService.removeListener(_updateSavedState);
  _saveController.dispose();
  super.dispose();
}

  void _updateSavedState() {
    if (!mounted) return;

    setState(() {
      _isSaved = _savedService.isSaved(widget.photo.id);
    });
  }

  Future<void> _toggleSave() async {
    _saveController.forward(from: 0);

    await _savedService.toggleSave(widget.photo);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isSaved
              ? 'Photo saved'
              : 'Photo removed from saved',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _sharePhoto() async {
    await SharePlus.instance.share(
      ShareParams(
        text:
            'Photo by ${widget.photo.photographer}\n${widget.photo.originalUrl}',
        subject: 'Photo from Pexels',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _sharePhoto,
                    icon: const Icon(Icons.ios_share_rounded),
                  ),
                ],
              ),
            ),

            // Large photo
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CachedNetworkImage(
                    imageUrl: widget.photo.originalUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    errorWidget: (context, url, error) {
                      return const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 48,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Bottom information section
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Photographer',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      widget.photo.photographer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    const Spacer(),

                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _toggleSave,
                            icon: ScaleTransition(
  scale: _saveScaleAnimation,
  child: Icon(
    _isSaved
        ? Icons.bookmark
        : Icons.bookmark_border,
  ),
),
                            label: Text(
                              _isSaved
                                  ? 'Saved'
                                  : 'Save Photo',
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        OutlinedButton(
                          onPressed: _sharePhoto,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 15,
                            ),
                          ),
                          child: const Icon(
                            Icons.share_rounded,
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
    );
  }
}