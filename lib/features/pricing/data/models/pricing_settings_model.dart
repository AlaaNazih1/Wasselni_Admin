class PricingSettings {
  final double basePrice;
  final double pricePerKm;
  final double minimumDeliveryPrice;

  const PricingSettings({
    required this.basePrice,
    required this.pricePerKm,
    required this.minimumDeliveryPrice,
  });

  factory PricingSettings.fromMap(Map<String, dynamic> data) {
    return PricingSettings(
      basePrice: (data['basePrice'] as num?)?.toDouble() ?? 0,
      pricePerKm: (data['pricePerKm'] as num?)?.toDouble() ?? 0,
      minimumDeliveryPrice:
          (data['minimumDeliveryPrice'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'basePrice': basePrice,
      'pricePerKm': pricePerKm,
      'minimumDeliveryPrice': minimumDeliveryPrice,
    };
  }
}
