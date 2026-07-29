import 'package:equatable/equatable.dart';
import 'pitch_update_model.dart';

class PitchModel extends Equatable {
  final String id;
  final String entrepreneurId;
  final String entrepreneurName;
  final String entrepreneurLocation;
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final double fundingGoal;
  final double amountRaised;
  final int investorCount;
  final String fundingType; // Grant, Loan, Equity Share
  final double returnPercentage; // For Loan/Equity
  final String incentiveDetails;
  final String status; // activ, funded, completed
  final DateTime createdAt;
  final List<PitchUpdateModel> updates;

  const PitchModel({
    required this.id,
    required this.entrepreneurId,
    required this.entrepreneurName,
    required this.entrepreneurLocation,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.fundingGoal,
    this.amountRaised = 0.0,
    this.investorCount = 0,
    required this.fundingType,
    this.returnPercentage = 0.0,
    required this.incentiveDetails,
    this.status = 'active',
    required this.createdAt,
    this.updates = const [],
  });

  double get progressPercentage {
    if (fundingGoal <= 0) return 0.0;
    final ratio = amountRaised / fundingGoal;
    return ratio > 1.0 ? 1.0 : ratio;
  }

  factory PitchModel.fromJson(Map<String, dynamic> json) {
    return PitchModel(
      id: json['id'] ?? '',
      entrepreneurId: json['entrepreneurId'] ?? '',
      entrepreneurName: json['entrepreneurName'] ?? '',
      entrepreneurLocation: json['entrepreneurLocation'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'General',
      imageUrl: json['imageUrl'] ?? '',
      fundingGoal: (json['fundingGoal'] ?? 0.0).toDouble(),
      amountRaised: (json['amountRaised'] ?? 0.0).toDouble(),
      investorCount: json['investorCount'] ?? 0,
      fundingType: json['fundingType'] ?? 'Grant',
      returnPercentage: (json['returnPercentage'] ?? 0.0).toDouble(),
      incentiveDetails: json['incentiveDetails'] ?? '',
      status: json['status'] ?? 'active',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updates: (json['updates'] as List<dynamic>?)
              ?.map((e) => PitchUpdateModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entrepreneurId': entrepreneurId,
      'entrepreneurName': entrepreneurName,
      'entrepreneurLocation': entrepreneurLocation,
      'title': title,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'fundingGoal': fundingGoal,
      'amountRaised': amountRaised,
      'investorCount': investorCount,
      'fundingType': fundingType,
      'returnPercentage': returnPercentage,
      'incentiveDetails': incentiveDetails,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updates': updates.map((u) => u.toJson()).toList(),
    };
  }

  PitchModel copyWith({
    double? amountRaised,
    int? investorCount,
    String? status,
    List<PitchUpdateModel>? updates,
  }) {
    return PitchModel(
      id: id,
      entrepreneurId: entrepreneurId,
      entrepreneurName: entrepreneurName,
      entrepreneurLocation: entrepreneurLocation,
      title: title,
      description: description,
      category: category,
      imageUrl: imageUrl,
      fundingGoal: fundingGoal,
      amountRaised: amountRaised ?? this.amountRaised,
      investorCount: investorCount ?? this.investorCount,
      fundingType: fundingType,
      returnPercentage: returnPercentage,
      incentiveDetails: incentiveDetails,
      status: status ?? this.status,
      createdAt: createdAt,
      updates: updates ?? this.updates,
    );
  }

  @override
  List<Object?> get props => [
        id,
        entrepreneurId,
        entrepreneurName,
        entrepreneurLocation,
        title,
        description,
        category,
        imageUrl,
        fundingGoal,
        amountRaised,
        investorCount,
        fundingType,
        returnPercentage,
        incentiveDetails,
        status,
        createdAt,
        updates,
      ];
}
