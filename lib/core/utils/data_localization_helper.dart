import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:delievry_app/l10n/app_localizations.dart';

class DataLocalizationHelper {
  static String translate(BuildContext context, String text) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return text;

    switch (text) {
      case 'Small':
        return l10n.small;
      case 'Medium':
        return l10n.medium;
      case 'Large':
        return l10n.large;
      case 'Extra Cheese':
        return l10n.extraCheese;
      case 'Bacon':
        return l10n.bacon;
      case 'Avocado':
        return l10n.avocado;
      case 'Demo City':
        return l10n.demoCity;
      case 'Cairo':
      case 'القاهره':
        return l10n.cairo;
      default:
        return text;
    }
  }

  static String formatCurrency(BuildContext context, double amount) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'ar') {
      final formatter = NumberFormat.decimalPattern('ar');
      return '${formatter.format(amount)} دولار';
    } else {
      final formatter = NumberFormat.decimalPattern('en');
      return '\$${formatter.format(amount)}';
    }
  }

  static String formatNumber(BuildContext context, num value) {
    final locale = Localizations.localeOf(context).languageCode;
    return NumberFormat.decimalPattern(locale).format(value);
  }
}
