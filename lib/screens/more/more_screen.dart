import 'package:flutter/material.dart';

import '../../widgets/pro_widgets.dart';
import '../payments/payment_list_screen.dart';
import '../reminders/reminder_list_screen.dart';
import '../subscription/subscription_screen.dart';

class MoreScreen extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onDataChanged;
  const MoreScreen({super.key, required this.onLogout, required this.onDataChanged});

  Future<void> _open(BuildContext context, Widget screen) async {
    final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => screen));
    if (changed == true) onDataChanged();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('More modules', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
        const SizedBox(height: 14),
        SectionCard(
          title: 'Accounting tools',
          subtitle: 'Payments, reminders and subscription',
          child: Column(
            children: [
              QuickActionTile(title: 'Payments', subtitle: 'View and receive customer payments', icon: Icons.payments_rounded, onTap: () => _open(context, const PaymentListScreen())),
              const SizedBox(height: 10),
              QuickActionTile(title: 'Reminders', subtitle: 'Payment due and follow-up reminders', icon: Icons.notifications_active_rounded, onTap: () => _open(context, const ReminderListScreen())),
              const SizedBox(height: 10),
              QuickActionTile(title: 'Subscription', subtitle: 'View trial/plan status', icon: Icons.workspace_premium_rounded, onTap: () => _open(context, const SubscriptionScreen())),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'App status',
          subtitle: 'Live API connected to Railway PostgreSQL',
          child: Column(
            children: [
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Icon(Icons.cloud_done_rounded)),
                title: Text('Server connected'),
                subtitle: Text('smart-khata-production.up.railway.app'),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(child: Icon(Icons.logout_rounded)),
                title: const Text('Logout'),
                subtitle: const Text('Clear this phone session'),
                onTap: onLogout,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
