import '../utils/json_utils.dart';

class Product {
  final String publicId;
  final String productName;
  final String? sku;
  final String productType;
  final int unitId;
  final String? unitCode;
  final double salePrice;
  final double purchasePrice;
  final double currentStock;

  Product({
    required this.publicId,
    required this.productName,
    this.sku,
    required this.productType,
    required this.unitId,
    this.unitCode,
    required this.salePrice,
    required this.purchasePrice,
    required this.currentStock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      publicId: JsonUtils.str(json['publicId']),
      productName: JsonUtils.str(json['productName']),
      sku: JsonUtils.str(json['sku'], ''),
      productType: JsonUtils.str(json['productType'], 'PRODUCT'),
      unitId: JsonUtils.integer(json['unitId'], 1),
      unitCode: JsonUtils.str(json['unitCode'], ''),
      salePrice: JsonUtils.number(json['salePrice']),
      purchasePrice: JsonUtils.number(json['purchasePrice']),
      currentStock: JsonUtils.number(json['currentStock']),
    );
  }
}
