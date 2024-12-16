import 'package:flutter/material.dart';
import 'package:task3/models/channel.dart';
import 'package:task3/models/app_user.dart';
import 'package:task3/screens/create_channel.dart';
import 'package:task3/services/channel_service.dart';
import 'package:task3/services/user_service.dart';
import 'package:task3/widgets/channel_tile.dart';

class ChannelsList extends StatefulWidget {
  const ChannelsList({super.key});

  @override
  State<ChannelsList> createState() => _ChannelsListState();
}

class _ChannelsListState extends State<ChannelsList> {
  List<Channel> channels = [];
  List subscribedChannels = [];
  AppUser? signedInUser;
  ChannelService channelService = ChannelService();
  UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    _fetchChannels();
  }

  Future<void> _fetchChannels() async {
    final fetchedChannels = await channelService.getChannels();
    final appUser = await userService.getSignedInUser();

    setState(() {
      channels = fetchedChannels;
      signedInUser = appUser;
      subscribedChannels = appUser?.subscribedChannels ?? [];
    });
  }

  void subscribe(String channelName) async {
    await userService.subscribeChannel(channelName, signedInUser!);
    await _fetchChannels();
  }

  void unsubscribe(String channelName) async {
    await userService.unsubscribeChannel(channelName, signedInUser!);
    await _fetchChannels();
  }

  void createChannel() {
    showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.white,
        builder: (ctx) => CreateChannel(
              onCreatingChannel: _fetchChannels,
            ));
  }

  void _removeChannel(Channel channel) async {
    await channelService.deleteChannel(channel);
    _fetchChannels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Channels",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {
                createChannel();
              },
              icon: const Icon(Icons.add)),
          const SizedBox(
            width: 20,
          )
        ],
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: ListView.builder(
          itemCount: channels.length,
          itemBuilder: (context, index) => Dismissible(
            key: ValueKey(channels[index]),
            background: Container(
              color: Colors.red.withOpacity(0.75),
            ),
            onDismissed: (direction) {
              _removeChannel(channels[index]);
            },
            child: ChannelTile(
                channels[index].name,
                subscribedChannels.contains(channels[index].name)
                    ? 'Unsubscribe'
                    : 'Subscribe',
                subscribe,
                unsubscribe),
          ),
        ),
      ),
    );
  }
}
