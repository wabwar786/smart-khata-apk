import 'package:flutter/material.dart';

import '../../widgets/pro_widgets.dart';
import '../payments/payment_list_screen.dart';
import '../reminders/reminder_list_screen.dart';
import '../subscription/subscription_screen.dart';
import '../modules/global_search_screen.dart';
import '../modules/offline_sync_screen.dart';
import '../modules/reports_screen.dart';
import '../modules/simple_module_screen.dart';

class MoreScreen extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onDataChanged;
  const MoreScreen({super.key, required this.onLogout, required this.onDataChanged});

  Future<void> _open(BuildContext context, Widget screen) async {
    final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => screen));
    if (changed == true) onDataChanged();
  }

  Widget _tile(BuildContext context, ModuleConfig config) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: QuickActionTile(
        title: config.title,
        subtitle: config.subtitle,
        icon: config.icon,
        onTap: () => _open(context, SimpleModuleScreen(config: config)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final partyModules = [
      const ModuleConfig(
        title: 'Suppliers',
        subtitle: 'Supplier profiles and payable khata',
        endpoint: '/api/suppliers',
        icon: Icons.local_shipping_rounded,
        canAdd: true,
        fields: [
          ModuleField(key: 'supplierName', label: 'Supplier name', required: true),
          ModuleField(key: 'phoneNumber', label: 'Phone number'),
          ModuleField(key: 'whatsAppNumber', label: 'WhatsApp number'),
          ModuleField(key: 'city', label: 'City'),
          ModuleField(key: 'openingBalance', label: 'Opening balance', keyboardType: TextInputType.number),
        ],
      ),
      const ModuleConfig(title: 'Customer Ledger', subtitle: 'Open customers tab for full ledger', endpoint: '/api/reports/receivables', icon: Icons.account_balance_wallet_rounded),
      const ModuleConfig(title: 'Supplier Payables', subtitle: 'Supplier balance report', endpoint: '/api/reports/payables', icon: Icons.request_quote_rounded),
    ];

    final accountingModules = [
      const ModuleConfig(
        title: 'Cash Book',
        subtitle: 'Cash in, cash out and daily cash record',
        endpoint: '/api/cashbook',
        icon: Icons.menu_book_rounded,
        canAdd: true,
        fields: [
          ModuleField(key: 'title', label: 'Title', required: true),
          ModuleField(key: 'entryType', label: 'Type CASH_IN / CASH_OUT', required: true),
          ModuleField(key: 'amount', label: 'Amount', keyboardType: TextInputType.number, required: true),
          ModuleField(key: 'description', label: 'Description'),
        ],
      ),
      const ModuleConfig(
        title: 'Bank / Wallet Accounts',
        subtitle: 'Cash, bank, Easypaisa, JazzCash, Raast, card',
        endpoint: '/api/accounts',
        icon: Icons.account_balance_rounded,
        canAdd: true,
        fields: [
          ModuleField(key: 'accountName', label: 'Account name', required: true),
          ModuleField(key: 'accountType', label: 'Type CASH/BANK/EASYPAISA/JAZZCASH/RAAST'),
          ModuleField(key: 'accountNumber', label: 'Account number'),
          ModuleField(key: 'openingBalance', label: 'Opening balance', keyboardType: TextInputType.number),
        ],
      ),
      const ModuleConfig(
        title: 'Expenses',
        subtitle: 'Business expense entry and report',
        endpoint: '/api/expenses',
        icon: Icons.money_off_csred_rounded,
        canAdd: true,
        fields: [
          ModuleField(key: 'title', label: 'Expense title', required: true),
          ModuleField(key: 'amount', label: 'Amount', keyboardType: TextInputType.number, required: true),
          ModuleField(key: 'paymentMethod', label: 'Payment method'),
          ModuleField(key: 'description', label: 'Description'),
        ],
      ),
      const ModuleConfig(title: 'Expense Categories', subtitle: 'Rent, salary, electricity, transport etc.', endpoint: '/api/expenses/categories', icon: Icons.category_rounded, canAdd: true, fields: [ModuleField(key: 'categoryName', label: 'Category name', required: true)]),
      const ModuleConfig(title: 'Cheques', subtitle: 'Pending, cleared and bounced cheques', endpoint: '/api/cheques', icon: Icons.fact_check_rounded, canAdd: true, fields: [ModuleField(key: 'chequeNo', label: 'Cheque number'), ModuleField(key: 'bankName', label: 'Bank name'), ModuleField(key: 'amount', label: 'Amount', keyboardType: TextInputType.number, required: true), ModuleField(key: 'status', label: 'PENDING/CLEARED/BOUNCED')]),
    ];

    final inventoryModules = [
      const ModuleConfig(title: 'Purchases', subtitle: 'Purchase bills and supplier stock entries', endpoint: '/api/purchases', icon: Icons.shopping_cart_checkout_rounded),
      const ModuleConfig(title: 'Stock Report', subtitle: 'Stock value and low stock check', endpoint: '/api/reports/stock', icon: Icons.inventory_rounded),
      const ModuleConfig(title: 'Product Categories', subtitle: 'Product category master', endpoint: '/api/lookups/product-categories', icon: Icons.view_module_rounded, canAdd: true, fields: [ModuleField(key: 'categoryName', label: 'Category name', required: true)]),
      const ModuleConfig(title: 'Units', subtitle: 'Piece, Kg, Box, Packet etc.', endpoint: '/api/lookups/units', icon: Icons.straighten_rounded),
    ];

    final staffModules = [
      const ModuleConfig(title: 'Staff / Employees', subtitle: 'Staff profiles, roles and salary basics', endpoint: '/api/staff', icon: Icons.badge_rounded, canAdd: true, fields: [ModuleField(key: 'fullName', label: 'Full name', required: true), ModuleField(key: 'phoneNumber', label: 'Phone number'), ModuleField(key: 'roleTitle', label: 'Role title'), ModuleField(key: 'salaryAmount', label: 'Salary amount', keyboardType: TextInputType.number)]),
      const ModuleConfig(title: 'Attendance', subtitle: 'Present, absent, half day, leave and late', endpoint: '/api/attendance', icon: Icons.event_available_rounded),
      const ModuleConfig(title: 'Payroll', subtitle: 'Salary run, paid amount and status', endpoint: '/api/payroll', icon: Icons.payments_rounded, canAdd: true, fields: [ModuleField(key: 'title', label: 'Payroll title'), ModuleField(key: 'payrollMonth', label: 'Payroll month YYYY-MM-DD'), ModuleField(key: 'grossAmount', label: 'Gross amount', keyboardType: TextInputType.number), ModuleField(key: 'netAmount', label: 'Net amount', keyboardType: TextInputType.number)]),
    ];

    final adminModules = [
      const ModuleConfig(title: 'Branches', subtitle: 'Multi-store / branch setup', endpoint: '/api/branches', icon: Icons.store_mall_directory_rounded, canAdd: true, fields: [ModuleField(key: 'branchName', label: 'Branch name', required: true), ModuleField(key: 'phoneNumber', label: 'Phone number'), ModuleField(key: 'city', label: 'City'), ModuleField(key: 'address', label: 'Address')]),
      const ModuleConfig(title: 'Notifications', subtitle: 'Business alerts and reminders', endpoint: '/api/notifications', icon: Icons.notifications_rounded),
      const ModuleConfig(title: 'Support Tickets', subtitle: 'Create and view support requests', endpoint: '/api/support-tickets', icon: Icons.support_agent_rounded, canAdd: true, fields: [ModuleField(key: 'subject', label: 'Subject', required: true), ModuleField(key: 'message', label: 'Message'), ModuleField(key: 'priority', label: 'LOW/NORMAL/HIGH/URGENT')]),
      const ModuleConfig(title: 'WhatsApp Logs', subtitle: 'Invoice, ledger and reminder sharing logs', endpoint: '/api/whatsapp/logs', icon: Icons.chat_rounded),
    ];

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
              QuickActionTile(title: 'Reports & Export', subtitle: 'Profit/loss, receivables, stock, audit, CSV data', icon: Icons.bar_chart_rounded, onTap: () => _open(context, const ReportsScreen())),
              const SizedBox(height: 10),
              QuickActionTile(title: 'Global Search', subtitle: 'Find customer, supplier, product or invoice', icon: Icons.search_rounded, onTap: () => _open(context, const GlobalSearchScreen())),
              const SizedBox(height: 10),
              QuickActionTile(title: 'Subscription', subtitle: 'View trial/plan status', icon: Icons.workspace_premium_rounded, onTap: () => _open(context, const SubscriptionScreen())),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(title: 'Parties & Khata', subtitle: 'Customer/supplier ledgers and balances', child: Column(children: partyModules.map((m) => _tile(context, m)).toList())),
        const SizedBox(height: 16),
        SectionCard(title: 'Cash, Bank & Expenses', subtitle: 'Daily accounting and payment modes', child: Column(children: accountingModules.map((m) => _tile(context, m)).toList())),
        const SizedBox(height: 16),
        SectionCard(title: 'Inventory & Purchase', subtitle: 'Purchase, stock, units and categories', child: Column(children: inventoryModules.map((m) => _tile(context, m)).toList())),
        const SizedBox(height: 16),
        SectionCard(title: 'Staff, Attendance & Payroll', subtitle: 'Employee management modules', child: Column(children: staffModules.map((m) => _tile(context, m)).toList())),
        const SizedBox(height: 16),
        SectionCard(title: 'Business Admin', subtitle: 'Branches, support, notifications and WhatsApp', child: Column(children: adminModules.map((m) => _tile(context, m)).toList())),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Offline & Backup',
          subtitle: 'Sync-ready structure for unstable internet',
          child: Column(
            children: [
              QuickActionTile(title: 'Offline Sync', subtitle: 'Pull server data and check sync queue endpoint', icon: Icons.sync_rounded, onTap: () => _open(context, const OfflineSyncScreen())),
              const SizedBox(height: 10),
              QuickActionTile(title: 'Backup Request', subtitle: 'Request cloud backup/export from API', icon: Icons.backup_rounded, onTap: () => _open(context, const SimpleModuleScreen(config: ModuleConfig(title: 'Backup Requests', subtitle: 'Backup and export requests', endpoint: '/api/export/customers', icon: Icons.backup_rounded)))),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Coming soon earning services',
          subtitle: 'Provider API required before activation',
          child: Column(
            children: const [
              _ComingSoonTile(title: 'Easyload', subtitle: 'Disabled until provider API is connected', icon: Icons.phone_android_rounded),
              SizedBox(height: 10),
              _ComingSoonTile(title: 'Bill Payment', subtitle: 'Utility bill module placeholder', icon: Icons.receipt_rounded),
              SizedBox(height: 10),
              _ComingSoonTile(title: 'Digital Vouchers', subtitle: 'Voucher sale and commission wallet', icon: Icons.card_giftcard_rounded),
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

class _ComingSoonTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _ComingSoonTile({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      trailing: const Chip(label: Text('Coming soon')),
    );
  }
}
