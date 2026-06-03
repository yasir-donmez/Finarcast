import 'package:flutter/material.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/picker_field.dart';
import '../../../l10n/app_localizations.dart';

class TransactionCurrencySelector extends StatefulWidget {
  final String selectedCurrency;
  final ValueChanged<String> onChanged;
  final double scalingFactor;

  const TransactionCurrencySelector({
    super.key,
    required this.selectedCurrency,
    required this.onChanged,
    this.scalingFactor = 1.0,
  });

  @override
  State<TransactionCurrencySelector> createState() => _TransactionCurrencySelectorState();
}

class _TransactionCurrencySelectorState extends State<TransactionCurrencySelector> {
  final List<String> _options = AppCurrency.supportedSymbols;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    int currentIndex = _options.indexOf(widget.selectedCurrency);
    if (currentIndex == -1) currentIndex = 0;

    return PickerField(
      icon: Icons.currency_exchange_rounded,
      label: l10n.currency,
      items: _options,
      selectedIndex: currentIndex,
      scalingFactor: widget.scalingFactor,
      onChanged: (index) {
        if (index >= 0 && index < _options.length) {
          widget.onChanged(_options[index]);
        }
      },
    );
  }
}
