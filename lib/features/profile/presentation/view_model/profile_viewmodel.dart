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
    state = state.copyWith(isLoading: true);

    final result = await _getProfileUseCase(NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (profile) => state = state.copyWith(
        isLoading: false,
        profile: profile,
      ),
    );
  }

  Future<void> updateProfile({
    String? name,
    String? phoneNumber,
    String? studentId,
    String? batch,
    String? collegeId,
    File? imageFile,
  }) async {
    state = state.copyWith(isLoading: true);

    final Map<String, dynamic> body = {};
    if (name != null) body['name'] = name;
    if (phoneNumber != null) body['phoneNumber'] = phoneNumber;
    if (studentId != null) body['studentId'] = studentId;
    if (batch != null) body['batch'] = batch;
    if (collegeId != null) body['collegeId'] = collegeId;

    final result = await _updateProfileUseCase(
      UpdateProfileParams(body: body, imageFile: imageFile),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (profile) => state = state.copyWith(
        isLoading: false,
        profile: profile,
        successMessage: 'Profile updated successfully',
      ),
    );
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}
