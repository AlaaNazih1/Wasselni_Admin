import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDriversRepository {
  final FirebaseFirestore _firestore;

  AdminDriversRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> watchAllDrivers() {
    return _firestore.collection('drivers').snapshots().map((snapshot) {
      final drivers = snapshot.docs.map((document) {
        return {...document.data(), 'driverId': document.id};
      }).toList();

      // ترتيب المندوبين بالأحدث أولاً.
      drivers.sort((a, b) {
        final dateA = a['createdAt'];
        final dateB = b['createdAt'];

        if (dateA is! Timestamp || dateB is! Timestamp) {
          return 0;
        }

        return dateB.compareTo(dateA);
      });

      return drivers;
    });
  }

  Future<List<Map<String, dynamic>>> getDriverOrders(String driverId) async {
    final snapshot = await _firestore
        .collectionGroup('orders')
        .where('driverId', isEqualTo: driverId)
        .get();

    return snapshot.docs.map((document) {
      return {
        ...document.data(),
        'orderId': document.id,
        'customerId': document.reference.parent.parent?.id,
      };
    }).toList();
  }

  Future<void> approveDriver(String driverId) async {
    await _firestore.collection('drivers').doc(driverId).update({
      'isApproved': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> activateDriver(String driverId) async {
    await _firestore.collection('drivers').doc(driverId).update({
      'isActive': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deactivateDriver(String driverId) async {
    await _firestore.collection('drivers').doc(driverId).update({
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

}
