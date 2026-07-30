import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openfoundry/core/constants/enums.dart';
import 'package:openfoundry/data/models/app_user.dart';
import 'package:openfoundry/data/models/pitch.dart';
import 'package:openfoundry/data/repositories/pitch_repository.dart';
import 'package:openfoundry/data/repositories/storage_repository.dart';


enum PitchFormStatus { initial, saving, saved, error }


class PitchState extends Equatable {
  const PitchState._({
    required this.status,
    this.message,
    this.savedId,
  });


  const PitchState.initial() : this._(status: PitchFormStatus.initial);
  const PitchState.saving() : this._(status: PitchFormStatus.saving);
  const PitchState.saved(String id)
      : this._(status: PitchFormStatus.saved, savedId: id);
  const PitchState.error(String message)
      : this._(status: PitchFormStatus.error, message: message);


  final PitchFormStatus status;
  final String? message;
  final String? savedId;


  bool get isSaving => status == PitchFormStatus.saving;


  @override
  List<Object?> get props => [status, message, savedId];
}


class PitchCubit extends Cubit<PitchState> {
  PitchCubit({
    required this.pitchRepository,
    required this.storageRepository,
  }) : super(const PitchState.initial());


  final PitchRepository pitchRepository;
  final StorageRepository storageRepository;


  Stream<List<Pitch>> myPitches(String entrepreneurId) {
    return pitchRepository.watchByEntrepreneur(entrepreneurId);
  }


  Future<String?> savePitch({
    required AppUser user,
    required String pitchId,
    required String title,
    required String description,
    required String industry,
    required FundingType fundingType,
    double? pricePerShare,
    required double fundingGoal,
    String? coverImageUrl,
    String? videoUrl,
    double raised = 0,
    PitchStatus status = PitchStatus.open,
    DateTime? createdAt,
    bool isEditing = false,
  }) async {
    emit(const PitchState.saving());
    try {
      final pitch = Pitch(
        id: pitchId,
        entrepreneurId: user.id,
        entrepreneurName: user.name,
        entrepreneurPhone: user.phone,
        entrepreneurEmail: user.email,
        title: title,
        description: description,
        industry: industry,
        fundingType: fundingType,
        pricePerShare: fundingType == FundingType.equity ? pricePerShare : null,
        fundingGoal: fundingGoal,
        coverImageUrl: coverImageUrl,
        videoUrl: videoUrl,
        status: status,
        createdAt: createdAt ?? DateTime.now(),
        raised: raised,
      );
      String newId;
      if (isEditing) {
        await pitchRepository.update(pitch);
        newId = pitch.id;
      } else {
        newId = await pitchRepository.create(pitch);
      }
      emit(PitchState.saved(newId));
      return newId;
    } catch (e) {
      emit(PitchState.error(e.toString()));
      return null;
    }
  }


  Future<void> deletePitch(Pitch pitch) async {
    try {
      await storageRepository.deletePitchMedia(pitch.id);
      await pitchRepository.delete(pitch.id);
    } catch (e) {
      emit(PitchState.error(e.toString()));
    }
  }


  Future<String?> uploadCover({required String pitchId, required XFile file}) async {
    try {
      return await storageRepository.uploadPitchCover(
        pitchId: pitchId,
        file: file,
      );
    } catch (e) {
      emit(PitchState.error(e.toString()));
      return null;
    }
  }


  Future<String?> uploadVideo({required String pitchId, required XFile file}) async {
    try {
      return await storageRepository.uploadPitchVideo(
        pitchId: pitchId,
        file: file,
      );
    } catch (e) {
      emit(PitchState.error(e.toString()));
      return null;
    }
  }
}

