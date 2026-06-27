import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class SkLogo extends StatelessWidget {
  final double size;
  final bool circular;
  const SkLogo({super.key, this.size = 72, this.circular = true});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circular ? null : BorderRadius.circular(size * .24),
        color: AppColors.primary,
        boxShadow: [BoxShadow(color: AppColors.primary.withAlpha(35), blurRadius: 24, offset: const Offset(0, 12))],
      ),
      child: Center(
        child: Text('خ', style: TextStyle(color: Colors.white, fontSize: size * .58, fontWeight: FontWeight.w900, height: .95)),
      ),
    );
  }
}

class PillButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color color;
  final Color foreground;
  final bool outlined;
  const PillButton({super.key, required this.text, this.icon, this.onTap, this.color = AppColors.green, this.foreground = Colors.white, this.outlined = false});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: outlined
          ? OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon ?? Icons.chevron_right_rounded),
              label: Text(text),
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color, width: 1.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon ?? Icons.chevron_right_rounded),
              label: Text(text),
              style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: foreground),
            ),
    );
  }
}

class InfoLine extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const InfoLine({super.key, required this.icon, required this.title, required this.subtitle, required this.color});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withAlpha(28), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color, size: 20)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primary)),
        const SizedBox(height: 2),
        Text(subtitle, style: AppText.small),
      ])),
    ]);
  }
}

class MoneyCard extends StatelessWidget {
  final String title;
  final dynamic amount;
  final IconData icon;
  final Color color;
  final String? footer;
  const MoneyCard({super.key, required this.title, required this.amount, required this.icon, required this.color, this.footer});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.line)),
      child: Row(children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: color.withAlpha(22), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: color)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppText.small),
          const SizedBox(height: 3),
          Text(Formatters.amount(amount), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.text)),
          if (footer != null) Text(footer!, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.small),
        ])),
      ]),
    );
  }
}

class SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  const SearchBox({super.key, required this.controller, required this.hint, this.onChanged});
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(prefixIcon: const Icon(Icons.search_rounded), hintText: hint, fillColor: const Color(0xFFF1F3F6), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none)),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 58, color: AppColors.primary.withAlpha(120)),
      const SizedBox(height: 12),
      Text(title, textAlign: TextAlign.center, style: AppText.h3),
      const SizedBox(height: 6),
      Text(subtitle, textAlign: TextAlign.center, style: AppText.small),
    ])));
  }
}
