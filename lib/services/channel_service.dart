import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task3/models/channel.dart';
import 'package:task3/models/app_user.dart';
import 'package:task3/services/chat_service.dart';
import 'package:task3/services/user_service.dart';
import 'package:uuid/uuid.dart';

class ChannelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Channel>> getChannels() async {
    final channels = await _firestore.collection("channels").get();
    try {
      final List<Channel> channelList =
          channels.docs.map((doc) => Channel.fromMap(doc.data())).toList();
      return channelList;
    } catch (e) {
      print("Error fetching channels: $e");
      return [];
    }
  }

  Future<bool> channelExist(String channelName) async {
    final channels = await _firestore.collection("channels").get();
    try {
      final List<String> channelList =
          channels.docs.map((doc) => doc.data()['name'] as String).toList();
      if (channelList.contains(channelName)) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error fetching channels: $e");
      return false;
    }
  }

  Future<void> createChannel(String channelName) async {
    try {
      const uuid = Uuid();
      String id = uuid.v4();
      Channel channel = Channel(id: id, name: channelName);
      await _firestore.collection("channels").doc(id).set(channel.toMap());
      await ChatService().createChat(channel);
    } catch (e) {
      print("Error fetching channels: $e");
    }
  }

  Future<void> deleteChannel(Channel channel) async {
    UserService userService = UserService();
    ChatService chatService = ChatService();
    try {
      await _firestore.collection("channels").doc(channel.id).delete();
      List<AppUser> users = await userService.getUsers();
      for (var i = 0; i < users.length; i++) {
        if (users[i].subscribedChannels.contains(channel.name)) {
          userService.unsubscribeChannel(channel.name, users[i]);
        }
      }
      chatService.deleteChat(channel);
    } catch (e) {
      print("Error fetching channels: $e");
    }
  }
}
