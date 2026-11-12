import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wasselni_admin/features/pricing/data/models/pricing_settings_model.dart';

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
  DocumentReference<Map<String, dynamic>> get _pricingSettingsDocument =>
      _firestore.collection('settings').doc('pricing');

  Stream<PricingSettings> watchPricingSettings() {
    return _pricingSettingsDocument.snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return const PricingSettings(
          basePrice: 0,
          pricePerKm: 0,
          minimumDeliveryPrice: 0,
        );
      }

      return PricingSettings.fromMap(snapshot.data()!);
    });
  }

  Future<void> updatePricingSettings(PricingSettings settings) async {
    await _pricingSettingsDocument.set({
      ...settings.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
