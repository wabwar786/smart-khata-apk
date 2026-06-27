import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/sk_widgets.dart';
import '../pos/pos_screen.dart';
import 'amount_entry_screen.dart';

class PartyActionScreen extends StatelessWidget {
  final String partyType;
  final String publicId;
  final String name;
  final String phone;
  final bool justCreated;
  const PartyActionScreen({super.key, required this.partyType, required this.publicId, required this.name, required this.phone, this.justCreated = false});

  bool get isCustomer => partyType == 'customer';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Row(children: [CircleAvatar(backgroundColor: Colors.white, child: Text(name.isEmpty ? '?' : name[0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900))), const SizedBox(width: 12), Expanded(child: Text(name)), const Icon(Icons.edit_rounded, size: 20)]), actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.picture_as_pdf_rounded)), PopupMenuButton(itemBuilder: (_) => const [PopupMenuItem(child: Text('Edit')), PopupMenuItem(child: Text('Delete'))])]),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            const SizedBox(height: 30),
            const InfoLine(icon: Icons.verified_user_rounded, title: 'Aapki sab entries safe and secure hain', subtitle: 'Every entry is saved with user and time record.', color: AppColors.green),
            const Spacer(),
            Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)), child: Column(children: [
              Text(justCreated ? 'What do you want to do with this ${isCustomer ? 'customer' : 'supplier'}?' : 'Select action for $name', textAlign: TextAlign.center, style: AppText.h3),
              const SizedBox(height: 18),
              if (isCustomer) ...[
                PillButton(text: 'SALE KARNI HAI', icon: Icons.point_of_sale_rounded, color: AppColors.green, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PosScreen(prefilledCustomerId: publicId, prefilledCustomerName: name)))),
                const SizedBox(height: 12),
                Row(children: [Expanded(child: PillButton(text: 'PAYMENT LENI HAI', icon: Icons.arrow_downward_rounded, outlined: true, color: AppColors.green, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AmountEntryScreen(partyType: partyType, partyId: publicId, partyName: name, actionType: 'received'))))), const SizedBox(width: 10), Expanded(child: PillButton(text: 'MAINE DIYE', icon: Icons.arrow_upward_rounded, outlined: true, color: AppColors.orange, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AmountEntryScreen(partyType: partyType, partyId: publicId, partyName: name, actionType: 'paid')))))])
              ] else ...[
                PillButton(text: 'PURCHASE / STOCK LENA HAI', icon: Icons.inventory_2_rounded, color: AppColors.green, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AmountEntryScreen(partyType: partyType, partyId: publicId, partyName: name, actionType: 'purchase')))),
                const SizedBox(height: 12),
                Row(children: [Expanded(child: PillButton(text: 'PAYMENT DENI HAI', icon: Icons.arrow_upward_rounded, outlined: true, color: AppColors.orange, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AmountEntryScreen(partyType: partyType, partyId: publicId, partyName: name, actionType: 'paid'))))), const SizedBox(width: 10), Expanded(child: PillButton(text: 'RECEIVE KARNI HAI', icon: Icons.arrow_downward_rounded, outlined: true, color: AppColors.green, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AmountEntryScreen(partyType: partyType, partyId: publicId, partyName: name, actionType: 'received')))))])
              ],
            ])),
          ]),
        ),
      ),
    );
  }
}
