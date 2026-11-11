import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCustomersRepository {
  final FirebaseFirestore _firestore;

  AdminCustomersRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> watchAllCustomers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      final customers = snapshot.docs.map((document) {
        return {...document.data(), 'customerId': document.id};
      }).toList();

      customers.sort((a, b) {
        final dateA = a['createdAt'];
        final dateB = b['createdAt'];

        if (dateA is! Timestamp || dateB is! Timestamp) {
          return 0;
        }

        return dateB.compareTo(dateA);
      });

      return customers;
    });
  }

  Future<List<Map<String, dynamic>>> getCustomerOrders(
    String customerId,
  ) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(customerId)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((document) {
      return {...document.data(), 'orderId': document.id};
    }).toList();
  }
}
