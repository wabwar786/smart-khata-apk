class Product {
  final String publicId;
  final String productName;
  final String? sku;
  final String productType;
  final int unitId;
  final String? unitCode;
  final String salePrice;
  final String purchasePrice;
  final String currentStock;

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
      publicId: json['publicId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      sku: json['sku']?.toString(),
      productType: json['productType']?.toString() ?? 'PRODUCT',
      unitId: int.tryParse(json['unitId']?.toString() ?? '1') ?? 1,
      unitCode: json['unitCode']?.toString(),
      salePrice: json['salePrice']?.toString() ?? '0',
      purchasePrice: json['purchasePrice']?.toString() ?? '0',
      currentStock: json['currentStock']?.toString() ?? '0',
    );
  }
}
