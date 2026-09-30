import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../models/photo_model.dart';
import '../services/pexels_service.dart';
import '../widgets/photo_card.dart';
import 'photo_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final PexelsService _pexelsService = PexelsService();
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  List<PhotoModel> _photos = [];

  bool _isLoading = false;
  String? _errorMessage;

  String _lastQuery = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    // Wait for the user to pause typing.
    _debounce?.cancel();

    if (query.isEmpty) {
      setState(() {
        _photos = [];
        _errorMessage = null;
        _isLoading = false;
        _lastQuery = '';
      });
      return;
    }

    _debounce = Timer(
      const Duration(milliseconds: 500),
      () {
        _searchPhotos(query);
      },
    );
  }

  Future<void> _searchPhotos(String query) async {
    if (query == _lastQuery) {
      return;
    }

    _lastQuery = query;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final photos = await _pexelsService.searchPhotos(
        query: query,
        page: 1,
        perPage: 20,
      );

      if (!mounted) return;

      setState(() {
        _photos = photos;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _photos = [];
        _errorMessage = 'Could not search photos.';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _retrySearch() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) return;

    _lastQuery = '';

    await _searchPhotos(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Search',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildSearchBar() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    child: ValueListenableBuilder<TextEditingValue>(
      valueListenable: _searchController,
      builder: (context, value, child) {
        return TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search photos...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: value.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                    },
                    icon: const Icon(Icons.close_rounded),
                  )
                : null,
            filled: true,
            fillColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        );
      },
    ),
  );
}

  Widget _buildBody() {
    if (_isLoading && _photos.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
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
                onPressed: _retrySearch,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchController.text.trim().isNotEmpty && _photos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No photos found.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return _buildEmptySearchState();
  }

  Widget _buildEmptySearchState() {
    if (_photos.isNotEmpty) {
      return MasonryGridView.count(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: _photos.length,
        itemBuilder: (context, index) {
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
      );
    }

    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_rounded,
            size: 56,
          ),
          SizedBox(height: 12),
          Text(
            'Search for something beautiful',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Try nature, mountains, cities, or anything you like.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}