import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:openfoundry/core/constants/enums.dart';
import 'package:openfoundry/data/models/contribution.dart';
import 'package:openfoundry/data/models/pitch.dart';


class ContributionRepository {
  ContributionRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;


  final FirebaseFirestore _db;


  static const _collection = 'contributions';


  Future<Contribution> create({
    required Pitch pitch,
    required String backerId,
    required String backerName,
    required double amount,
    required PaymentMethod paymentMethod,
  }) async {
    final isEquity = pitch.fundingType == FundingType.equity;
    final shares = isEquity && pitch.pricePerShare != null && pitch.pricePerShare! > 0
        ? (amount / pitch.pricePerShare!).round()
        : null;


    final contribution = Contribution(
      id: '',
      pitchId: pitch.id,
      pitchTitle: pitch.title,
      entrepreneurId: pitch.entrepreneurId,
      entrepreneurName: pitch.entrepreneurName,
      backerId: backerId,
      backerName: backerName,
      amount: amount,
      fundingType: pitch.fundingType,
      shares: shares,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
    );


    final docRef = await _db.collection(_collection).add(contribution.toMap());


    await _updatePitchRaised(pitch: pitch, amountAdded: amount);


    return Contribution(
      id: docRef.id,
      pitchId: contribution.pitchId,
      pitchTitle: contribution.pitchTitle,
      entrepreneurId: contribution.entrepreneurId,
      entrepreneurName: contribution.entrepreneurName,
      backerId: contribution.backerId,
      backerName: contribution.backerName,
      amount: contribution.amount,
      fundingType: contribution.fundingType,
      shares: contribution.shares,
      paymentMethod: contribution.paymentMethod,
      createdAt: contribution.createdAt,
    );
  }


  Future<void> _updatePitchRaised({
    required Pitch pitch,
    required double amountAdded,
  }) async {
    final pitchRef = _db.collection('pitches').doc(pitch.id);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(pitchRef);
      if (!snap.exists) return;
      final data = snap.data()!;
      final current = ((data['raised'] ?? 0) as num).toDouble();
      final newRaised = current + amountAdded;
      final newStatus =
          newRaised >= pitch.fundingGoal ? PitchStatus.closed : PitchStatus.open;
      tx.set(pitchRef, {
        'raised': newRaised,
        'status': newStatus.name,
      }, SetOptions(merge: true));
    });
  }


  Stream<List<Contribution>> watchByBacker(String backerId) {
    return _db
        .collection(_collection)
        .where('backerId', isEqualTo: backerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Contribution.fromMap(d.id, d.data())).toList());
  }


  Stream<List<Contribution>> watchByEntrepreneur(String entrepreneurId) {
    return _db
        .collection(_collection)
        .where('entrepreneurId', isEqualTo: entrepreneurId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Contribution.fromMap(d.id, d.data())).toList());
  }


  Stream<List<Contribution>> watchForPitch(String pitchId) {
    return _db
        .collection(_collection)
        .where('pitchId', isEqualTo: pitchId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Contribution.fromMap(d.id, d.data())).toList());
  }
}
