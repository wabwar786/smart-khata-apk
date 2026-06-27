import 'package:flutter/material.dart';

import '../services/session_service.dart';
import 'customers/customer_list_screen.dart';
import 'dashboard_screen.dart';
import 'invoices/invoice_list_screen.dart';
import 'login_screen.dart';
import 'products/product_list_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  SessionData? _session;

  final _screens = const [
    DashboardScreen(),
    CustomerListScreen(),
    ProductListScreen(),
    InvoiceListScreen(),
  ];

  @override
  void initState() {
    super.initState();
    SessionService.get().then((s) => setState(() => _session = s));
  }

  Future<void> _logout() async {
    await SessionService.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_session?.businessName ?? 'Smart Khata'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.people_alt_rounded), label: 'Customers'),
          NavigationDestination(icon: Icon(Icons.inventory_2_rounded), label: 'Products'),
          NavigationDestination(icon: Icon(Icons.receipt_long_rounded), label: 'Invoices'),
        ],
      ),
    );
  }
}
