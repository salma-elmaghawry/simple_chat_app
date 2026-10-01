import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_chat_app/core/helpers/cache_helper.dart';
import 'package:simple_chat_app/features/auth/data/models/user_model.dart';
// Supabase has its own User class, we use the Firebase one.
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  late final FirebaseAuth auth = FirebaseAuth.instance;
  late final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late final SupabaseClient supabase = Supabase.instance.client;
  final ImagePicker imagePicker = ImagePicker();

  static const String profileImagesBucket = 'easy_chat_profile_images';

  File? selectedProfileImage;

  /// 1. Pick image only
  Future<void> pickProfileImage() async {
    try {
      final XFile? pickedImage = await imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedImage == null) {
        return;
      }

      selectedProfileImage = File(pickedImage.path);

      emit(ProfileImagePicked(image: selectedProfileImage!));
    } catch (e) {
      log(e.toString());
      emit(ProfileUpdateError(message: 'Failed to pick image.'));
    }
  }

  /// 2. Upload image to Supabase and return image URL
  Future<String> uploadProfileImageAndGetUrl({required File imageFile}) async {
    final User? currentUser = auth.currentUser;

    if (currentUser == null) {
      throw Exception('User is not logged in.');
    }

    final String imagePath =
        'users/${currentUser.uid}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

    await supabase.storage
        .from(profileImagesBucket)
        .upload(
          imagePath,
          imageFile,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: false,
            contentType: 'image/jpeg',
          ),
        );

    final String imageUrl = supabase.storage
        .from(profileImagesBucket)
        .getPublicUrl(imagePath);

    return imageUrl;
  }

  /// 3. Update name and image in Firebase, then refresh the cache
  Future<void> updateProfile({required String name, File? imageFile}) async {
    try {
      emit(ProfileUpdateLoading());

      final User? currentUser = auth.currentUser;

      if (currentUser == null) {
        emit(ProfileUpdateError(message: 'User is not logged in.'));
        return;
      }

      final DocumentReference<Map<String, dynamic>> userRef = firestore
          .collection('users')
          .doc(currentUser.uid);

      final Map<String, dynamic> updatedData = {};

      if (name.trim().isNotEmpty) {
        updatedData['name'] = name.trim();
      }

      if (imageFile != null) {
        final String imageUrl = await uploadProfileImageAndGetUrl(
          imageFile: imageFile,
        );

        updatedData['image'] = imageUrl;
      }

      if (updatedData.isEmpty) {
        emit(ProfileUpdateError(message: 'No data to update.'));
        return;
      }

      await userRef.update(updatedData);

      if (updatedData.containsKey('name')) {
        await currentUser.updateDisplayName(updatedData['name']);
      }

      if (updatedData.containsKey('image')) {
        await currentUser.updatePhotoURL(updatedData['image']);
      }

      final DocumentSnapshot<Map<String, dynamic>> userDoc = await userRef
          .get();

      final Map<String, dynamic>? userData = userDoc.data();

      if (userData == null) {
        emit(ProfileUpdateError(message: 'User data not found.'));
        return;
      }

      final UserModel updatedUserModel = UserModel.fromJson(userData);

      await CacheHelper.saveUserModelData(
        userKey: 'user',
        userModel: updatedUserModel,
      );

      selectedProfileImage = null;

      emit(ProfileUpdateSuccess());
    } on StorageException catch (e) {
      emit(ProfileUpdateError(message: e.message));
    } on FirebaseException catch (e) {
      emit(ProfileUpdateError(message: e.message ?? 'Firebase error.'));
    } catch (e) {
      log(e.toString());
      emit(ProfileUpdateError(message: 'Failed to update profile.'));
    }
  }
}
