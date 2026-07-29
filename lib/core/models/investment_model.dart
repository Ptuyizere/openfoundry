import 'package:equatable/equatable.dart';

class InvestmentModel extends Equatable {
  final String id;
  final String pitchId;
  final String pitchTitle;
  final String entrepreneurName;
  final String backerId;
  final String backerName;
  final double amount;
  final String paymentMethod; // M-Pesa, Momo, Card
  final String fundingType; // Grant, Loan, Equity Share
  final double expectedReturn;
  final String status; // Active, Completed, Repaid
  final DateTime timestamp;

  const InvestmentModel({
    required this.id,
    required this.pitchId,
    required this.pitchTitle,
    required this.entrepreneurName,
    required this.backerId,
    required this.backerName,
    required this.amount,
    required this.paymentMethod,
    required this.fundingType,
    this.expectedReturn = 0.0,
    this.status = 'Active',
    required this.timestamp,
  });

  factory InvestmentModel.fromJson(Map<String, dynamic> json) {
    return InvestmentModel(
      id: json['id'] ?? '',
      pitchId: json['pitchId'] ?? '',
      pitchTitle: json['pitchTitle'] ?? '',
      entrepreneurName: json['entrepreneurName'] ?? '',
      backerId: json['backerId'] ?? '',
      backerName: json['backerName'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'M-Pesa',
      fundingType: json['fundingType'] ?? 'Grant',
      expectedReturn: (json['expectedReturn'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'Active',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pitchId': pitchId,
      'pitchTitle': pitchTitle,
      'entrepreneurName': entrepreneurName,
      'backerId': backerId,
      'backerName': backerName,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'fundingType': fundingType,
      'expectedReturn': expectedReturn,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        pitchId,
        pitchTitle,
        entrepreneurName,
        backerId,
        backerName,
        amount,
        paymentMethod,
        fundingType,
        expectedReturn,
        status,
        timestamp,
      ];
}
