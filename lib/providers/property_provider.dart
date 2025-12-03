import 'package:flutter/foundation.dart';
import '../models/property.dart';
import '../services/database_helper.dart';

class PropertyProvider with ChangeNotifier {
  List<Property> _properties = [];
  List<Property> _filteredProperties = [];
  bool _isLoading = false;
  String? _filterType;
  double? _minPrice;
  double? _maxPrice;

  List<Property> get properties => _filteredProperties;
  bool get isLoading => _isLoading;

  Future<void> loadProperties() async {
    try {
      _isLoading = true;
      notifyListeners();

      _properties = await DatabaseHelper.instance.getAllProperties();
      _applyFilters();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserProperties(int userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _properties = await DatabaseHelper.instance.getPropertiesByUser(userId);
      _filteredProperties = _properties;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addProperty(Property property) async {
    try {
      final id = await DatabaseHelper.instance.createProperty(property);
      final newProperty = property.copyWith(id: id);
      _properties.insert(0, newProperty);
      _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateProperty(Property property) async {
    try {
      await DatabaseHelper.instance.updateProperty(property);
      final index = _properties.indexWhere((p) => p.id == property.id);
      if (index != -1) {
        _properties[index] = property;
        _applyFilters();
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteProperty(int propertyId) async {
    try {
      await DatabaseHelper.instance.deleteProperty(propertyId);
      _properties.removeWhere((p) => p.id == propertyId);
      _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Property?> getPropertyById(int id) async {
    return await DatabaseHelper.instance.getPropertyById(id);
  }

  void setFilters({String? type, double? minPrice, double? maxPrice}) {
    _filterType = type;
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _filterType = null;
    _minPrice = null;
    _maxPrice = null;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredProperties = _properties.where((property) {
      bool typeMatch = _filterType == null || property.type == _filterType;
      bool minPriceMatch = _minPrice == null || property.price >= _minPrice!;
      bool maxPriceMatch = _maxPrice == null || property.price <= _maxPrice!;
      return typeMatch && minPriceMatch && maxPriceMatch;
    }).toList();
  }
}
