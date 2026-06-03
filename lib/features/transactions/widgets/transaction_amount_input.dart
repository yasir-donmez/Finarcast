import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../l10n/app_localizations.dart';

class TransactionAmountInput extends StatelessWidget {
  final bool isFlexibleAmount;
  final String currency;
  final TextEditingController amountController;
  final TextEditingController minController;
  final TextEditingController maxController;
  final FocusNode amountFocusNode;

  const TransactionAmountInput({
    super.key,
    required this.isFlexibleAmount,
    required this.currency,
    required this.amountController,
    required this.minController,
    required this.maxController,
    required this.amountFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: isFlexibleAmount
          ? _buildFlexibleAmountDisplay(context)
          : _buildSingleAmountDisplay(context),
    );
  }

  bool _isSymbolOnLeft(String symbol) {
    return symbol == r'$' ||
           symbol == '£' ||
           symbol == '¥' ||
           symbol == '₩' ||
           symbol == '元' ||
           symbol == r'R$';
  }

  Widget _buildSingleAmountDisplay(BuildContext context) {
    final activeColor = Theme.of(context).colorScheme.primary;
    final symbolOnLeft = _isSymbolOnLeft(currency);

    return Container(
      key: const ValueKey('single_amount'),
      height: 100,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Left Side (Currency symbol if left-aligned, otherwise balanced spacer)
          SizedBox(
            width: 50,
            child: symbolOnLeft
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: Text(
                        currency,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: activeColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          
          Expanded(
            child: CustomTextField(
              controller: amountController,
              focusNode: amountFocusNode,
              hintText: "0,00",
              icon: Icons.attach_money_rounded,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [_TRCurrencyFormatter()],
              textAlign: TextAlign.center,
              fontSize: 56,
              showBackground: false,
            ),
          ),
          
          // Right Side (Currency symbol if right-aligned, otherwise balanced spacer)
          SizedBox(
            width: 50,
            child: !symbolOnLeft
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Text(
                        currency,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: activeColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildFlexibleAmountDisplay(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      key: const ValueKey('flex_amount'),
      height: 100,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: _buildFlexBox(context, l10n.minimum, minController)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              "-",
              style: TextStyle(
                fontSize: 24,
                color: AppColors.getTextSecondary(context).withValues(alpha: 0.3),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: _buildFlexBox(context, l10n.maximum, maxController)),
        ],
      ),
    );
  }

  Widget _buildFlexBox(
    BuildContext context,
    String label,
    TextEditingController controller,
  ) {
    final activeColor = Theme.of(context).colorScheme.primary;
    final symbolOnLeft = _isSymbolOnLeft(currency);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            color: AppColors.getPrimary(context).withValues(alpha: 0.7),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Left Side (Currency symbol if left-aligned, otherwise balanced spacer)
            SizedBox(
              width: 30,
              child: symbolOnLeft
                  ? Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 3.0),
                        child: Text(
                          currency,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: activeColor.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            
            Expanded(
              child: CustomTextField(
                controller: controller,
                hintText: "0,00",
                icon: Icons.attach_money_rounded,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [_TRCurrencyFormatter()],
                textAlign: TextAlign.center,
                fontSize: 24,
                showBackground: false,
              ),
            ),
            
            // Right Side (Currency symbol if right-aligned, otherwise balanced spacer)
            SizedBox(
              width: 30,
              child: !symbolOnLeft
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 3.0),
                        child: Text(
                          currency,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: activeColor.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ],
    );
  }
}

/// Akıllı Türkiye Para Formatı Formattırı
class _TRCurrencyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    // Sadece rakamlar ve virgül kalsın
    String text = newValue.text.replaceAll(RegExp(r'[^0-9,]'), '');
    
    // Sadece bir tane virgüle izin ver
    if (text.contains(',')) {
      List<String> parts = text.split(',');
      if (parts.length > 2) {
        text = '${parts[0]},${parts.sublist(1).join('')}';
      }
    }

    if (text.isEmpty) return newValue.copyWith(text: '');

    // Binlik ayırıcıları ekle (Nokta)
    String integerPart = text.contains(',') ? text.split(',')[0] : text;
    String decimalPart = text.contains(',') ? text.split(',')[1] : '';

    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String formattedInteger = integerPart.replaceAllMapped(reg, (Match m) => '${m[1]}.');

    String formatted = decimalPart.isEmpty && !text.contains(',') 
        ? formattedInteger 
        : '$formattedInteger,$decimalPart';

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
