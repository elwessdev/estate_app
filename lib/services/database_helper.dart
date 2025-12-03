import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/property.dart';
import '../models/favorite.dart';
import '../models/message.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('estate_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Delete database (for debugging/testing purposes)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'estate_app.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    // Users table
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        name $textType,
        email $textType UNIQUE,
        password_hash $textType,
        profile_picture TEXT,
        created_at $textType
      )
    ''');

    // Properties table
    await db.execute('''
      CREATE TABLE properties (
        id $idType,
        user_id $integerType,
        title $textType,
        description $textType,
        price $realType,
        type $textType,
        latitude $realType,
        longitude $realType,
        photos TEXT,
        created_at $textType,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Favorites table
    await db.execute('''
      CREATE TABLE favorites (
        id $idType,
        user_id $integerType,
        property_id $integerType,
        created_at $textType,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (property_id) REFERENCES properties (id) ON DELETE CASCADE,
        UNIQUE(user_id, property_id)
      )
    ''');

    // Messages table
    await db.execute('''
      CREATE TABLE messages (
        id $idType,
        sender_id $integerType,
        receiver_id $integerType,
        property_id $integerType,
        content $textType,
        is_read INTEGER DEFAULT 0,
        created_at $textType,
        FOREIGN KEY (sender_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (receiver_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (property_id) REFERENCES properties (id) ON DELETE CASCADE
      )
    ''');
  }

  // User operations
  Future<int> createUser(User user) async {
    try {
      final db = await instance.database;
      return await db.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      // Rethrow the error to be caught by the provider
      throw Exception('Failed to create user: ${e.toString()}');
    }
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await instance.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Property operations
  Future<int> createProperty(Property property) async {
    final db = await instance.database;
    return await db.insert('properties', property.toMap());
  }

  Future<List<Property>> getAllProperties() async {
    final db = await instance.database;
    final maps = await db.query('properties', orderBy: 'created_at DESC');
    return maps.map((map) => Property.fromMap(map)).toList();
  }

  Future<List<Property>> getPropertiesByUser(int userId) async {
    final db = await instance.database;
    final maps = await db.query(
      'properties',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Property.fromMap(map)).toList();
  }

  Future<Property?> getPropertyById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'properties',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Property.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateProperty(Property property) async {
    final db = await instance.database;
    return await db.update(
      'properties',
      property.toMap(),
      where: 'id = ?',
      whereArgs: [property.id],
    );
  }

  Future<int> deleteProperty(int id) async {
    final db = await instance.database;
    return await db.delete(
      'properties',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Property>> searchProperties({
    double? minPrice,
    double? maxPrice,
    String? type,
  }) async {
    final db = await instance.database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (minPrice != null) {
      whereClause += 'price >= ?';
      whereArgs.add(minPrice);
    }

    if (maxPrice != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'price <= ?';
      whereArgs.add(maxPrice);
    }

    if (type != null && type.isNotEmpty) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'type = ?';
      whereArgs.add(type);
    }

    final maps = await db.query(
      'properties',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Property.fromMap(map)).toList();
  }

  // Favorite operations
  Future<int> addFavorite(Favorite favorite) async {
    final db = await instance.database;
    return await db.insert('favorites', favorite.toMap());
  }

  Future<int> removeFavorite(int userId, int propertyId) async {
    final db = await instance.database;
    return await db.delete(
      'favorites',
      where: 'user_id = ? AND property_id = ?',
      whereArgs: [userId, propertyId],
    );
  }

  Future<List<Property>> getFavoriteProperties(int userId) async {
    final db = await instance.database;
    final maps = await db.rawQuery('''
      SELECT p.* FROM properties p
      INNER JOIN favorites f ON p.id = f.property_id
      WHERE f.user_id = ?
      ORDER BY f.created_at DESC
    ''', [userId]);

    return maps.map((map) => Property.fromMap(map)).toList();
  }

  Future<bool> isFavorite(int userId, int propertyId) async {
    final db = await instance.database;
    final maps = await db.query(
      'favorites',
      where: 'user_id = ? AND property_id = ?',
      whereArgs: [userId, propertyId],
    );
    return maps.isNotEmpty;
  }

  // Message operations
  Future<int> createMessage(Message message) async {
    final db = await instance.database;
    return await db.insert('messages', message.toMap());
  }

  Future<List<Message>> getConversation(
      int userId, int otherUserId, int propertyId) async {
    final db = await instance.database;
    final maps = await db.query(
      'messages',
      where: '''
        property_id = ? AND 
        ((sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?))
      ''',
      whereArgs: [propertyId, userId, otherUserId, otherUserId, userId],
      orderBy: 'created_at ASC',
    );

    return maps.map((map) => Message.fromMap(map)).toList();
  }

  Future<List<Map<String, dynamic>>> getChatList(int userId) async {
    final db = await instance.database;
    // Get unique conversations with last message
    final maps = await db.rawQuery('''
      SELECT 
        m.*,
        p.title as property_title,
        u.name as other_user_name,
        u.profile_picture as other_user_picture,
        CASE 
          WHEN m.sender_id = ? THEN m.receiver_id 
          ELSE m.sender_id 
        END as other_user_id
      FROM messages m
      INNER JOIN properties p ON m.property_id = p.id
      INNER JOIN users u ON u.id = (
        CASE 
          WHEN m.sender_id = ? THEN m.receiver_id 
          ELSE m.sender_id 
        END
      )
      WHERE m.id IN (
        SELECT MAX(id) 
        FROM messages 
        WHERE sender_id = ? OR receiver_id = ?
        GROUP BY property_id, 
          CASE 
            WHEN sender_id = ? THEN receiver_id 
            ELSE sender_id 
          END
      )
      ORDER BY m.created_at DESC
    ''', [userId, userId, userId, userId, userId]);

    return maps;
  }

  Future<int> markMessagesAsRead(int userId, int senderId, int propertyId) async {
    final db = await instance.database;
    return await db.update(
      'messages',
      {'is_read': 1},
      where: 'receiver_id = ? AND sender_id = ? AND property_id = ? AND is_read = 0',
      whereArgs: [userId, senderId, propertyId],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
