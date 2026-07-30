import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';


class StorageRepository {
  StorageRepository({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;


  final FirebaseStorage _storage;


  Future<String> uploadProfileImage({
    required String userId,
    required XFile file,
  }) async {
    final bytes = await file.readAsBytes();
    final ref = _storage.ref().child('users/$userId/profile.jpg');
    final metadata = SettableMetadata(contentType: 'image/jpeg');
    await ref.putData(bytes, metadata);
    return ref.getDownloadURL();
  }


  Future<String> uploadPitchCover({
    required String pitchId,
    required XFile file,
  }) async {
    final bytes = await file.readAsBytes();
    final ref = _storage.ref().child('pitches/$pitchId/cover.jpg');
    final metadata = SettableMetadata(contentType: 'image/jpeg');
    await ref.putData(bytes, metadata);
    return ref.getDownloadURL();
  }


  Future<String> uploadPitchVideo({
    required String pitchId,
    required XFile file,
  }) async {
    final bytes = await file.readAsBytes();
    final ext = file.path.split('.').last.toLowerCase();
    final ref = _storage.ref().child('pitches/$pitchId/video.$ext');
    final metadata = SettableMetadata(contentType: 'video/$ext');
    await ref.putData(bytes, metadata);
    return ref.getDownloadURL();
  }


  Future<void> deletePitchMedia(String pitchId) async {
    final folder = _storage.ref().child('pitches/$pitchId');
    final items = await folder.listAll();
    for (final item in items.items) {
      await item.delete().catchError((_) {});
    }
  }
}

