import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_toastr.dart';
import '../../../../di/injection_container.dart';
import '../../../../core/events/order_events.dart';
import '../bloc/checkout_bloc.dart';
import '../bloc/checkout_event.dart';
import '../bloc/checkout_state.dart';
import 'package:delievry_app/l10n/app_localizations.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late CheckoutBloc _bloc;
  final TextEditingController _addressController = TextEditingController(text: '123 Market St, San Francisco, CA');
  final TextEditingController _notesController = TextEditingController();
  String _selectedPaymentMethod = 'Credit Card';

  @override
  void initState() {
    super.initState();
    _bloc = sl<CheckoutBloc>();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _bloc,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => context.pop(),
          ),
          title: Text(AppLocalizations.of(context)?.checkout ?? 'Checkout', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        ),
        body: BlocConsumer<CheckoutBloc, CheckoutState>(
          listener: (context, state) {
            if (state is CheckoutSuccess) {
              context.read<CartBloc>().add(ClearCart());
              sl<OrderEventBus>().fire(const OrderPlacedEvent());
              _showSuccessDialog();
            } else if (state is CheckoutError) {
              context.showErrorToast(
                title: 'Checkout Error',
                message: state.message,
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(AppLocalizations.of(context)?.deliveryAddress ?? 'Delivery Address'),
                  const SizedBox(height: 12),
                  _buildAddressField(),
                  const SizedBox(height: 24),
                  _buildSectionTitle(AppLocalizations.of(context)?.paymentMethods ?? 'Payment Method'),
                  const SizedBox(height: 12),
                  _buildPaymentMethods(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Order Notes'),
                  const SizedBox(height: 12),
                  _buildNotesField(),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: state is CheckoutLoading ? null : _placeOrder,
                      child: state is CheckoutLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              AppLocalizations.of(context)?.placeOrder ?? 'Place Order',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
    );
  }

  Widget _buildAddressField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(_addressController.text, style: const TextStyle(fontSize: 14))),
          IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    final methods = ['Credit Card', 'Cash on Delivery'];
    return Column(
      children: methods.map((m) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12)),
        // ignore: deprecated_member_use
        child: RadioListTile<String>(
          title: Text(m),
          value: m,
          // ignore: deprecated_member_use
          groupValue: _selectedPaymentMethod,
          activeColor: AppColors.primary,
          // ignore: deprecated_member_use
          onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
        ),
      )).toList(),
    );
  }

  Widget _buildNotesField() {
    return TextField(
      controller: _notesController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)?.addNoteToOrder ?? 'Add a note to your order...',
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  void _placeOrder() {
    final mappedPaymentMethod = _selectedPaymentMethod == 'Credit Card' ? 'card' : 'cod';
    _bloc.add(PlaceOrderEvent(
      address: _addressController.text,
      paymentMethod: mappedPaymentMethod,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    ));
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            Text(AppLocalizations.of(context)?.success ?? 'Success!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)?.orderPlacedSuccessfully ?? 'Your order has been placed successfully.', textAlign: TextAlign.center),
            const SizedBox(height: 32),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                context.go('/orders');
              },
              child: Text(AppLocalizations.of(context)?.viewMyOrders ?? 'View My Orders'),
            ),
          ),
        ],
      ),
    );
  }
}
