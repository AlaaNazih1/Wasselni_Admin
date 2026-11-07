import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardRepository {
  final FirebaseFirestore _firestore;

  DashboardRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<int> watchTotalOrders() {
    return _firestore
        .collectionGroup('orders')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Stream<int> watchTotalCustomers() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Stream<int> watchTotalDrivers() {
    return _firestore
        .collection('drivers')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Stream<int> watchCompletedOrders() {
    return _firestore
        .collectionGroup('orders')
        .where('status', isEqualTo: 'delivered')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }
}
