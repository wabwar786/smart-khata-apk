import 'package:flutter/material.dart';

import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/sk_widgets.dart';
import '../login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  const _OnboardingItem(this.icon, this.title, this.description, this.color);
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  int _index = 0;
  final _items = const [
    _OnboardingItem(Icons.people_alt_rounded, 'Manage Customers', 'Add customers, track receivable/payable khata, send reminders and share statements.', Color(0xFF7C3AED)),
    _OnboardingItem(Icons.storefront_rounded, 'Manage Suppliers', 'Record supplier purchases, payable balances and supplier payments with simple wording.', Color(0xFF2563EB)),
    _OnboardingItem(Icons.inventory_2_rounded, 'Inventory & Stock', 'Track purchase price, sale price, stock value, reorder level and low stock alerts.', Color(0xFFEA580C)),
    _OnboardingItem(Icons.point_of_sale_rounded, 'Sale / POS Invoice', 'Create quick open-item sales or inventory-based invoices with cash and udhaar options.', Color(0xFF16A34A)),
    _OnboardingItem(Icons.shopping_bag_rounded, 'Online Shop Orders', 'Create your shop profile, share shop code and receive customer orders inside the app.', AppColors.primary),
  ];

  Future<void> _next() async {
    if (_index < _items.length - 1) {
      _page.nextPage(duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
      return;
    }
    await SessionService.setOnboardingCompleted();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  void dispose() { _page.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final last = _index == _items.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () async { await SessionService.setOnboardingCompleted(); if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen())); }, child: const Text('Skip'))),
            Expanded(
              child: PageView.builder(
                controller: _page,
                onPageChanged: (v) => setState(() => _index = v),
                itemCount: _items.length,
                itemBuilder: (_, i) {
                  final item = _items[i];
                  return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(width: 132, height: 132, decoration: BoxDecoration(color: item.color.withAlpha(20), borderRadius: BorderRadius.circular(42)), child: Icon(item.icon, size: 70, color: item.color)),
                    const SizedBox(height: 36),
                    Text(item.title, textAlign: TextAlign.center, style: AppText.h1),
                    const SizedBox(height: 14),
                    Text(item.description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.muted, fontWeight: FontWeight.w600)),
                  ]);
                },
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_items.length, (i) => AnimatedContainer(duration: const Duration(milliseconds: 200), margin: const EdgeInsets.symmetric(horizontal: 4), width: i == _index ? 28 : 8, height: 8, decoration: BoxDecoration(color: i == _index ? AppColors.primary : const Color(0xFFD9DEE5), borderRadius: BorderRadius.circular(10))))),
            const SizedBox(height: 24),
            PillButton(text: last ? 'GET STARTED' : 'NEXT', icon: last ? Icons.check_rounded : Icons.arrow_forward_rounded, onTap: _next),
          ]),
        ),
      ),
    );
  }
}
