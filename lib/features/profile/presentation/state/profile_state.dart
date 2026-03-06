import '../../domain/entities/profile_entity.dart';

enum ProfileStatus {
  initial,
  loading,
  loaded,
  updating,
  success,
  error,
}

class ProfileState {
  final ProfileStatus status;
  final Profile? profile;
  final String? errorMessage;
  final String? successMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
    this.successMessage,
  });

  bool get isBusy => status == ProfileStatus.loading || status == ProfileStatus.updating;

  ProfileState copyWith({
    ProfileStatus? status,
    Profile? profile,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: clearError ? null : errorMessage,
      successMessage: clearSuccess ? null : successMessage,
    );
  }
}
