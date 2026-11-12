import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceArea {
  final String id;
  final String cityName;
  final String areaName;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ServiceArea({
    required this.id,
    required this.cityName,
    this.areaName = '',
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceArea.fromMap(String id, Map<String, dynamic> data) {
    return ServiceArea(
      id: id,
      cityName: data['cityName'] ?? '',
      areaName: data['areaName'] ?? '',
      isActive: data['isActive'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'cityName': cityName, 'areaName': areaName, 'isActive': isActive};
  }
}
