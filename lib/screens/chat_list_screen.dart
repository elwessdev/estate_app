import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/message_provider.dart';
import '../providers/auth_provider.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChats();
    });
  }

  Future<void> _loadChats() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await messageProvider.loadChatList(authProvider.currentUser!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: Consumer2<MessageProvider, AuthProvider>(
        builder: (context, messageProvider, authProvider, child) {
          if (authProvider.currentUser == null) {
            return const Center(
              child: Text('Please login to view messages'),
            );
          }

          if (messageProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (messageProvider.chatList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.message_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadChats,
            child: ListView.builder(
              itemCount: messageProvider.chatList.length,
              itemBuilder: (context, index) {
                final chat = messageProvider.chatList[index];
                final lastMessage = (chat['content'] ?? 'No message') as String;
                final otherUserId = chat['other_user_id'] as int;
                final otherUserName = (chat['other_user_name'] ?? 'Unknown User') as String;
                final propertyTitle = (chat['property_title'] ?? 'Unknown Property') as String;
                final propertyId = chat['property_id'] as int;
                final isRead = (chat['is_read'] as int?) == 1;
                final isSender =
                    (chat['sender_id'] as int) == authProvider.currentUser!.id;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        otherUserName[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      otherUserName,
                      style: TextStyle(
                        fontWeight:
                            !isRead && !isSender ? FontWeight.bold : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          propertyTitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight:
                                !isRead && !isSender ? FontWeight.bold : null,
                          ),
                        ),
                      ],
                    ),
                    trailing: !isRead && !isSender
                        ? Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            propertyId: propertyId,
                            otherUserId: otherUserId,
                          ),
                        ),
                      ).then((_) => _loadChats());
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
