class Customer {
  final String publicId;
  final String customerName;
  final String? phoneNumber;
  final String? whatsAppNumber;
  final String? city;
  final String? address;
  final String? email;
  final String currentBalance;

  Customer({
    required this.publicId,
    required this.customerName,
    this.phoneNumber,
    this.whatsAppNumber,
    this.city,
    this.address,
    this.email,
    required this.currentBalance,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      publicId: json['publicId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString(),
      whatsAppNumber: json['whatsAppNumber']?.toString(),
      city: json['city']?.toString(),
      address: json['address']?.toString(),
      email: json['email']?.toString(),
      currentBalance: json['currentBalance']?.toString() ?? '0',
    );
  }
}
