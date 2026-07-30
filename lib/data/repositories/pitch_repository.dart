import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:openfoundry/core/constants/enums.dart';
import 'package:openfoundry/data/models/app_user.dart';
import 'package:openfoundry/data/models/pitch.dart';


class PitchRepository {
  PitchRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;


  final FirebaseFirestore _db;


  static const _collection = 'pitches';


  Future<String> create(Pitch pitch) async {
    final ref = await _db.collection(_collection).add(pitch.toMap());
    return ref.id;
  }


  Future<void> update(Pitch pitch) async {
    await _db.collection(_collection).doc(pitch.id).set(
          pitch.toMap(),
          SetOptions(merge: true),
        );
  }


  Future<void> delete(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }


  Future<Pitch?> read(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return Pitch.fromMap(doc.id, doc.data()!);
  }


  Stream<Pitch?> watchSingle(String id) {
    return _db.collection(_collection).doc(id).snapshots().map(
      (doc) => doc.exists ? Pitch.fromMap(doc.id, doc.data()!) : null,
    );
  }


  Stream<List<Pitch>> watchByEntrepreneur(String entrepreneurId) {
    return _db
        .collection(_collection)
        .where('entrepreneurId', isEqualTo: entrepreneurId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Pitch.fromMap(d.id, d.data())).toList());
  }


  Stream<List<Pitch>> watchAll() {
    return _db
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Pitch.fromMap(d.id, d.data())).toList());
  }


  Future<List<Pitch>> fetchFiltered({
    String? search,
    String? industry,
    FundingType? fundingType,
  }) async {
    Query<Map<String, dynamic>> query = _db.collection(_collection).orderBy('createdAt', descending: true);
    if (industry != null && industry.isNotEmpty) {
      query = query.where('industry', isEqualTo: industry);
    }
    if (fundingType != null) {
      query = query.where('fundingType', isEqualTo: fundingType.name);
    }
    final snap = await query.get();
    var pitches = snap.docs.map((d) => Pitch.fromMap(d.id, d.data())).toList();
    if (search != null && search.trim().isNotEmpty) {
      final term = search.trim().toLowerCase();
      pitches = pitches
          .where((p) =>
              p.title.toLowerCase().contains(term) ||
              p.description.toLowerCase().contains(term) ||
              p.entrepreneurName.toLowerCase().contains(term) ||
              p.industry.toLowerCase().contains(term))
          .toList();
    }
    return pitches;
  }


  Future<void> updateRaisedAndStatus({
    required String pitchId,
    required double newRaised,
    required double goal,
  }) async {
    final status = newRaised >= goal ? PitchStatus.closed : PitchStatus.open;
    await _db.collection(_collection).doc(pitchId).set(
      {
        'raised': newRaised,
        'status': status.name,
      },
      SetOptions(merge: true),
    );
  }


  Future<double> fetchRaisedForPitch(String pitchId) async {
    final snap = await FirebaseFirestore.instance
        .collection('contributions')
        .where('pitchId', isEqualTo: pitchId)
        .get();
    var total = 0.0;
    for (final doc in snap.docs) {
      total += ((doc.data()['amount'] ?? 0) as num).toDouble();
    }
    return total;
  }
}


Pitch buildPitchFromUser(AppUser user, String id) {
  return Pitch(
    id: id,
    entrepreneurId: user.id,
    entrepreneurName: user.name,
    entrepreneurPhone: user.phone,
    entrepreneurEmail: user.email,
    title: '',
    description: '',
    industry: '',
    fundingType: FundingType.grant,
    fundingGoal: 0,
    status: PitchStatus.open,
    createdAt: DateTime.now(),
  );
}

