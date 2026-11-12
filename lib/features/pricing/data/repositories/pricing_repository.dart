import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/service_area_model.dart';

class PricingRepository {
  final FirebaseFirestore _firestore;

  PricingRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _areasCollection =>
      _firestore.collection('service_areas');

  // Watch all service areas
  Stream<List<ServiceArea>> watchServiceAreas() {
    return _areasCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((document) {
            return ServiceArea.fromMap(document.id, document.data());
          }).toList();
        });
  }

  // Add new service area
  Future<void> addServiceArea(ServiceArea area) async {
    await _areasCollection.add({
      ...area.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update service area
  Future<void> updateServiceArea(ServiceArea area) async {
    await _areasCollection.doc(area.id).update({
      ...area.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Toggle service area status
  Future<void> toggleServiceArea(String areaId, bool isActive) async {
    await _areasCollection.doc(areaId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete service area
  Future<void> deleteServiceArea(String areaId) async {
    await _areasCollection.doc(areaId).delete();
  }
}
