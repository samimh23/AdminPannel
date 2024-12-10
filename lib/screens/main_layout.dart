// lib/screens/main_layout.dart
import 'package:admindash/screens/product_list_screen.dart';
import 'package:admindash/screens/users_screen.dart';
import 'package:flutter/material.dart';

import 'Reclamation_Screen.dart';
import 'dashboard_screen.dart';

class MainLayout extends StatefulWidget {
  final String token;

  const MainLayout({Key? key, required this.token}) : super(key: key);

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

// lib/screens/main_layout.dart
class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            extended: true,
            minExtendedWidth: 250,
            backgroundColor: Colors.grey[200],
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
                padding: EdgeInsets.all(16),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Users'),
                padding: EdgeInsets.all(16),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.shop),
                label: Text('MarketPlace'),
                padding: EdgeInsets.all(16),
              ),NavigationRailDestination(
                icon: Icon(Icons.receipt),
                label: Text('Reclamations'),
                padding: EdgeInsets.all(16),
              )
            ],
          ),
          // Vertical divider
          VerticalDivider(thickness: 1, width: 1),
          // Main content
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                DashboardScreen(token: widget.token),
                UsersScreen(token: widget.token),
                ProductListScreen(),
                ReclamationScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}