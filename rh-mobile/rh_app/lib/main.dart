import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:rh_app/features/position/view/position_page.dart';

void main() {
  runApp(const RHApp());
}

class RHApp extends StatelessWidget {
  const RHApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RH',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() {
    return const [
      ProjectsPage(),
      PlaceholderPage(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.work),
        title: 'Projects',
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.more_horiz),
        title: 'More',
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
    ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      navBarStyle: NavBarStyle.style3,
      backgroundColor: Colors.white,
    );
  }
}

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Projects Page',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
