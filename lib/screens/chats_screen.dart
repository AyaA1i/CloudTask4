import 'package:flutter/material.dart';
import 'package:task3/models/chat.dart';
import 'package:task3/models/app_user.dart';
import 'package:task3/screens/sign_in.dart';
import 'package:task3/services/channel_service.dart';
import 'package:task3/services/chat_service.dart';
import 'package:task3/services/user_service.dart';
import 'package:task3/widgets/chat_tile.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  List<Chat> chats = [];
  List<String> subscribedChannels = [];
  AppUser? signedInUser;
  UserService userService = UserService();
  ChannelService channelService = ChannelService();
  ChatService chatService = ChatService();

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    final fetchedChats = await chatService.getChats();
    final AppUser = await userService.getSignedInUser();
    signedInUser = AppUser;
    subscribedChannels = AppUser?.subscribedChannels ?? [];
    setState(() {
      chats = fetchedChats
          .where((chat) => subscribedChannels.contains(chat.channel.name))
          .toList();
    });
  }

  void logout() async {
    await userService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignIn()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Channels Rooms",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {
                logout();
              },
              icon: const Icon(Icons.logout)),
          const SizedBox(
            width: 20,
          )
        ],
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) => ChatTile(chat: chats[index])),
      ),
    );
  }
}
