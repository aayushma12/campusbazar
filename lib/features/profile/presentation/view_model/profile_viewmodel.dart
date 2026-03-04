import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/usecases/usecase.dart';
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
    if (name != null && name.trim().isNotEmpty) body['name'] = name.trim();
    if (phoneNumber != null && phoneNumber.trim().isNotEmpty) body['phoneNumber'] = phoneNumber.trim();
    if (studentId != null && studentId.trim().isNotEmpty) body['studentId'] = studentId.trim();
    if (batch != null && batch.trim().isNotEmpty) body['batch'] = batch.trim();
    if (collegeId != null && collegeId.trim().isNotEmpty) body['collegeId'] = collegeId.trim();
    if (university != null && university.trim().isNotEmpty) body['university'] = university.trim();
    if (campus != null && campus.trim().isNotEmpty) body['campus'] = campus.trim();
    if (bio != null && bio.trim().isNotEmpty) body['bio'] = bio.trim();

    if (body.isEmpty && imageFile == null) {
      state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'No changes to update',
      );
      return;
    }

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
  }

  void clearMessages() {
    state = state.copyWith(
      clearError: true,
      clearSuccess: true,
      status: state.profile == null ? ProfileStatus.initial : ProfileStatus.loaded,
    );
  }
}
