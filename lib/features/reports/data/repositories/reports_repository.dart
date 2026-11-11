import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsRepository {
  final FirebaseFirestore _firestore;

  ReportsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getAllOrders() async {
    final snapshot = await _firestore.collectionGroup('orders').get();

    final orders = snapshot.docs.map((document) {
      return {
        ...document.data(),
        'orderId': document.id,
        'customerId': document.reference.parent.parent?.id,
      };
    }).toList();

    orders.sort((a, b) {
      final dateA = a['createdAt'];
      final dateB = b['createdAt'];

      if (dateA is! Timestamp || dateB is! Timestamp) {
        return 0;
      }

      return dateB.compareTo(dateA);
    });

    return orders;
  }
}
