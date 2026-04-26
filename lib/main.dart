import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:renewtrack/services/authProvider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_renewal_screen.dart';
import 'screens/renewal_list_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const RenewTrackApp());
}

class RenewTrackApp extends StatelessWidget {
  const RenewTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthScope wraps the entire tree so every screen can access AuthProvider
    return AuthScope(
      notifier: AuthProvider(),
      child: MaterialApp(
        title: 'RenewTrack',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/login',
        routes: {
          '/login': (_) => const LoginScreen(),
          '/dashboard': (_) => const MainShell(initialIndex: 0),
          '/renewals': (_) => const MainShell(initialIndex: 1),
          '/add-renewal': (_) => const AddRenewalScreen(),
        },
      ),
    );
  }
}

/// Bottom-nav shell that hosts Dashboard, Renewals, Clients tabs.
class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = const [
    DashboardScreen(),
    RenewalListScreen(),
    _ClientsPlaceholder(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.autorenew_outlined),
            selectedIcon: Icon(Icons.autorenew),
            label: 'Renewals',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Clients',
          ),
        ],
      ),
    );
  }
}

class _ClientsPlaceholder extends StatelessWidget {
  const _ClientsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Clients screen coming soon'),
    );
  }
}
