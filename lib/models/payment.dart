import '../utils/json_utils.dart';

class PaymentReceived {
  final String publicId;
  final String customerName;
  final double amount;
  final String paymentMethod;
  final String paymentDate;
  final String description;

  PaymentReceived({required this.publicId, required this.customerName, required this.amount, required this.paymentMethod, required this.paymentDate, required this.description});

  factory PaymentReceived.fromJson(Map<String, dynamic> json) {
    return PaymentReceived(
      publicId: JsonUtils.str(json['publicId']),
      customerName: JsonUtils.str(json['customerName']),
      amount: JsonUtils.number(json['amount']),
      paymentMethod: JsonUtils.str(json['paymentMethod'], 'Cash'),
      paymentDate: JsonUtils.str(json['paymentDate']),
      description: JsonUtils.str(json['description']),
    );
  }
}
