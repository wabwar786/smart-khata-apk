import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../utils/json_utils.dart';
import '../../widgets/sk_widgets.dart';
import 'pos_screen.dart';

class SaleSuccessScreen extends StatefulWidget {
  final double total;
  final String paymentType;
  final Map<String, dynamic> invoice;
  final List<SaleItemDraft> items;
  const SaleSuccessScreen({super.key, required this.total, required this.paymentType, required this.invoice, required this.items});
  @override
  State<SaleSuccessScreen> createState() => _SaleSuccessScreenState();
}

class _SaleSuccessScreenState extends State<SaleSuccessScreen> {
  bool _invoiceTab = false;
  @override
  Widget build(BuildContext context) {
    final no = JsonUtils.str(widget.invoice['invoiceNo'] ?? widget.invoice['invoice_no'], 'Draft');
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(child: ListView(padding: const EdgeInsets.all(18), children: [
        Align(alignment: Alignment.center, child: Container(height: 50, width: 230, padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFFEAF8FF), borderRadius: BorderRadius.circular(24)), child: Row(children: [_switch('Receipt', false), _switch('Invoice', true)]))),
        Align(alignment: Alignment.centerRight, child: IconButton(icon: const Icon(Icons.settings_rounded, color: AppColors.primary), onPressed: () {})),
        const SizedBox(height: 8),
        _invoiceTab ? _invoice(no) : _receipt(no),
        const SizedBox(height: 24),
        PillButton(text: 'VIEW SALES', icon: Icons.receipt_long_rounded, outlined: true, color: AppColors.primary, onTap: () => Navigator.pop(context)),
        const SizedBox(height: 12),
        PillButton(text: 'NEW SALE', icon: Icons.add_rounded, onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const PosScreen()))),
      ])),
    );
  }
  Widget _switch(String t, bool v) => Expanded(child: GestureDetector(onTap: () => setState(() => _invoiceTab = v), child: Container(alignment: Alignment.center, decoration: BoxDecoration(color: _invoiceTab == v ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(22)), child: Text(t, style: TextStyle(fontWeight: FontWeight.w900, color: _invoiceTab == v ? AppColors.primary : AppColors.text)))));

  Widget _receipt(String no) => Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)), child: Column(children: [
    Text(Formatters.amount(widget.total), style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900)),
    Text(widget.paymentType == 'CASH' ? 'Paid with cash' : widget.paymentType == 'UDHAAR' ? 'Added to udhaar' : 'Collect online', style: AppText.h3),
    const SizedBox(height: 28), const Divider(height: 1), const SizedBox(height: 24),
    Row(children: [const Expanded(child: Text('Date', style: AppText.small)), Text(Formatters.date(DateTime.now().toIso8601String()), style: AppText.body)]),
    const SizedBox(height: 18),
    for (final item in widget.items) Row(children: [Expanded(child: Text(item.name, style: AppText.body)), Text('${item.qty.toStringAsFixed(0)} x ', style: AppText.small), Text(Formatters.amount(item.total), style: AppText.body)]),
    const SizedBox(height: 40),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.print_rounded), SizedBox(width: 30), Icon(Icons.share_rounded), SizedBox(width: 30), Icon(Icons.download_rounded)]),
  ]));

  Widget _invoice(String no) => Container(color: Colors.white, child: Column(children: [
    Container(color: const Color(0xFF3B3B3B), padding: const EdgeInsets.all(16), child: Row(children: [const CircleAvatar(backgroundColor: Colors.white), const SizedBox(width: 12), const Expanded(child: Text('Smart Khata', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900))), Text('INV# $no', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))])),
    Padding(padding: const EdgeInsets.all(18), child: Column(children: [
      Table(columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(), 2: FlexColumnWidth()}, children: [
        const TableRow(children: [Text('Item Description', style: AppText.small), Text('Qty', style: AppText.small), Text('Amount', style: AppText.small)]),
        for (final item in widget.items) TableRow(children: [Padding(padding: const EdgeInsets.only(top: 10), child: Text(item.name)), Padding(padding: const EdgeInsets.only(top: 10), child: Text(item.qty.toStringAsFixed(0))), Padding(padding: const EdgeInsets.only(top: 10), child: Text(Formatters.amount(item.total)))]),
      ]),
      const SizedBox(height: 80), Align(alignment: Alignment.centerRight, child: Text('Total: ${Formatters.amount(widget.total)}', style: AppText.h3)),
      const SizedBox(height: 34), Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [PillButton(text: 'PRINT', outlined: true, color: AppColors.primary, onTap: () {}), PillButton(text: 'SHARE', outlined: true, color: AppColors.green, onTap: () {})]),
    ])),
  ]));
}
