import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recyclear/models/bin_model.dart';
import 'package:recyclear/services/notification_service.dart';

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  Future<void> setData({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    final reference = firestore.doc(path);
    debugPrint('$path: $data');
    await reference.set(data);
  }

  Future<void> deleteData({required String path}) async {
    final reference = firestore.doc(path);
    debugPrint('delete: $path');
    await reference.delete();
  }

  Stream<List<T>> collectionStream<T>({
    required String path,
    required T Function(Map<String, dynamic> data, String documentId) builder,
    Query Function(Query query)? queryBuilder,
    int Function(T lhs, T rhs)? sort,
  }) {
    Query query = firestore.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final snapshots = query.snapshots();
    return snapshots.map((snapshot) {
      final result = snapshot.docs
          .map((snapshot) =>
              builder(snapshot.data() as Map<String, dynamic>, snapshot.id))
          .where((value) => value != null)
          .toList();
      if (sort != null) {
        result.sort(sort);
      }
      return result;
    });
  }

  Future<T> getDocument<T>({
    required String path,
    required T Function(Map<String, dynamic> data, String documentID) builder,
  }) async {
    final reference = firestore.doc(path);
    final snapshot = await reference.get();
    return builder(snapshot.data() as Map<String, dynamic>, snapshot.id);
  }

  Stream<T> documentStream<T>({
    required String path,
    required T Function(Map<String, dynamic> data, String documentID) builder,
  }) {
    final reference = firestore.doc(path);
    final snapshots = reference.snapshots();
    return snapshots.map((snapshot) =>
        builder(snapshot.data() as Map<String, dynamic>, snapshot.id));
  }

  Future<List<T>> getCollection<T>({
    required String path,
    required T Function(Map<String, dynamic> data, String documentId) builder,
    Query Function(Query query)? queryBuilder,
    int Function(T lhs, T rhs)? sort,
  }) async {
    Query query = firestore.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final snapshots = await query.get();
    final result = snapshots.docs
        .map((snapshot) =>
            builder(snapshot.data() as Map<String, dynamic>, snapshot.id))
        .where((value) => value != null)
        .toList();
    if (sort != null) {
      result.sort(sort);
    }
    return result;
  }

  void monitorBinHeightAndNotify() {
    collectionStream<BinModel>(
      path: 'bin info',
      builder: (data, documentId) {
        debugPrint('Received data from Firestore: $data');
        return BinModel.fromMap(data, documentId);
      },
    ).listen(
      (binList) {
        for (var bin in binList) {
          debugPrint("-------- the height is : ${bin.height}  ");
          if (bin.height > 60) {
            debugPrint(
                "Showing notification for bin at location: ${bin.location}");

            NotificationService().showNotification(
              title: 'Bin Height Alert',
              body: 'The bin at ${bin.location} is now ${bin.height}cm high.',
              payload: 'Bin ID: ${bin.id}',
            );
          }
        }
      },
      onError: (error) {
        debugPrint('Error in monitoring bins: $error');
      },
    );
  }
}
