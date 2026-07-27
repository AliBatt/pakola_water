import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  FirebaseFirestore get instance => _firestore;

  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }

  DocumentReference<Map<String, dynamic>> doc(String path, String id) {
    return _firestore.collection(path).doc(id);
  }

  Future<void> setDoc(
    String path,
    String id,
    Map<String, dynamic> data, {
    bool merge = false,
  }) {
    return doc(path, id).set(data, SetOptions(merge: merge));
  }

  Future<void> updateDoc(
    String path,
    String id,
    Map<String, dynamic> data,
  ) {
    return doc(path, id).update(data);
  }

  Future<void> deleteDoc(String path, String id) {
    return doc(path, id).delete();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> queryWhere(
    String path, {
    required String field,
    required Object isEqualTo,
  }) {
    return collection(path).where(field, isEqualTo: isEqualTo).get();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchDoc(
    String path,
    String id,
  ) {
    return doc(path, id).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchWhere(
    String path, {
    required String field,
    required Object isEqualTo,
  }) {
    return collection(path).where(field, isEqualTo: isEqualTo).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchWhereOrderBy(
    String path, {
    required String field,
    required Object isEqualTo,
    required String orderBy,
    bool descending = true,
  }) {
    return collection(path)
        .where(field, isEqualTo: isEqualTo)
        .orderBy(orderBy, descending: descending)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchCollectionOrderBy(
    String path, {
    required String orderBy,
    bool descending = true,
  }) {
    return collection(path)
        .orderBy(orderBy, descending: descending)
        .snapshots();
  }

  CollectionReference<Map<String, dynamic>> subcollection(
    String parentPath,
    String parentId,
    String subPath,
  ) {
    return doc(parentPath, parentId).collection(subPath);
  }
}
