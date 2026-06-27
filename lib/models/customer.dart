import '../utils/json_utils.dart';

class Customer {
  final String publicId;
  final String customerName;
  final String? phoneNumber;
  final String? whatsAppNumber;
  final String? city;
  final String? address;
  final String? email;
  final double currentBalance;
  final double creditLimit;

  Customer({
    required this.publicId,
    required this.customerName,
    this.phoneNumber,
    this.whatsAppNumber,
    this.city,
    this.address,
    this.email,
    required this.currentBalance,
    required this.creditLimit,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      publicId: JsonUtils.str(json['publicId']),
      customerName: JsonUtils.str(json['customerName']),
      phoneNumber: JsonUtils.str(json['phoneNumber'], ''),
      whatsAppNumber: JsonUtils.str(json['whatsAppNumber'], ''),
      city: JsonUtils.str(json['city'], ''),
      address: JsonUtils.str(json['address'], ''),
      email: JsonUtils.str(json['email'], ''),
      currentBalance: JsonUtils.number(json['currentBalance']),
      creditLimit: JsonUtils.number(json['creditLimit']),
    );
  }
}
