import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/entities/address_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfileEntity user;
  const ProfileLoaded(this.user);
  @override
  List<Object?> get props => [user];
}

class AddressesLoaded extends ProfileState {
  final List<AddressEntity> addresses;
  const AddressesLoaded(this.addresses);
  @override
  List<Object?> get props => [addresses];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

class LogoutSuccess extends ProfileState {}
