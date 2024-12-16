import 'package:flutter/material.dart';

class ChannelTile extends StatefulWidget {
  final String name;
  final String text;
  final void Function(String channelName) subscribe;
  final void Function(String channelName) unsubscribe;
  const ChannelTile(this.name, this.text, this.subscribe, this.unsubscribe,
      {super.key});
  @override
  State<ChannelTile> createState() => _ChannelTileState();
}

class _ChannelTileState extends State<ChannelTile> {
  void func() {
    if (widget.text == 'Subscribe') {
      widget.subscribe(widget.name);
    } else {
      widget.unsubscribe(widget.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.name,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            ElevatedButton(
              onPressed: () {
                func();
              },
              child: Text(widget.text),
            ),
          ],
        ),
      ),
    );
  }
}
