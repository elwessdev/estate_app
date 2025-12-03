class Message {
  final int? id;
  final int senderId;
  final int receiverId;
  final int propertyId;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  Message({
    this.id,
    required this.senderId,
    required this.receiverId,
    required this.propertyId,
    required this.content,
    DateTime? createdAt,
    this.isRead = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'property_id': propertyId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead ? 1 : 0,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as int?,
      senderId: map['sender_id'] as int,
      receiverId: map['receiver_id'] as int,
      propertyId: map['property_id'] as int,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      isRead: (map['is_read'] as int) == 1,
    );
  }

  Message copyWith({
    int? id,
    int? senderId,
    int? receiverId,
    int? propertyId,
    String? content,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      propertyId: propertyId ?? this.propertyId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
