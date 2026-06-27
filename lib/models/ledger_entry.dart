import '../utils/json_utils.dart';

class LedgerEntry {
  final String ledgerDate;
  final String entryType;
  final double debitAmount;
  final double creditAmount;
  final double balanceAfter;
  final String description;

  LedgerEntry({required this.ledgerDate, required this.entryType, required this.debitAmount, required this.creditAmount, required this.balanceAfter, required this.description});

  factory LedgerEntry.fromJson(Map<String, dynamic> json) {
    return LedgerEntry(
      ledgerDate: JsonUtils.str(json['ledger_date'] ?? json['ledgerDate']),
      entryType: JsonUtils.str(json['entry_type'] ?? json['entryType']),
      debitAmount: JsonUtils.number(json['debit_amount'] ?? json['debitAmount']),
      creditAmount: JsonUtils.number(json['credit_amount'] ?? json['creditAmount']),
      balanceAfter: JsonUtils.number(json['balance_after'] ?? json['balanceAfter']),
      description: JsonUtils.str(json['description']),
    );
  }
}
