import 'package:flutter/foundation.dart';
import '../models/property.dart';
import '../models/favorite.dart';
import '../services/database_helper.dart';

class FavoriteProvider with ChangeNotifier {
  List<Property> _favoriteProperties = [];
  Set<int> _favoriteIds = {};
  bool _isLoading = false;

  List<Property> get favoriteProperties => _favoriteProperties;
  bool get isLoading => _isLoading;

  bool isFavorite(int propertyId) {
    return _favoriteIds.contains(propertyId);
  }

  Future<void> loadFavorites(int userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _favoriteProperties =
          await DatabaseHelper.instance.getFavoriteProperties(userId);
      _favoriteIds = _favoriteProperties.map((p) => p.id!).toSet();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleFavorite(int userId, int propertyId) async {
    try {
      if (_favoriteIds.contains(propertyId)) {
        // Remove from favorites
        await DatabaseHelper.instance.removeFavorite(userId, propertyId);
        _favoriteIds.remove(propertyId);
        _favoriteProperties.removeWhere((p) => p.id == propertyId);
      } else {
        // Add to favorites
        final favorite = Favorite(userId: userId, propertyId: propertyId);
        await DatabaseHelper.instance.addFavorite(favorite);
        _favoriteIds.add(propertyId);
        
        // Optionally load the property to add to list
        final property = await DatabaseHelper.instance.getPropertyById(propertyId);
        if (property != null) {
          _favoriteProperties.insert(0, property);
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
