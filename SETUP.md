# Estate App - Real Estate Platform

A comprehensive Flutter mobile application for a real estate platform with SQLite local database storage.

## Features

### 1. Authentication
- User registration with email and password
- Secure login with hashed passwords (SHA-256)
- Profile management (update name, email, profile picture)
- Password change functionality

### 2. Property Management
- Add new properties with details (title, description, price, type)
- Update existing properties
- Delete properties
- View all properties in a scrollable list
- Each property includes:
  - Title and description
  - Price
  - Type (rent/sale)
  - Location (latitude/longitude)
  - Multiple photos
  - Google Maps integration for location selection

### 3. Home Page
- Display all properties in an attractive card layout
- Property thumbnail, title, price, type, and location
- Filter properties by:
  - Price range (min/max)
  - Location
  - Type (rent/sale)
- Pull-to-refresh functionality

### 4. Messaging System
- Chat with property owners
- View chat history
- Real-time message list
- Unread message indicators
- SQLite-based message storage

### 5. Favorites
- Add properties to favorites
- Remove from favorites
- View all favorite properties
- Quick access from profile

### 6. Modern UI/UX
- Clean and light design
- Material Design 3
- Responsive layouts
- Smooth animations
- Card-based layouts with rounded corners
- Bottom navigation bar
- Floating action button for quick actions

## Technology Stack

- **Framework**: Flutter
- **State Management**: Provider
- **Local Database**: SQLite (sqflite)
- **Maps**: Google Maps Flutter
- **Image Handling**: Image Picker
- **Security**: Crypto (password hashing)
- **Date Formatting**: Intl

## Setup Instructions

### Prerequisites
- Flutter SDK (>=3.9.2)
- Android Studio / Xcode for mobile development
- Google Maps API key

### Installation Steps

1. **Clone and Navigate**
   ```bash
   cd /home/elwess/Documents/ISET/estate_app
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Google Maps API**
   
   **For Android** (`android/app/src/main/AndroidManifest.xml`):
   Add inside `<application>` tag:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
   ```

   **For iOS** (`ios/Runner/AppDelegate.swift`):
   Add at the top:
   ```swift
   import GoogleMaps
   ```
   
   And in the `application` method:
   ```swift
   GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
   ```

4. **Configure Permissions**

   **Android** (`android/app/src/main/AndroidManifest.xml`):
   Add before `<application>`:
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
   <uses-permission android:name="android.permission.CAMERA"/>
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
   ```

   **iOS** (`ios/Runner/Info.plist`):
   Add:
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>We need your location to show properties near you</string>
   <key>NSCameraUsageDescription</key>
   <string>We need camera access to take property photos</string>
   <key>NSPhotoLibraryUsageDescription</key>
   <string>We need photo library access to select property images</string>
   ```

5. **Run the App**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point with providers setup
├── models/                   # Data models
│   ├── user.dart
│   ├── property.dart
│   ├── favorite.dart
│   └── message.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── property_provider.dart
│   ├── favorite_provider.dart
│   └── message_provider.dart
├── screens/                  # UI screens
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen.dart
│   ├── profile_screen.dart
│   ├── add_property_screen.dart
│   ├── property_detail_screen.dart
│   ├── favorites_screen.dart
│   ├── chat_list_screen.dart
│   └── chat_screen.dart
└── services/                 # Database and services
    └── database_helper.dart
```

## Database Schema

### Users Table
- id (Primary Key)
- name
- email (Unique)
- password_hash
- profile_picture
- created_at

### Properties Table
- id (Primary Key)
- user_id (Foreign Key → Users)
- title
- description
- price
- type (rent/sale)
- latitude
- longitude
- photos (comma-separated paths)
- created_at

### Favorites Table
- id (Primary Key)
- user_id (Foreign Key → Users)
- property_id (Foreign Key → Properties)
- created_at
- Unique constraint on (user_id, property_id)

### Messages Table
- id (Primary Key)
- sender_id (Foreign Key → Users)
- receiver_id (Foreign Key → Users)
- property_id (Foreign Key → Properties)
- content
- is_read
- created_at

## Usage Guide

1. **Register/Login**
   - Launch the app
   - Create a new account or login with existing credentials

2. **Browse Properties**
   - View all available properties on the home screen
   - Use filters to narrow down results
   - Tap on a property to view details

3. **Add Property**
   - Tap the floating action button (+) on home screen
   - Fill in property details
   - Select location on map
   - Add photos
   - Save property

4. **Favorites**
   - Tap the heart icon on any property to favorite it
   - Access favorites from your profile

5. **Messaging**
   - Tap "Contact Owner" on property details
   - Send messages to property owners
   - View all conversations in Messages tab

6. **Profile Management**
   - Access profile from bottom navigation
   - Update name, email, and profile picture
   - View your properties and favorites

## Development Notes

- **State Management**: Uses Provider for reactive state management
- **Database**: SQLite for local data persistence with proper relationships
- **Security**: Passwords are hashed using SHA-256
- **Navigation**: Bottom navigation bar for main sections
- **Form Validation**: Comprehensive validation on all input forms
- **Error Handling**: Try-catch blocks with user feedback

## Future Enhancements

- Cloud storage for images
- Push notifications for messages
- Property search by address
- Advanced filtering options
- User ratings and reviews
- Payment integration
- Property booking system

## Troubleshooting

**Issue**: Google Maps not showing
- Ensure you have a valid Google Maps API key
- Check that the API key is properly configured in platform-specific files
- Enable Maps SDK for Android/iOS in Google Cloud Console

**Issue**: Images not loading
- Check camera and storage permissions
- Ensure the device has sufficient storage

**Issue**: Database errors
- Clear app data and reinstall
- Check SQLite version compatibility

## License

This project is created for educational purposes.

## Support

For issues or questions, please contact the development team.
