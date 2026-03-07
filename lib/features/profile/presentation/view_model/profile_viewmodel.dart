import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../state/profile_state.dart';

final profileViewModelProvider = NotifierProvider<ProfileViewModel, ProfileState>(
  ProfileViewModel.new,
);

class ProfileViewModel extends Notifier<ProfileState> {
  late final GetProfileUseCase _getProfileUseCase;
  late final UpdateProfileUseCase _updateProfileUseCase;

  @override
  ProfileState build() {
    _getProfileUseCase = sl<GetProfileUseCase>();
    _updateProfileUseCase = sl<UpdateProfileUseCase>();
    return const ProfileState();
  }

  Future<void> getProfile() async {
    state = state.copyWith(
      status: ProfileStatus.loading,
      clearError: true,
      clearSuccess: true,
    );

    final result = await _getProfileUseCase(NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: failure.message,
        clearSuccess: true,
      ),
      (profile) => state = state.copyWith(
        status: ProfileStatus.loaded,
        profile: profile,
        clearError: true,
        clearSuccess: true,
      ),
    );
  }

  Future<void> updateProfile({
    required Profile originalProfile,
    String? name,
    String? phoneNumber,
    String? studentId,
    String? batch,
    String? collegeId,
    String? university,
    String? campus,
    String? bio,
    File? imageFile,
  }) async {
    state = state.copyWith(
      status: ProfileStatus.updating,
      clearError: true,
      clearSuccess: true,
    );

    final Map<String, dynamic> body = {};
    final normalizedName = (name ?? '').trim();
    if (normalizedName.isNotEmpty && normalizedName != originalProfile.name.trim()) {
      body['name'] = normalizedName;
    }

    String normalize(String? value) => (value ?? '').trim();

    final normalizedPhoneNumber = normalize(phoneNumber);
    if (normalizedPhoneNumber != normalize(originalProfile.phoneNumber)) {
      body['phoneNumber'] = normalizedPhoneNumber;
    }

    final normalizedStudentId = normalize(studentId);
    if (normalizedStudentId != normalize(originalProfile.studentId)) {
      body['studentId'] = normalizedStudentId;
    }

    final normalizedBatch = normalize(batch);
    if (normalizedBatch != normalize(originalProfile.batch)) {
      body['batch'] = normalizedBatch;
    }

    final normalizedCollegeId = normalize(collegeId);
    if (normalizedCollegeId != normalize(originalProfile.collegeId)) {
      body['collegeId'] = normalizedCollegeId;
    }

    final normalizedUniversity = normalize(university);
    if (normalizedUniversity != normalize(originalProfile.university)) {
      body['university'] = normalizedUniversity;
    }

    final normalizedCampus = normalize(campus);
    if (normalizedCampus != normalize(originalProfile.campus)) {
      body['campus'] = normalizedCampus;
    }

    final normalizedBio = normalize(bio);
    if (normalizedBio != normalize(originalProfile.bio)) {
      body['bio'] = normalizedBio;
    }

    if (body.isEmpty && imageFile == null) {
      state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'No changes to update',
      );
      return;
    }

    try {
      final result = await _updateProfileUseCase(
        UpdateProfileParams(body: body, imageFile: imageFile),
      );

      result.fold(
        (failure) => state = state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
          clearSuccess: true,
        ),
        (profile) => state = state.copyWith(
          status: ProfileStatus.success,
          profile: profile,
          successMessage: 'Profile updated successfully',
          clearError: true,
        ),
      );
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '').trim();
      state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: message.isEmpty ? 'Failed to update profile' : message,
        clearSuccess: true,
      );
    }
  }

  void clearMessages() {
    state = state.copyWith(
      clearError: true,
      clearSuccess: true,
      status: state.profile == null ? ProfileStatus.initial : ProfileStatus.loaded,
    );
  }
}
