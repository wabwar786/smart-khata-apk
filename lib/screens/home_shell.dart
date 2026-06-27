import 'package:flutter/material.dart';

import '../services/session_service.dart';
import 'customers/customer_list_screen.dart';
import 'dashboard_screen.dart';
import 'invoices/invoice_list_screen.dart';
import 'login_screen.dart';
import 'more/more_screen.dart';
import 'products/product_list_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  SessionData? _session;
  int _refreshTick = 0;

  @override
  void initState() {
    super.initState();
    SessionService.get().then((s) {
      if (mounted) setState(() => _session = s);
    });
  }

  Future<void> _logout() async {
    await SessionService.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _refreshAll() => setState(() => _refreshTick++);

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(key: ValueKey('dash-$_refreshTick'), onDataChanged: _refreshAll),
      CustomerListScreen(key: ValueKey('customers-$_refreshTick')),
      ProductListScreen(key: ValueKey('products-$_refreshTick')),
      InvoiceListScreen(key: ValueKey('invoices-$_refreshTick')),
      MoreScreen(onLogout: _logout, onDataChanged: _refreshAll),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_session?.businessName ?? 'Smart Khata', style: const TextStyle(fontWeight: FontWeight.w900)),
            if (_session != null)
              Text('Hello, ${_session!.userName}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refreshAll,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.people_alt_rounded), label: 'Customers'),
          NavigationDestination(icon: Icon(Icons.inventory_2_rounded), label: 'Products'),
          NavigationDestination(icon: Icon(Icons.receipt_long_rounded), label: 'Invoices'),
          NavigationDestination(icon: Icon(Icons.menu_rounded), label: 'More'),
        ],
      ),
    );
  }
}
