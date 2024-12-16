import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:task3/models/chat.dart';
import 'package:task3/models/message.dart';
import 'package:task3/models/app_user.dart';
import 'package:task3/services/user_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.chat});
  final Chat chat;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final TextEditingController _messageController = TextEditingController();
  late DatabaseReference _channelMessagesRef;
  final userService = UserService();
  AppUser? signedInUser;

  @override
  void initState() {
    super.initState();
    prefetch();
  }

  Future<void> prefetch() async {
    _channelMessagesRef = _dbRef.child("chats/${widget.chat.id}/messages");
    signedInUser = await userService.getSignedInUser();
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;
    Message msg = Message(
        username: signedInUser!.username,
        message: message,
        timestamp: DateTime.now());
    _channelMessagesRef.push().set(msg.toMap());
    widget.chat.messages.add(msg);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chat.channel.name),
        backgroundColor: const Color.fromARGB(255, 230, 230, 230),
      ),
      body: FutureBuilder<void>(
        future: prefetch(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          return Column(
            children: [
              Expanded(
                child: StreamBuilder<DatabaseEvent>(
                  stream: _channelMessagesRef.onValue,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
                    final messages = (snapshot.data?.snapshot.value as Map?)
                            ?.values
                            .map((e) =>
                                Message.fromMap(Map<String, dynamic>.from(e)))
                            .toList() ??
                        [];

                    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

                    return ListView.builder(
                      reverse: false,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMine =
                            message.username == signedInUser?.username;

                        return Align(
                          alignment: isMine
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.8,
                            ),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: isMine
                                    ? const Color.fromARGB(255, 214, 207, 255)
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!isMine)
                                    Text(
                                      message.username,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  Text(message.message),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      "${message.timestamp.hour}:${message.timestamp.minute}",
                                      style: const TextStyle(
                                        fontSize: 10.0,
                                        color: Color.fromARGB(255, 67, 67, 67),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: "Enter a message",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => _sendMessage(_messageController.text),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
