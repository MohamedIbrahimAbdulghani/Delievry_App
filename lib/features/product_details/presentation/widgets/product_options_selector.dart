import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/addon_entity.dart';
import '../../domain/entities/variation_entity.dart';
import 'package:delievry_app/l10n/app_localizations.dart';
import '../../../../core/utils/data_localization_helper.dart';

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
          Text(
            AppLocalizations.of(context)?.choiceOfSize ?? 'Choice of size',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...variations.map((v) => // ignore: deprecated_member_use
              RadioListTile<String>(
                title: Text(DataLocalizationHelper.translate(context, v.name), style: const TextStyle(fontWeight: FontWeight.w500)),
                secondary: Text('+${DataLocalizationHelper.formatCurrency(context, v.price)}'),
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
          Text(
            AppLocalizations.of(context)?.frequentlyBoughtTogether ?? 'Frequently bought together',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...addons.map((a) => CheckboxListTile(
                title: Text(DataLocalizationHelper.translate(context, a.name), style: const TextStyle(fontWeight: FontWeight.w500)),
                secondary: Text('+${DataLocalizationHelper.formatCurrency(context, a.price)}'),
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
