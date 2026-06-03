import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/database/models/vault.dart';
import '../../../shared/widgets/picker_field.dart';

class TransactionVaultSelector extends StatefulWidget {
  final List<Vault> vaults;
  final List<int> selectedVaultIds;
  final ValueChanged<List<int>> onChanged;
  final double scalingFactor;

  const TransactionVaultSelector({
    super.key,
    required this.vaults,
    required this.selectedVaultIds,
    required this.onChanged,
    this.scalingFactor = 1.0,
  });

  @override
  State<TransactionVaultSelector> createState() => _TransactionVaultSelectorState();
}

class _TransactionVaultSelectorState extends State<TransactionVaultSelector> {
  @override
  Widget build(BuildContext context) {
    final vaults = widget.vaults;
    final selectedVaultIds = widget.selectedVaultIds;
    final onChanged = widget.onChanged;

    final l10n = AppLocalizations.of(context)!;
    final List<Vault> vaultOptions = vaults;

    // Mevcut seçimin indexini bul
    int currentIndex = vaultOptions.indexWhere(
      (v) => selectedVaultIds.contains(v.id),
    );
    if (currentIndex == -1) currentIndex = 0;

    return PickerField(
      icon: Icons.account_balance_wallet_rounded,
      label: l10n.vault,
      items: vaultOptions.map((v) => v.name).toList(),
      selectedIndex: currentIndex,
      scalingFactor: widget.scalingFactor,
      onChanged: (index) {
        if (index >= 0 && index < vaultOptions.length) {
          final vault = vaultOptions[index];
          onChanged([vault.id]);
        }
      },
    );
  }
}
