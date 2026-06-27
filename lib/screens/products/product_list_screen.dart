import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../services/api_client.dart';
import '../../utils/formatters.dart';
import '../../utils/json_utils.dart';
import 'product_form_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  bool _loading = true;
  String _error = '';
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final res = await ApiClient.instance.get('/api/products', query: {'limit': 100});
      final rows = JsonUtils.list(res['data']);
      setState(() => _products = rows.map((e) => Product.fromJson(JsonUtils.map(e))).toList());
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openAdd() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const ProductFormScreen()),
    );
    if (changed == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      body: _error.isNotEmpty
          ? Center(child: Text(_error))
          : RefreshIndicator(
              onRefresh: _load,
              child: _products.isEmpty
                  ? const Center(child: Text('No products yet. Tap + to add.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemBuilder: (_, i) {
                        final p = _products[i];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(child: Icon(p.productType == 'SERVICE' ? Icons.handyman_rounded : Icons.inventory_2_rounded)),
                            title: Text(p.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('Stock: ${p.currentStock} ${p.unitCode ?? ''}${p.sku == null || p.sku!.isEmpty ? '' : ' • ${p.sku}'}'),
                            trailing: Text(Formatters.amount(p.salePrice), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemCount: _products.length,
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAdd,
        icon: const Icon(Icons.add),
        label: const Text('Product'),
      ),
    );
  }
}
