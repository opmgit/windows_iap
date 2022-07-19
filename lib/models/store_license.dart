class StoreLicense {
  final bool? isActive;
  final String? skuStoreId;
  final String? inAppOfferToken;
  final num? expirationDate;

  const StoreLicense({
    this.isActive,
    this.skuStoreId,
    this.inAppOfferToken,
    this.expirationDate,
  });

  factory StoreLicense.fromJson(Map<String, dynamic> json) {
    return StoreLicense(
        isActive: json['isActive'],
        skuStoreId: json['skuStoreId'],
        inAppOfferToken: json['inAppOfferToken'],
        expirationDate: json['expirationDate']);
  }

  Map<String, dynamic> toJson() {
    return {
      'isActive': isActive,
      'skuStoreId': skuStoreId,
      'inAppOfferToken': inAppOfferToken,
      'expirationDate': expirationDate,
    };
  }
}
