import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nicare/pages/reels_page.dart';
import 'package:nicare/pages/team_page.dart';
import 'package:nicare/pages/video_page.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'guides.dart';
import 'home_page.dart';
import 'language_constants.dart';
import 'leadership_ann.dart';

class BotNav extends StatefulWidget {
  const BotNav({super.key});

  @override
  State<BotNav> createState() => BotNavState();
}
class BotNavState extends State<BotNav> {
  String access = TeamPageState.access;

  PersistentTabController _controller = PersistentTabController(initialIndex: 0);

//Screens for each nav items.
  List<Widget> _NavScreens() {
    return [
      HomePage(),
      GuidesPage(),
      // VideoPage(),
      ReelsPage(),
      LeadershipAnn(),

    ];
  }

  // List<Widget> _NavScreensCustomer() {
  //   return [
  //     HomePageCustomer(),
  //     GuidesPage(),
  //     VideoPage(),
  //     NewsAnn(),
  //
  //   ];
  // }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home),
        title: (translation(context).home),
        opacity: 0.5,
        inactiveColorPrimary: Colors.black,
        activeColorSecondary: Colors.blue,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.book),
        title: (translation(context).guide),
        inactiveColorPrimary: Colors.black,
        activeColorSecondary: Colors.blue,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.play_circle_outline_outlined),
        title: (translation(context).video),
        inactiveColorPrimary: Colors.black,
        activeColorSecondary: Colors.blue,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.announcement_outlined),
        title: (translation(context).leader),
        inactiveColorPrimary: Colors.black,
        activeColorSecondary: Colors.blue,
      ),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItemsCustomer() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home),
        title: (translation(context).home),
        opacity: 0.5,
        inactiveColorPrimary: Colors.black,
        activeColorSecondary: Colors.blue,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.book),
        title: (translation(context).guide),
        inactiveColorPrimary: Colors.black,
        activeColorSecondary: Colors.blue,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.play_circle_outline_outlined),
        title: (translation(context).video),
        inactiveColorPrimary: Colors.black,
        activeColorSecondary: Colors.blue,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.announcement_outlined),
        title: 'News',
        inactiveColorPrimary: Colors.black,
        activeColorSecondary: Colors.blue,
      ),
    ];
  }

  int myIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PersistentTabView(
        context,
        controller: _controller,
        // screens: (access == "Internal")?_NavScreens():_NavScreensCustomer(),
        screens: _NavScreens(),
        items: (access == "Internal")?_navBarsItems():_navBarsItemsCustomer(),
        confineToSafeArea: true,
        backgroundColor: Colors.white,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        hideNavigationBarWhenKeyboardAppears: true,
        decoration: NavBarDecoration(
        ),
        popBehaviorOnSelectedNavBarItemPress: PopBehavior.all,
        navBarStyle: NavBarStyle.style4,
      ),
    );
  }
}
