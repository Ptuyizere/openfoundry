import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:openfoundry/core/constants/enums.dart';


class Pitch {
  Pitch({
    required this.id,
    required this.entrepreneurId,
    required this.entrepreneurName,
    required this.entrepreneurPhone,
    required this.entrepreneurEmail,
    required this.title,
    required this.description,
    required this.industry,
    required this.fundingType,
    this.pricePerShare,
    required this.fundingGoal,
    this.coverImageUrl,
    this.videoUrl,
    required this.status,
    required this.createdAt,
    this.raised = 0,
  });


  final String id;
  final String entrepreneurId;
  final String entrepreneurName;
  final String entrepreneurPhone;
  final String entrepreneurEmail;
  final String title;
  final String description;
  final String industry;
  final FundingType fundingType;
  final double? pricePerShare;
  final double fundingGoal;
  final String? coverImageUrl;
  final String? videoUrl;
  final PitchStatus status;
  final DateTime createdAt;
  final double raised;


  factory Pitch.fromMap(String id, Map<String, dynamic> map) {
    return Pitch(
      id: id,
      entrepreneurId: (map['entrepreneurId'] ?? '') as String,
      entrepreneurName: (map['entrepreneurName'] ?? '') as String,
      entrepreneurPhone: (map['entrepreneurPhone'] ?? '') as String,
      entrepreneurEmail: (map['entrepreneurEmail'] ?? '') as String,
      title: (map['title'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      industry: (map['industry'] ?? '') as String,
      fundingType: FundingType.values.firstWhere(
        (f) => f.name == map['fundingType'],
        orElse: () => FundingType.grant,
      ),
      pricePerShare: (map['pricePerShare'] as num?)?.toDouble(),
      fundingGoal: ((map['fundingGoal'] ?? 0) as num).toDouble(),
      coverImageUrl: map['coverImageUrl'] as String?,
      videoUrl: map['videoUrl'] as String?,
      status: PitchStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => PitchStatus.open,
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      raised: ((map['raised'] ?? 0) as num).toDouble(),
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'entrepreneurId': entrepreneurId,
      'entrepreneurName': entrepreneurName,
      'entrepreneurPhone': entrepreneurPhone,
      'entrepreneurEmail': entrepreneurEmail,
      'title': title,
      'description': description,
      'industry': industry,
      'fundingType': fundingType.name,
      'pricePerShare': pricePerShare,
      'fundingGoal': fundingGoal,
      'coverImageUrl': coverImageUrl,
      'videoUrl': videoUrl,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'raised': raised,
    };
  }


  Pitch copyWith({
    String? title,
    String? description,
    String? industry,
    FundingType? fundingType,
    double? pricePerShare,
    double? fundingGoal,
    String? coverImageUrl,
    String? videoUrl,
    PitchStatus? status,
    double? raised,
  }) {
    return Pitch(
      id: id,
      entrepreneurId: entrepreneurId,
      entrepreneurName: entrepreneurName,
      entrepreneurPhone: entrepreneurPhone,
      entrepreneurEmail: entrepreneurEmail,
      title: title ?? this.title,
      description: description ?? this.description,
      industry: industry ?? this.industry,
      fundingType: fundingType ?? this.fundingType,
      pricePerShare: pricePerShare ?? this.pricePerShare,
      fundingGoal: fundingGoal ?? this.fundingGoal,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      status: status ?? this.status,
      createdAt: createdAt,
      raised: raised ?? this.raised,
    );
  }


  double get progress => fundingGoal <= 0 ? 0 : (raised / fundingGoal).clamp(0, 1);


  bool get isFunded => raised >= fundingGoal;
}

