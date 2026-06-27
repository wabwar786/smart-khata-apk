import '../utils/json_utils.dart';

class SalesInvoice {
  final String publicId;
  final String invoiceNo;
  final String customerName;
  final double grandTotal;
  final double paidAmount;
  final double balanceAmount;
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
      publicId: JsonUtils.str(json['publicId']),
      invoiceNo: JsonUtils.str(json['invoiceNo']),
      customerName: JsonUtils.str(json['customerName'], 'Cash Customer'),
      grandTotal: JsonUtils.number(json['grandTotal']),
      paidAmount: JsonUtils.number(json['paidAmount']),
      balanceAmount: JsonUtils.number(json['balanceAmount']),
      paymentStatus: JsonUtils.str(json['paymentStatus']),
      invoiceDate: JsonUtils.str(json['invoiceDate']),
    );
  }
}
