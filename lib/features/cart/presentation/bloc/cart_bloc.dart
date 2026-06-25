import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/cart_usecases.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartUseCase getCartUseCase;
  final AddToCartUseCase addToCartUseCase;
  final UpdateCartItemUseCase updateCartItemUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final ClearCartUseCase clearCartUseCase;

  CartBloc({
    required this.getCartUseCase,
    required this.addToCartUseCase,
    required this.updateCartItemUseCase,
    required this.removeFromCartUseCase,
    required this.clearCartUseCase,
  }) : super(CartInitial()) {
    on<FetchCart>(_onFetchCart);
    on<AddItemToCart>(_onAddItemToCart);
    on<UpdateItemQuantity>(_onUpdateItemQuantity);
    on<RemoveItemFromCart>(_onRemoveItemFromCart);
    on<ClearCart>(_onClearCart);
  }

  Future<void> _onFetchCart(FetchCart event, Emitter<CartState> emit) async {
    emit(CartLoading());
    final result = await getCartUseCase();
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  Future<void> _onAddItemToCart(AddItemToCart event, Emitter<CartState> emit) async {
    emit(CartLoading());
    final result = await addToCartUseCase(event.productId, event.quantity, options: event.options);
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  Future<void> _onUpdateItemQuantity(UpdateItemQuantity event, Emitter<CartState> emit) async {
    if (event.quantity <= 0) {
      add(RemoveItemFromCart(event.lineId));
      return;
    }
    
    if (state is CartLoaded) {
      final currentCart = (state as CartLoaded).cart;
      final updatedItems = currentCart.items.map((item) {
        if (item.id == event.lineId) {
          return item.copyWith(quantity: event.quantity);
        }
        return item;
      }).toList();
      emit(CartLoaded(currentCart.copyWith(items: updatedItems)));
    } else {
      emit(CartLoading());
    }
    
    final result = await updateCartItemUseCase(event.lineId, event.quantity);
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  Future<void> _onRemoveItemFromCart(RemoveItemFromCart event, Emitter<CartState> emit) async {
    if (state is CartLoaded) {
      final currentCart = (state as CartLoaded).cart;
      final updatedItems = currentCart.items.where((item) => item.id != event.lineId).toList();
      emit(CartLoaded(currentCart.copyWith(items: updatedItems)));
    } else {
      emit(CartLoading());
    }
    
    final result = await removeFromCartUseCase(event.lineId);
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    emit(CartLoading());
    final result = await clearCartUseCase();
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart)),
    );
  }
}
