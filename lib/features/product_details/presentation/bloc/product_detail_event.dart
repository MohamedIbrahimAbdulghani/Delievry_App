import 'package:equatable/equatable.dart';

abstract class ProductDetailEvent extends Equatable {
  const ProductDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchProductDetails extends ProductDetailEvent {
  final int id;
  const FetchProductDetails(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateQuantity extends ProductDetailEvent {
  final int quantity;
  const UpdateQuantity(this.quantity);

  @override
  List<Object?> get props => [quantity];
}

class ToggleAddon extends ProductDetailEvent {
  final String addonId;
  const ToggleAddon(this.addonId);

  @override
  List<Object?> get props => [addonId];
}

class SelectVariation extends ProductDetailEvent {
  final String variationId;
  const SelectVariation(this.variationId);

  @override
  List<Object?> get props => [variationId];
}
