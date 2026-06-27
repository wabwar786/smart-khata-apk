class SalesInvoice {
  final String publicId;
  final String invoiceNo;
  final String customerName;
  final String grandTotal;
  final String paidAmount;
  final String balanceAmount;
  final String paymentStatus;
  final String invoiceDate;

  SalesInvoice({
    required this.publicId,
    required this.invoiceNo,
    required this.customerName,
    required this.grandTotal,
    required this.paidAmount,
    required this.balanceAmount,
    required this.paymentStatus,
    required this.invoiceDate,
  });

  factory SalesInvoice.fromJson(Map<String, dynamic> json) {
    return SalesInvoice(
      publicId: json['publicId']?.toString() ?? '',
      invoiceNo: json['invoiceNo']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? 'Cash Customer',
      grandTotal: json['grandTotal']?.toString() ?? '0',
      paidAmount: json['paidAmount']?.toString() ?? '0',
      balanceAmount: json['balanceAmount']?.toString() ?? '0',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      invoiceDate: json['invoiceDate']?.toString() ?? '',
    );
  }
}
