import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../utils/formatters.dart';
import '../../utils/json_utils.dart';
import '../../widgets/pro_widgets.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _loading = true;
  String _error = '';
  Map<String, dynamic>? _sub;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final res = await ApiClient.instance.get('/api/subscriptions/current');
      setState(() => _sub = JsonUtils.map(res['data']));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error, textAlign: TextAlign.center))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    GradientHeaderCard(
                      title: 'Current plan',
                      subtitle: JsonUtils.str(_sub?['subscription_status'] ?? _sub?['subscriptionStatus'], 'No subscription'),
                      amount: JsonUtils.str(_sub?['plan_name'] ?? _sub?['planName'], 'Trial'),
                      footer: 'Valid until: ${Formatters.date(_sub?['end_date'] ?? _sub?['endDate'])}',
                      icon: Icons.workspace_premium_rounded,
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      title: 'Plan details',
                      child: Column(
                        children: [
                          ListTile(contentPadding: EdgeInsets.zero, title: const Text('Monthly price'), trailing: Text(Formatters.amount(_sub?['monthly_price'] ?? _sub?['monthlyPrice']))),
                          const Divider(),
                          ListTile(contentPadding: EdgeInsets.zero, title: const Text('Currency'), trailing: Text(JsonUtils.str(_sub?['currency_code'] ?? _sub?['currencyCode'], 'PKR'))),
                          const Divider(),
                          const Text('Manual payment approval screen will be added in the next admin panel phase.', style: TextStyle(color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
