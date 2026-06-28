import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart' as intl;

class OrderItemEntity extends Equatable {
  final int id;
  final int productId;
  final String _productName;
  final String? productNameAr;
  final String? productNameEn;
  final int quantity;
  final double unitPrice;
  final Map<String, dynamic>? options;

  const OrderItemEntity({
    required this.id,
    required this.productId,
    required String productName,
    this.productNameAr,
    this.productNameEn,
    required this.quantity,
    required this.unitPrice,
    this.options,
  }) : _productName = productName;

  String get productName {
    final locale = intl.Intl.getCurrentLocale().split('_').first;
    final val = locale == 'ar' ? productNameAr : productNameEn;
    if (val != null && val.trim().isNotEmpty) {
      return val;
    }
    return _productName;
  }

  double get lineTotal => unitPrice * quantity;

  @override
  List<Object?> get props => [id, productId, _productName, productNameAr, productNameEn, quantity, unitPrice, options];
}
