import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class FetchProfile extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final String? name;
  final String? phone;
  final String? imageUrl;
  const UpdateProfileEvent({this.name, this.phone, this.imageUrl});
  @override
  List<Object?> get props => [name, phone, imageUrl];
}

class FetchAddresses extends ProfileEvent {}

class LogoutEvent extends ProfileEvent {}
