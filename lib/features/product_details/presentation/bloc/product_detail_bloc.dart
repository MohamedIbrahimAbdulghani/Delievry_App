import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_product_details_usecase.dart';
import 'product_detail_event.dart';
import 'product_detail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final GetProductDetailsUseCase getProductDetailsUseCase;

  ProductDetailBloc({
    required this.getProductDetailsUseCase,
  }) : super(ProductDetailInitial()) {
    on<FetchProductDetails>(_onFetchProductDetails);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<ToggleAddon>(_onToggleAddon);
    on<SelectVariation>(_onSelectVariation);
  }

  Future<void> _onFetchProductDetails(
    FetchProductDetails event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(ProductDetailLoading());
    final result = await getProductDetailsUseCase(event.id);
    result.fold(
      (failure) => emit(ProductDetailError(failure.message)),
      (product) => emit(ProductDetailLoaded(
        product: product,
        selectedVariationId: product.variations.isNotEmpty ? product.variations.first.id : null,
      )),
    );
  }

  void _onUpdateQuantity(UpdateQuantity event, Emitter<ProductDetailState> emit) {
    if (state is ProductDetailLoaded) {
      final currentState = state as ProductDetailLoaded;
      if (event.quantity > 0) {
        emit(currentState.copyWith(quantity: event.quantity));
      }
    }
  }

  void _onToggleAddon(ToggleAddon event, Emitter<ProductDetailState> emit) {
    if (state is ProductDetailLoaded) {
      final currentState = state as ProductDetailLoaded;
      final List<String> currentAddons = List.from(currentState.selectedAddonIds);
      if (currentAddons.contains(event.addonId)) {
        currentAddons.remove(event.addonId);
      } else {
        currentAddons.add(event.addonId);
      }
      emit(currentState.copyWith(selectedAddonIds: currentAddons));
    }
  }

  void _onSelectVariation(SelectVariation event, Emitter<ProductDetailState> emit) {
    if (state is ProductDetailLoaded) {
      final currentState = state as ProductDetailLoaded;
      emit(currentState.copyWith(selectedVariationId: event.variationId));
    }
  }
}
