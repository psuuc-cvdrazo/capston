import 'package:capstoneapp/screen/userside/checkcam.dart';
import 'package:capstoneapp/screen/userside/form.dart';
import 'package:capstoneapp/screen/map.dart';
import 'package:capstoneapp/screen/userside/profile.dart';
import 'package:capstoneapp/screen/userside/realtime.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';


class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _selectedIndex = 2; 


  final List<Widget> _pages = [
     CheckTimePage(),
    const FormScreen(),
    const MapScreen(),
    const UserProfileScreen(),                   
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],  
     bottomNavigationBar: CurvedNavigationBar(
  color: const Color.fromARGB(255, 47, 61, 2),
  index: _selectedIndex,
  animationDuration: const Duration(milliseconds: 300),
  animationCurve: Curves.fastLinearToSlowEaseIn,
  buttonBackgroundColor: const Color.fromARGB(255, 47, 61, 2),
  backgroundColor: Colors.transparent,
  items: [
    Icon(
      Icons.video_camera_back_sharp,
      color: _selectedIndex == 0 ? Colors.white : Colors.grey,
    ),
    Icon(
      Icons.chat,
      color: _selectedIndex == 1 ? Colors.white : Colors.grey,
    ),
    Icon(
      Icons.map_rounded,
      color: _selectedIndex == 2 ? Colors.white : Colors.grey,
    ),
    Icon(
      Icons.person,
      color: _selectedIndex == 3 ? Colors.white : Colors.grey,
    ),
  ],
  onTap: (index) {
    setState(() {
      _selectedIndex = index;  
    });
  },
),

    );
  }
}
