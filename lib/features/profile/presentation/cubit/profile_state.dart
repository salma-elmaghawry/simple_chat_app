part of 'profile_cubit.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileUpdateLoading extends ProfileState {}

final class ProfileUpdateSuccess extends ProfileState {}

final class ProfileUpdateError extends ProfileState {
  final String message;
  ProfileUpdateError({required this.message});
}

final class ProfileImagePicked extends ProfileState {
  final File image;
  ProfileImagePicked({required this.image});
}
