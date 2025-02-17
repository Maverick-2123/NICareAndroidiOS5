import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nicare/pages/reels_page.dart';
import 'package:nicare/pages/video_page.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'guides.dart';
import 'home_page.dart';
import 'language_constants.dart';
import 'leadership_ann.dart';

class BotNavGuide extends StatefulWidget {
  const BotNavGuide({super.key});

  @override
  State<BotNavGuide> createState() => BotNavGuideState();
}
class BotNavGuideState extends State<BotNavGuide> {

  PersistentTabController _controller = PersistentTabController(initialIndex: 1);

//Screens for each nav items.
  List<Widget> _NavScreens() {
    return [
      HomePage(),
      GuidesPage(),
      ReelsPage(),
      LeadershipAnn(),

    ];
  }

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

  int myIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PersistentTabView(
        context,
        controller: _controller,
        screens: _NavScreens(),
        items: _navBarsItems(),
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
