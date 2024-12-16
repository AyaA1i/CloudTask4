import 'package:firebase_database/firebase_database.dart';
import 'package:task3/models/channel.dart';
import 'package:task3/models/chat.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class ChatService {
  Future<List<Chat>> getChats() async {
    try {
      List<Chat> result = [];
      final url = Uri.https(
          'cloudtask2-6a286-default-rtdb.firebaseio.com', 'chats.json');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        if (json.decode(response.body) == null) {
          return [];
        }
        final Map<String, dynamic> chats = json.decode(response.body);
        for (var id in chats.keys) {
          final chat = chats[id];
          result.add(Chat.fromMap(chat));
        }
        return result;
      } else {
        return [];
      }
    } catch (e) {
      print('An error occurred: $e');
      return [];
    }
  }

  Future<void> createChat(Channel channel) async {
    const uuid = Uuid();
    String chatId = uuid.v4();
    Chat chat = Chat(id: chatId, channel: channel, messages: []);
    final DatabaseReference chatsRef =
        FirebaseDatabase.instance.ref('chats/$chatId');
    try {
      await chatsRef.set(chat.toMap());
    } catch (e) {
      print('Error creating chat: $e');
    }
  }

  Future<void> deleteChat(Channel channel) async {
    try {
      final url = Uri.https(
          'cloudtask2-6a286-default-rtdb.firebaseio.com', 'chats.json');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        if (json.decode(response.body) == null) {
          print('No chats found.');
          return;
        }

        final Map<String, dynamic> chats = json.decode(response.body);

        for (var chatId in chats.keys) {
          final chat = Chat.fromMap(chats[chatId]);

          // Compare channels to check for equality
          if (chat.channel.id == channel.id) {
            // Construct URL for the specific chat
            final deleteUrl = Uri.https(
                'cloudtask2-6a286-default-rtdb.firebaseio.com',
                'chats/$chatId.json');

            // Send DELETE request
            final deleteResponse = await http.delete(deleteUrl);

            if (deleteResponse.statusCode == 200) {
              print('Chat with id $chatId deleted successfully.');
            } else {
              print(
                  'Failed to delete chat with id $chatId. Status code: ${deleteResponse.statusCode}');
            }
          }
        }
      } else {
        print('Failed to fetch chats. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting chat: $e');
    }
  }
}
