import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openfoundry/core/constants/enums.dart';
import 'package:openfoundry/data/models/contribution.dart';
import 'package:openfoundry/data/models/pitch.dart';
import 'package:openfoundry/data/repositories/contribution_repository.dart';

enum ContributionStatus { initial, processing, success, failure }

class ContributionState extends Equatable {
  const ContributionState._({
    required this.status,
    this.message,
  });

  const ContributionState.initial()
      : this._(status: ContributionStatus.initial);
  const ContributionState.processing()
      : this._(status: ContributionStatus.processing);
  const ContributionState.success()
      : this._(status: ContributionStatus.success);
  const ContributionState.failure(String message)
      : this._(status: ContributionStatus.failure, message: message);

  final ContributionStatus status;
  final String? message;

  bool get isProcessing => status == ContributionStatus.processing;

  @override
  List<Object?> get props => [status, message];
}

class ContributionCubit extends Cubit<ContributionState> {
  ContributionCubit({required this.contributionRepository})
      : super(const ContributionState.initial());

  final ContributionRepository contributionRepository;

  Stream<List<Contribution>> myFunding(String backerId) {
    return contributionRepository.watchByBacker(backerId);
  }

  Stream<List<Contribution>> fundersOfEntrepreneur(String entrepreneurId) {
    return contributionRepository.watchByEntrepreneur(entrepreneurId);
  }

  Future<void> fundPitch({
    required Pitch pitch,
    required String backerId,
    required String backerName,
    required double amount,
    required PaymentMethod paymentMethod,
  }) async {
    emit(const ContributionState.processing());
    try {
      await Future.delayed(const Duration(seconds: 2));
      await contributionRepository.create(
        pitch: pitch,
        backerId: backerId,
        backerName: backerName,
        amount: amount,
        paymentMethod: paymentMethod,
      );
      emit(const ContributionState.success());
    } catch (e) {
      emit(ContributionState.failure(e.toString()));
    }
  }
}



