
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:recycleapp/pages/home.dart';
import 'package:recycleapp/pages/points.dart';
import 'package:recycleapp/pages/profile.dart';



class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  late List<Widget> pages;

  late Home HomePage;
  late Points points;
  late Profile profilePage;

  int currentTabIndex = 0;

  @override
  void initState() {
    HomePage = Home();
    points=Points();
    profilePage = Profile();

    pages = [HomePage, points, profilePage];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        height: 70,
        backgroundColor: Colors.white,
        color: Colors.black,
        animationDuration: Duration(milliseconds: 500),
        onTap: (int index) {
          setState(() {
            currentTabIndex = index;
          });
        },
        items: [
          Icon(Icons.home, color: Colors.white, size: 34.0),
          Icon(Icons.point_of_sale, color: Colors.white, size: 34.0,),
          Icon(Icons.person, color: Colors.white, size: 34.0),
        ],
      ),
      body: pages[currentTabIndex],
    );
  }
}
