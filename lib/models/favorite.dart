class Favorite {
  final int? id;
  final int userId;
  final int propertyId;
  final DateTime createdAt;

  Favorite({
    this.id,
    required this.userId,
    required this.propertyId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'property_id': propertyId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      propertyId: map['property_id'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
