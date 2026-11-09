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
        .asyncMap((snapshot) async {
          final orders = snapshot.docs.map((document) {
            return <String, dynamic>{
              ...document.data(),
              'orderId': document.id,
              'orderReference': document.reference,
              'customerId': document.reference.parent.parent?.id,
            };
          }).toList();

          // استخراج IDs العملاء بدون تكرار.
          final customerIds = orders
              .map((order) => order['customerId']?.toString())
              .whereType<String>()
              .toSet();

          // تحميل بيانات العملاء.
          final customerFutures = customerIds.map((id) async {
            final customerDoc = await _firestore
                .collection('users')
                .doc(id)
                .get();

            return MapEntry(
              id,
              customerDoc.data()?['name']?.toString() ?? 'عميل غير معروف',
            );
          });

          final customerEntries = await Future.wait(customerFutures);
          final customerNames = Map.fromEntries(customerEntries);

          // إضافة اسم العميل لكل طلب.
          for (final order in orders) {
            final customerId = order['customerId']?.toString();

            order['customerName'] =
                customerNames[customerId] ?? 'عميل غير معروف';
          }

          return orders;
        });
  }
}
