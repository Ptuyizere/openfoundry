import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openfoundry/data/models/app_user.dart';
import 'package:openfoundry/data/repositories/storage_repository.dart';
import 'package:openfoundry/data/repositories/user_repository.dart';


enum ProfileStatus { initial, uploading, saving, saved, imageUploaded, error }


class ProfileState extends Equatable {
  const ProfileState._({
    required this.status,
    this.message,
    this.imageUrl,
  });


  const ProfileState.initial() : this._(status: ProfileStatus.initial);
  const ProfileState.uploading() : this._(status: ProfileStatus.uploading);
  const ProfileState.saving() : this._(status: ProfileStatus.saving);
  const ProfileState.saved() : this._(status: ProfileStatus.saved);
  const ProfileState.imageUploaded(String url)
      : this._(status: ProfileStatus.imageUploaded, imageUrl: url);
  const ProfileState.error(String message)
      : this._(status: ProfileStatus.error, message: message);


  final ProfileStatus status;
  final String? message;
  final String? imageUrl;


  bool get isSaving => status == ProfileStatus.saving || status == ProfileStatus.uploading;


  @override
  List<Object?> get props => [status, message, imageUrl];
}


class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required this.userRepository,
    required this.storageRepository,
  }) : super(const ProfileState.initial());


  final UserRepository userRepository;
  final StorageRepository storageRepository;


  Future<String?> uploadProfileImage({
    required String userId,
    required XFile file,
  }) async {
    emit(const ProfileState.uploading());
    try {
      final url = await storageRepository.uploadProfileImage(
        userId: userId,
        file: file,
      );
      emit(ProfileState.imageUploaded(url));
      return url;
    } catch (e) {
      emit(ProfileState.error(e.toString()));
      return null;
    }
  }


  Future<void> saveProfile({
    required AppUser user,
    required String name,
    required String phone,
    required String bio,
    required String location,
    String? profileImageUrl,
  }) async {
    emit(const ProfileState.saving());
    try {
      final updated = user.copyWith(
        name: name,
        phone: phone,
        bio: bio,
        location: location,
        profileImageUrl: profileImageUrl ?? user.profileImageUrl,
      );
      await userRepository.update(updated);
      emit(const ProfileState.saved());
    } catch (e) {
      emit(ProfileState.error(e.toString()));
    }
  }
}
