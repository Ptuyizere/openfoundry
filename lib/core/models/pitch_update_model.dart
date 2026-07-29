import 'package:equatable/equatable.dart';

class PitchUpdateModel extends Equatable {
  final String id;
  final String pitchId;
  final String title;
  final String description;
  final double amountSpent;
  final DateTime date;

  const PitchUpdateModel({
    required this.id,
    required this.pitchId,
    required this.title,
    required this.description,
    required this.amountSpent,
    required this.date,
  });

  factory PitchUpdateModel.fromJson(Map<String, dynamic> json) {
    return PitchUpdateModel(
      id: json['id'] ?? '',
      pitchId: json['pitchId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      amountSpent: (json['amountSpent'] ?? 0.0).toDouble(),
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pitchId': pitchId,
      'title': title,
      'description': description,
      'amountSpent': amountSpent,
      'date': date.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, pitchId, title, description, amountSpent, date];
}
