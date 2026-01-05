import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:rh_app/core/services/http_service.dart';
import 'package:rh_app/features/position/view/position_page.dart';
import 'package:rh_app/features/projects/view/projects_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


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
    return [
      ProjectsPage(),
      const PlaceholderPage(),
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

Future<void> testarConexao() async {
  try {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/ping/'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ CONEXÃO OK COM DJANGO');
      print('Resposta do backend: $data');
    } else {
      print('⚠️ Backend respondeu, mas com erro');
      print('Status: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ NÃO CONSEGUIU CONECTAR NO BACKEND');
    print(e);
  }
}
