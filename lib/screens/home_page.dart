import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'photo_detail_page.dart';
import '../models/photo_model.dart';
import '../services/pexels_service.dart';
import '../widgets/photo_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PexelsService _pexelsService = PexelsService();
  final ScrollController _scrollController = ScrollController();

  final List<PhotoModel> _photos = [];

  int _currentPage = 1;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  String? _errorMessage;
  String? _loadMoreError;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    _loadPhotos();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;

    // Start loading the next page shortly before reaching the bottom.
    if (position.maxScrollExtent - position.pixels < 500) {
      _loadMorePhotos();
    }
  }

  Future<void> _loadPhotos() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final photos = await _pexelsService.getCuratedPhotos(
        page: 1,
        perPage: 20,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _photos
          ..clear()
          ..addAll(photos);

        _currentPage = 1;
        _hasMore = photos.isNotEmpty;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = 'Could not load photos.';
      });
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMorePhotos() async {
    if (_isLoadingMore || !_hasMore || _isLoading) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
      _loadMoreError = null;
    });

    final nextPage = _currentPage + 1;

    try {
      final photos = await _pexelsService.getCuratedPhotos(
        page: nextPage,
        perPage: 20,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _photos.addAll(photos);
        _currentPage = nextPage;

        if (photos.isEmpty) {
          _hasMore = false;
        }
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadMoreError = 'Could not load more photos.';
      });
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _refreshPhotos() async {
    _hasMore = true;
    _currentPage = 1;

    await _loadPhotos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Find something beautiful',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _refreshPhotos,
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _photos.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null && _photos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 52,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadPhotos,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_photos.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshPhotos,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Center(
              child: Text(
                'No photos found.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshPhotos,
      child: MasonryGridView.count(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: _photos.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _photos.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            );
          }

          final photo = _photos[index];

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