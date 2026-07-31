import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:openfoundry/core/constants/enums.dart';


class Contribution {
  Contribution({
    required this.id,
    required this.pitchId,
    required this.pitchTitle,
    required this.entrepreneurId,
    required this.entrepreneurName,
    required this.backerId,
    required this.backerName,
    required this.amount,
    required this.fundingType,
    this.shares,
    required this.paymentMethod,
    required this.createdAt,
  });


  final String id;
  final String pitchId;
  final String pitchTitle;
  final String entrepreneurId;
  final String entrepreneurName;
  final String backerId;
  final String backerName;
  final double amount;
  final FundingType fundingType;
  final int? shares;
  final PaymentMethod paymentMethod;
  final DateTime createdAt;


  factory Contribution.fromMap(String id, Map<String, dynamic> map) {
    return Contribution(
      id: id,
      pitchId: (map['pitchId'] ?? '') as String,
      pitchTitle: (map['pitchTitle'] ?? '') as String,
      entrepreneurId: (map['entrepreneurId'] ?? '') as String,
      entrepreneurName: (map['entrepreneurName'] ?? '') as String,
      backerId: (map['backerId'] ?? '') as String,
      backerName: (map['backerName'] ?? '') as String,
      amount: ((map['amount'] ?? 0) as num).toDouble(),
      fundingType: FundingType.values.firstWhere(
        (f) => f.name == map['fundingType'],
        orElse: () => FundingType.grant,
      ),
      shares: (map['shares'] as num?)?.toInt(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (p) => p.name == map['paymentMethod'],
        orElse: () => PaymentMethod.mpesa,
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'pitchId': pitchId,
      'pitchTitle': pitchTitle,
      'entrepreneurId': entrepreneurId,
      'entrepreneurName': entrepreneurName,
      'backerId': backerId,
      'backerName': backerName,
      'amount': amount,
      'fundingType': fundingType.name,
      'shares': shares,
      'paymentMethod': paymentMethod.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
