class PhotoModel {
  final int id;
  final int width;
  final int height;
  final String photographer;
  final String photoUrl;
  final String originalUrl;

  PhotoModel({
    required this.id,
    required this.width,
    required this.height,
    required this.photographer,
    required this.photoUrl,
    required this.originalUrl,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'],
      width: json['width'],
      height: json['height'],
      photographer: json['photographer'] ?? 'Unknown photographer',
      photoUrl: json['src']['medium'],
      originalUrl: json['src']['original'],
    );
  }
}