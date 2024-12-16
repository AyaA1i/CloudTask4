import 'package:flutter/material.dart';
import 'package:task3/models/chat.dart';
import 'package:task3/screens/chat_screen.dart';

class ChatTile extends StatefulWidget {
  const ChatTile({super.key, required this.chat});

  final Chat chat;
  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  void openChat(Chat chat) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(chat: chat)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        openChat(widget.chat);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 15,
              child: Image.asset('assets/images/chat-icon.jpg'),
            ),
            const SizedBox(
              width: 7,
            ),
            Text(
              widget.chat.channel.name,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            const SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }
}
