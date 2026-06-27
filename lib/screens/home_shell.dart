import 'package:flutter/material.dart';

import '../services/session_service.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'inventory/inventory_home_screen.dart';
import 'login_screen.dart';
import 'pos/pos_screen.dart';
import 'shop/your_shop_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  SessionData? _session;
  int _refresh = 0;

  @override
  void initState() { super.initState(); SessionService.get().then((s) { if (mounted) setState(() => _session = s); }); }

  Future<void> _logout() async {
    await SessionService.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(key: ValueKey('home-$_refresh'), onDataChanged: () => setState(() => _refresh++)),
      PosScreen(key: ValueKey('pos-$_refresh'), onSaved: () => setState(() => _refresh++)),
      InventoryHomeScreen(key: ValueKey('inv-$_refresh'), onChanged: () => setState(() => _refresh++)),
      YourShopScreen(key: ValueKey('shop-$_refresh')),
    ];
    return Scaffold(
      appBar: _index == 1 ? null : AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_session?.businessName ?? 'Smart Khata', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19)),
          const Text('Customers • Suppliers • Inventory', style: TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w600)),
        ]),
        actions: [
          IconButton(onPressed: () => setState(() => _refresh++), icon: const Icon(Icons.refresh_rounded)),
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu_rounded, size: 30),
            onSelected: (v) { if (v == 'logout') _logout(); },
            itemBuilder: (_) => const [PopupMenuItem(value: 'logout', child: Text('Logout'))],
          ),
        ],
      ),
      body: screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.point_of_sale_rounded), label: 'POS / Sale'),
          NavigationDestination(icon: Icon(Icons.inventory_2_rounded), label: 'Inventory'),
          NavigationDestination(icon: Icon(Icons.storefront_rounded), label: 'Your Shop'),
        ],
      ),
    );
  }
}
