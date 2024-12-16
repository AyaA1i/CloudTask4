import 'package:flutter/material.dart';
import 'package:task3/services/channel_service.dart';

class CreateChannel extends StatefulWidget {
  const CreateChannel({super.key, required this.onCreatingChannel});

  final void Function() onCreatingChannel;

  @override
  State<StatefulWidget> createState() => _CreateChannelState();
}

class _CreateChannelState extends State<CreateChannel> {
  var channelName = '';
  var inputError = '';
  ChannelService channelService = ChannelService();

  void createChannel() async {
    if (channelName.trim().isEmpty) {
      setState(() {
        inputError = 'Please Enter Channel Name';
      });
      return;
    }

    bool exist = await channelService.channelExist(channelName);
    if (exist) {
      setState(() {
        inputError = 'Please Enter Another Name';
      });
      return;
    }

    await channelService.createChannel(channelName);
    widget.onCreatingChannel();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create New Channel',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            decoration: const InputDecoration(
              labelText: "Channel Name",
            ),
            onChanged: (value) => setState(() {
              channelName = value;
              inputError = '';
            }),
          ),
          if (inputError.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(
              inputError,
              style: const TextStyle(fontSize: 13, color: Colors.red),
            ),
          ],
          const SizedBox(
            height: 15,
          ),
          ElevatedButton(
            onPressed: createChannel,
            child: const Text(
              'Create',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
