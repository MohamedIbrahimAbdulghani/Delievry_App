import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/addon_entity.dart';
import '../../domain/entities/variation_entity.dart';

class ProductOptionsSelector extends StatelessWidget {
  final List<VariationEntity> variations;
  final List<AddonEntity> addons;
  final String? selectedVariationId;
  final List<String> selectedAddonIds;
  final Function(String) onVariationSelected;
  final Function(String) onAddonToggled;

  const ProductOptionsSelector({
    super.key,
    required this.variations,
    required this.addons,
    required this.selectedVariationId,
    required this.selectedAddonIds,
    required this.onVariationSelected,
    required this.onAddonToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (variations.isNotEmpty) ...[
          const Text(
            'Choice of size',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...variations.map((v) => // ignore: deprecated_member_use
              RadioListTile<String>(
                title: Text(v.name),
                secondary: Text('+\$${v.price.toStringAsFixed(2)}'),
                value: v.id,
                // ignore: deprecated_member_use
                groupValue: selectedVariationId,
                activeColor: AppColors.primary,
                // ignore: deprecated_member_use
                onChanged: (value) => onVariationSelected(value!),
                contentPadding: EdgeInsets.zero,
              )),
          const SizedBox(height: 24),
        ],
        if (addons.isNotEmpty) ...[
          const Text(
            'Frequently bought together',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...addons.map((a) => CheckboxListTile(
                title: Text(a.name),
                secondary: Text('+\$${a.price.toStringAsFixed(2)}'),
                value: selectedAddonIds.contains(a.id),
                activeColor: AppColors.primary,
                onChanged: (value) => onAddonToggled(a.id),
                contentPadding: EdgeInsets.zero,
              )),
        ],
      ],
    );
  }
}
