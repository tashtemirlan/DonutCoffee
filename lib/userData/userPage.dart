import 'package:donutcoffee/userData/favoritesPage.dart';
import 'package:donutcoffee/userData/homePage.dart';
import 'package:donutcoffee/userData/ordersPage.dart';
import 'package:donutcoffee/userData/profilePage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class UserScreen extends StatefulWidget{
  const UserScreen({super.key});

  @override
  UserScreenState createState()=> UserScreenState();
}

class UserScreenState extends State<UserScreen>{
  int _currentIndex = 0;

  final List<Widget> _pages = [
    // Our widgets =>
    const HomePageScreen(),
    const FavoritePageScreen(),
    const OrdersPageScreen(),
    const ProfilePageScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color.fromRGBO(30, 29, 33, 1),
        unselectedItemColor: const Color.fromRGBO(188, 188, 188, 0.6),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.house),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.solidHeart),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.mugSaucer),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.user),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
