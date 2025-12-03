class Property {
  final int? id;
  final int userId;
  final String title;
  final String description;
  final double price;
  final String type; // 'rent' or 'sale'
  final double latitude;
  final double longitude;
  final String? photos; // Comma-separated photo paths
  final DateTime createdAt;

  Property({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.price,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.photos,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'price': price,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'photos': photos,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Property.fromMap(Map<String, dynamic> map) {
    return Property(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
      type: map['type'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      photos: map['photos'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  List<String> getPhotoList() {
    if (photos == null || photos!.isEmpty) return [];
    return photos!.split(',');
  }

  Property copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    double? price,
    String? type,
    double? latitude,
    double? longitude,
    String? photos,
    DateTime? createdAt,
  }) {
    return Property(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      type: type ?? this.type,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photos: photos ?? this.photos,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
