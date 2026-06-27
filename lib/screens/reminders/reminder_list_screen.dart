import 'package:flutter/material.dart';

import '../../models/reminder.dart';
import '../../services/api_client.dart';
import '../../utils/formatters.dart';
import '../../utils/json_utils.dart';
import 'reminder_form_screen.dart';

class ReminderListScreen extends StatefulWidget {
  const ReminderListScreen({super.key});

  @override
  State<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen> {
  bool _loading = true;
  String _error = '';
  List<ReminderItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final res = await ApiClient.instance.get('/api/reminders', query: {'limit': 100});
      final rows = JsonUtils.list(res['data']);
      setState(() => _items = rows.map((e) => ReminderItem.fromJson(JsonUtils.map(e))).toList());
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _add() async {
    final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const ReminderFormScreen()));
    if (changed == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error, textAlign: TextAlign.center))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _items.isEmpty
                      ? const Center(child: Text('No reminders yet.'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final r = _items[i];
                            return Card(
                              child: ListTile(
                                leading: const CircleAvatar(child: Icon(Icons.notifications_active_rounded)),
                                title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                                subtitle: Text('${Formatters.date(r.reminderDateTime)} • ${r.type}${r.customerName.isEmpty ? '' : ' • ${r.customerName}'}'),
                                trailing: Text(r.status, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                              ),
                            );
                          },
                        ),
                ),
      floatingActionButton: FloatingActionButton.extended(onPressed: _add, icon: const Icon(Icons.add), label: const Text('Reminder')),
    );
  }
}
