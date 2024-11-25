import 'package:capstoneapp/screen/collectorside/collectorprofile.dart';
import 'package:capstoneapp/screen/collectorside/logs.dart';
import 'package:capstoneapp/screen/map.dart';
import 'package:capstoneapp/screen/mapCollector.dart';
import 'package:capstoneapp/screen/userside/realtime.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; 


  final List<Widget> _pages = [
   
   
    LogScreen(),
     const CollectorMapScreen(),
     const CollectorProfileScreen(),                   
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],  
      bottomNavigationBar: CurvedNavigationBar(
        color: const Color(0xFF0A2A05),
        index: _selectedIndex,
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.fastLinearToSlowEaseIn,
        buttonBackgroundColor: const Color(0xFF0A2A05),
        backgroundColor: Colors.transparent,
        items: [
          Icon(
            Icons.file_copy_outlined,
            color: _selectedIndex == 0 ? Colors.white : Colors.grey,
          ),
          Icon(
            Icons.map_rounded,
            color: _selectedIndex == 1 ? Colors.white : Colors.grey,
          ),
          Icon(
            Icons.person,
            color: _selectedIndex == 2 ? Colors.white : Colors.grey,
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
