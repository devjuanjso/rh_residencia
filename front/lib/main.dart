import 'package:flutter/material.dart';
import 'package:front/features/profile/view/my_projects_page.dart';
import 'package:front/features/profile/view/profile_page.dart';
import 'package:front/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:front/features/projects/view/project_list_page.dart';
import 'package:front/features/projects/viewmodel/project_form_viewmodel.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

import 'features/auth/view/login_page.dart';
import 'features/auth/viewmodel/auth_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authViewModel = AuthViewModel();
  await authViewModel.loadUserFromStorage();

  runApp(
    RHApp(authViewModel: authViewModel),
  );
}

class RHApp extends StatelessWidget {
  final AuthViewModel authViewModel;

  const RHApp({
    super.key,
    required this.authViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProjectFormViewModel>(
          create: (_) => ProjectFormViewModel(),
        ),
        ChangeNotifierProvider<AuthViewModel>.value(
          value: authViewModel,
        ),
        ChangeNotifierProvider<ProfileViewModel>(
          create: (_) => ProfileViewModel(),
        ),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RH',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),

      home: auth.isAuthenticated
          ? const HomePage()
          : const LoginPage(),
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
      ProjectListPage(),
      MyProjectsPage(),
      ProfilePage(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    const purple = Color(0xFF6B21A8);
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.explore_rounded),
        title: 'Descobrir',
        activeColorPrimary: purple,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.cases_rounded),
        title: 'Projetos',
        activeColorPrimary: purple,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.account_circle_rounded),
        title: 'Perfil',
        activeColorPrimary: purple,
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