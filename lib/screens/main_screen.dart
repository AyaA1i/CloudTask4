import 'package:flutter/material.dart';
import 'package:task3/screens/channels_list.dart';
import 'package:task3/screens/chats_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedScreenIndex = 0;

  void _selectScreen(int index) {
    setState(() {
      _selectedScreenIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activeScreen = const ChatsScreen();
    if (_selectedScreenIndex == 1) {
      activeScreen = const ChannelsList();
    }
    return Scaffold(
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 10,
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(79, 156, 156, 156),
                  spreadRadius: 8,
                  blurRadius: 18,
                  offset: Offset(0, 7),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(22.0),
              topRight: Radius.circular(22.0),
            ),
            child: SizedBox(
              height: 70,
              child: BottomNavigationBar(
                onTap: _selectScreen,
                currentIndex: _selectedScreenIndex,
                backgroundColor: const Color.fromARGB(255, 214, 214, 214),
                selectedItemColor: const Color(0xFF5f4bce),
                unselectedItemColor: const Color.fromARGB(255, 112, 112, 112),
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(
                        Icons.message,
                      ),
                      label: 'Chats'),
                  BottomNavigationBarItem(
                      icon: Icon(
                        Icons.menu,
                      ),
                      label: 'Channels'),
                ],
              ),
            ),
          ),
        ],
      ),
      body: activeScreen,
    );
  }
}
