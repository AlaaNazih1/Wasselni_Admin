import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrdersRepository {
  final FirebaseFirestore _firestore;

  AdminOrdersRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> watchAllOrders() {
    return _firestore
        .collectionGroup('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((document) {
            return {
              ...document.data(),
              'orderId': document.id,
              'orderReference': document.reference,
              'customerId': document.reference.parent.parent?.id,
            };
          }).toList();
        });
  }
}
