import 'package:task3/models/channel.dart';
import 'package:task3/models/message.dart';

class Chat {
  String id;
  Channel channel;
  List<Message> messages;

  Chat({
    required this.id,
    required this.channel,
    required this.messages,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'channel': channel.toMap(),
      'messages': messages.map((message) => message.toMap()).toList(),
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'],
      channel: Channel.fromMap(map['channel'] ?? {}),
      messages: map['messages'] != null
          ? (map['messages'] as Map<String, dynamic>).values
              .map((x) => Message.fromMap(x))
              .toList()
          : [],
    );
  }
}
