import '../../domain/entities/profile_entity.dart';

class ProfileState {
  final bool isLoading;
  final Profile? profile;
  final String? errorMessage;
  final String? successMessage;

  const ProfileState({
    this.isLoading = false,
    this.profile,
    this.errorMessage,
    this.successMessage,
  });

  ProfileState copyWith({
    bool? isLoading,
    Profile? profile,
    String? errorMessage,
    String? successMessage,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
