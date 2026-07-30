import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:openfoundry/core/constants/enums.dart';
import 'package:openfoundry/data/models/app_user.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const _collection = 'users';

  Future<void> create(AppUser user) async {
    await _db.collection(_collection).doc(user.id).set(user.toMap());
  }

  Future<AppUser?> read(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.id, doc.data()!);
  }

  Stream<AppUser?> watch(String id) {
    return _db.collection(_collection).doc(id).snapshots().map(
      (doc) => doc.exists ? AppUser.fromMap(doc.id, doc.data()!) : null,
    );
  }

  Future<void> update(AppUser user) async {
    await _db.collection(_collection).doc(user.id).set(
          user.toMap(),
          SetOptions(merge: true),
        );
  }

  Future<AppUser> upsertFromAuth({
    required String uid,
    required String email,
    required String name,
    required String phone,
    required UserRole role,
  }) async {
    final existing = await read(uid);
    if (existing != null) return existing;
    final user = AppUser(
      id: uid,
      name: name,
      email: email,
      phone: phone,
      role: role,
      createdAt: DateTime.now(),
    );
    await create(user);
    return user;
  }
}


