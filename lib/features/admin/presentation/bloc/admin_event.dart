import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class FetchAdminData extends AdminEvent {}

class UpdateOrderStatusEvent extends AdminEvent {
  final int orderId;
  final String status;

  const UpdateOrderStatusEvent({required this.orderId, required this.status});

  @override
  List<Object?> get props => [orderId, status];
}

class CreateRestaurantEvent extends AdminEvent {
  final Map<String, dynamic> data;

  const CreateRestaurantEvent(this.data);

  @override
  List<Object?> get props => [data];
}

class UpdateRestaurantEvent extends AdminEvent {
  final int id;
  final Map<String, dynamic> data;

  const UpdateRestaurantEvent({required this.id, required this.data});

  @override
  List<Object?> get props => [id, data];
}

class DeleteRestaurantEvent extends AdminEvent {
  final int id;

  const DeleteRestaurantEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateMealEvent extends AdminEvent {
  final Map<String, dynamic> data;

  const CreateMealEvent(this.data);

  @override
  List<Object?> get props => [data];
}

class UpdateMealEvent extends AdminEvent {
  final int id;
  final Map<String, dynamic> data;

  const UpdateMealEvent({required this.id, required this.data});

  @override
  List<Object?> get props => [id, data];
}

class DeleteMealEvent extends AdminEvent {
  final int id;

  const DeleteMealEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateUserEvent extends AdminEvent {
  final int id;
  final Map<String, dynamic> data;

  const UpdateUserEvent({required this.id, required this.data});

  @override
  List<Object?> get props => [id, data];
}

class DeleteUserEvent extends AdminEvent {
  final int id;

  const DeleteUserEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class SaveSettingsEvent extends AdminEvent {
  final Map<String, dynamic> settings;

  const SaveSettingsEvent(this.settings);

  @override
  List<Object?> get props => [settings];
}

class SaveDriversEvent extends AdminEvent {
  final List<Map<String, dynamic>> drivers;

  const SaveDriversEvent(this.drivers);

  @override
  List<Object?> get props => [drivers];
}

class CreateCategoryEvent extends AdminEvent {
  final Map<String, dynamic> data;

  const CreateCategoryEvent(this.data);

  @override
  List<Object?> get props => [data];
}

class UpdateCategoryEvent extends AdminEvent {
  final String id;
  final Map<String, dynamic> data;

  const UpdateCategoryEvent({required this.id, required this.data});

  @override
  List<Object?> get props => [id, data];
}

class DeleteCategoryEvent extends AdminEvent {
  final String id;

  const DeleteCategoryEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateUserEvent extends AdminEvent {
  final Map<String, dynamic> data;

  const CreateUserEvent(this.data);

  @override
  List<Object?> get props => [data];
}

class AssignDriverEvent extends AdminEvent {
  final int orderId;
  final int driverId;

  const AssignDriverEvent({required this.orderId, required this.driverId});

  @override
  List<Object?> get props => [orderId, driverId];
}
