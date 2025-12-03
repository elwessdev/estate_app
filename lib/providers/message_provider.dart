import 'package:flutter/foundation.dart';
import '../models/message.dart';
import '../services/database_helper.dart';

class MessageProvider with ChangeNotifier {
  List<Message> _messages = [];
  List<Map<String, dynamic>> _chatList = [];
  bool _isLoading = false;

  List<Message> get messages => _messages;
  List<Map<String, dynamic>> get chatList => _chatList;
  bool get isLoading => _isLoading;

  Future<void> loadChatList(int userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _chatList = await DatabaseHelper.instance.getChatList(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading chat list: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadConversation(
      int userId, int otherUserId, int propertyId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _messages = await DatabaseHelper.instance.getConversation(
        userId,
        otherUserId,
        propertyId,
      );

      // Mark messages as read
      await DatabaseHelper.instance.markMessagesAsRead(
        userId,
        otherUserId,
        propertyId,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(Message message) async {
    try {
      final id = await DatabaseHelper.instance.createMessage(message);
      final newMessage = message.copyWith(id: id);
      _messages.add(newMessage);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void clearMessages() {
    _messages = [];
    notifyListeners();
  }
}
