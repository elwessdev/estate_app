# Estate App - Quick Reference Guide

## 📱 App Structure

### Navigation Flow
```
LoginScreen
    ├─→ RegisterScreen
    └─→ HomeScreen (Bottom Nav)
            ├─→ Home Tab
            │   ├─→ PropertyDetailScreen
            │   │   └─→ ChatScreen
            │   └─→ AddPropertyScreen
            ├─→ Messages Tab (ChatListScreen)
            │   └─→ ChatScreen
            └─→ Profile Tab (ProfileScreen)
                ├─→ FavoritesScreen
                └─→ MyPropertiesScreen
```

## 🗄️ Database Tables

### Users
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  profile_picture TEXT,
  created_at TEXT NOT NULL
);
```

### Properties
```sql
CREATE TABLE properties (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  price REAL NOT NULL,
  type TEXT NOT NULL,  -- 'rent' or 'sale'
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  photos TEXT,  -- comma-separated paths
  created_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);
```

### Favorites
```sql
CREATE TABLE favorites (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  property_id INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  FOREIGN KEY (property_id) REFERENCES properties (id) ON DELETE CASCADE,
  UNIQUE(user_id, property_id)
);
```

### Messages
```sql
CREATE TABLE messages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sender_id INTEGER NOT NULL,
  receiver_id INTEGER NOT NULL,
  property_id INTEGER NOT NULL,
  content TEXT NOT NULL,
  is_read INTEGER DEFAULT 0,
  created_at TEXT NOT NULL,
  FOREIGN KEY (sender_id) REFERENCES users (id) ON DELETE CASCADE,
  FOREIGN KEY (receiver_id) REFERENCES users (id) ON DELETE CASCADE,
  FOREIGN KEY (property_id) REFERENCES properties (id) ON DELETE CASCADE
);
```

## 🔑 Key Classes

### Providers
- **AuthProvider**: User authentication, registration, login, profile updates
- **PropertyProvider**: Property CRUD, filtering, searching
- **FavoriteProvider**: Favorite management, toggle favorites
- **MessageProvider**: Chat functionality, load conversations

### Models
- **User**: id, name, email, passwordHash, profilePicture, createdAt
- **Property**: id, userId, title, description, price, type, lat, lng, photos, createdAt
- **Favorite**: id, userId, propertyId, createdAt
- **Message**: id, senderId, receiverId, propertyId, content, isRead, createdAt

## 🎨 Theme Configuration

```dart
ColorScheme: Blue-based
Card Radius: 12px
Input Radius: 12px
Button Radius: 12px
Material Design: 3
```

## 📝 Common Tasks

### Add a New Screen
1. Create file in `lib/screens/`
2. Import necessary providers
3. Use `Consumer` or `Provider.of()` for state
4. Add navigation from existing screen

### Add a Database Table
1. Update `database_helper.dart` `_createDB` method
2. Create model in `lib/models/`
3. Add CRUD methods in `DatabaseHelper`
4. Create provider if needed

### Add a New Feature
1. Define model (if needed)
2. Update database schema
3. Create/update provider
4. Create UI screen
5. Add navigation

## 🔧 Debug Commands

```bash
# Get dependencies
flutter pub get

# Run analyzer
flutter analyze

# Run app
flutter run

# Clean build
flutter clean && flutter pub get

# Check outdated packages
flutter pub outdated
```

## 🐛 Common Issues

### Google Maps Not Showing
- Check API key is added correctly
- Verify Maps SDK is enabled in Google Cloud
- Ensure location permissions are granted

### Images Not Displaying
- Check file path is correct
- Verify storage permissions
- Ensure file exists on device

### Database Errors
- Clear app data
- Check foreign key constraints
- Verify table creation

## 📲 Platform-Specific Setup

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>

<application>
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_API_KEY"/>
</application>
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location needed for property search</string>
<key>NSCameraUsageDescription</key>
<string>Camera needed for property photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Photo library needed for property images</string>
```

## 🎯 Testing Scenarios

1. **User Registration**
   - Valid email and password
   - Duplicate email (should fail)
   - Weak password (should fail)

2. **Property Management**
   - Add property with all fields
   - Add property without photos
   - Edit existing property
   - Delete property

3. **Filters**
   - Filter by type only
   - Filter by price range only
   - Combine multiple filters
   - Clear filters

4. **Messaging**
   - Send message to property owner
   - Receive messages
   - Multiple conversations
   - Mark as read

5. **Favorites**
   - Add to favorites
   - Remove from favorites
   - View favorites list

## 💡 Pro Tips

- Use `Provider.of<T>(context, listen: false)` for one-time reads
- Use `Consumer<T>` or `context.watch<T>()` for reactive updates
- Always handle null cases for database queries
- Use async/await for database operations
- Validate forms before submitting
- Show loading indicators during async operations
- Provide user feedback with SnackBars

## 📚 Resources

- [Flutter Docs](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [Sqflite Package](https://pub.dev/packages/sqflite)
- [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter)

---

**Version**: 1.0.0  
**Last Updated**: December 2025
