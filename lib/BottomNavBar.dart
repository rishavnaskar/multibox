import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:multibox/news/ui/home/home_screen.dart';
import 'package:multibox/profile/profile_screen.dart';
import 'package:multibox/to_do/todo_screen.dart';
import 'package:multibox/weather/weather_screen.dart';

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  GlobalKey _bottomNavigationKey = GlobalKey();
  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          ToDoScreen(),
          WeatherScreen(),
          HomeScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: 0,
        height: 60.0,
        animationCurve: Curves.fastOutSlowIn,
        animationDuration: Duration(milliseconds: 200),
        color: Colors.white,
        backgroundColor: Color(0xff6B63FF),
        items: <Widget>[
          Icon(Icons.list, size: 25.0, color: Colors.black,),
          Icon(Icons.wb_sunny, size: 25.0, color: Colors.black,),
          Icon(Icons.public, size: 25.0, color: Colors.black,),
          Icon(Icons.person_pin, size: 25.0, color: Colors.black,),
        ],

        onTap: (value) {
          setState(() {
            _pageController.jumpToPage(value);
          });
        },
      ),
    );
  }
}
