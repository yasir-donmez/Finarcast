import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/custom_dismissible.dart';
import '../../../core/theme/app_constants.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/database/models/vault.dart';
import '../../../l10n/app_localizations.dart';
import '../../transactions/widgets/transaction_category_data.dart';
import '../../../shared/widgets/inline_picker.dart';
import '../../../shared/widgets/custom_card.dart';
import '../services/draft_service.dart';


class DismissibleDraftCard extends StatefulWidget {
  final DraftTransaction draft;
  final List<Vault> vaults;
  final String currencySymbol;
  final int selectedVaultId;
  final ValueChanged<int> onVaultSelected;
  final int? selectedTargetVaultId;
  final ValueChanged<int>? onTargetVaultSelected;
  final VoidCallback onEdit;
  final VoidCallback onApprove;
  final VoidCallback onDelete;

  const DismissibleDraftCard({
    super.key,
    required this.draft,
    required this.vaults,
    required this.currencySymbol,
    required this.selectedVaultId,
    required this.onVaultSelected,
    this.selectedTargetVaultId,
    this.onTargetVaultSelected,
    required this.onEdit,
    required this.onApprove,
    required this.onDelete,
  });

  @override
  State<DismissibleDraftCard> createState() => _DismissibleDraftCardState();
}

class _DismissibleDraftCardState extends State<DismissibleDraftCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return CustomDismissible(
      enableLeftToRight: true,
      enableRightToLeft: true,
      onDismissed: (direction) {
        if (direction == SwipeDismissDirection.leftToRight) {
          widget.onApprove();
        } else {
          widget.onDelete();
        }
      },
      leftToRightBackgroundBuilder: (context, progress, isThresholdReached) =>
          _buildSwipeBackground(isLeftToRight: true, progress: progress, isThresholdReached: isThresholdReached),
      rightToLeftBackgroundBuilder: (context, progress, isThresholdReached) =>
          _buildSwipeBackground(isLeftToRight: false, progress: progress, isThresholdReached: isThresholdReached),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            _scale = 0.98;
          });
        },
        onTapUp: (_) {
          setState(() {
            _scale = 1.0;
          });
        },
        onTapCancel: () {
          setState(() {
            _scale = 1.0;
          });
        },
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onEdit();
        },
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          child: _buildDraftCard(context),
        ),
      ),
    );
  }

  /// Swipe arka plan — ikon 3D perspektifli, çekme oranına bağlı döner
  Widget _buildSwipeBackground({
    required bool isLeftToRight,
    required double progress,
    required bool isThresholdReached,
  }) {
    final color = isLeftToRight
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);
    final alignment = isLeftToRight
        ? Alignment.centerLeft
        : Alignment.centerRight;
    
    // Y-eksenindeki 3D kapı açılma yönünü kenarlara göre simetrik yapalım:
    // Soldayken (+), Sağdayken (-) yönde dönerek ekrana doğru açılır.
    final rotationSign = isLeftToRight ? 1.0 : -1.0;

    // İkon dönme açısı: çekme ilerledikçe 90° → 0° (yüzünü gösterir)
    // İlk %25 çekmede dönme tamamlanır, sonra ikon düz kalır
    final rotationProgress = (progress / 0.25).clamp(0.0, 1.0);
    final angle = (1.0 - rotationProgress) * (math.pi / 2) * rotationSign;

    // Slide in from outer edges towards center
    final slideSign = isLeftToRight ? -1.0 : 1.0;
    final slideProgress = (progress / 0.25).clamp(0.0, 1.0);
    final xOffset = 30.0 * (1.0 - slideProgress) * slideSign;
    
    // Proportional fade-in before threshold, solid active color at/after threshold
    final double bgAlpha = isThresholdReached
        ? 0.22
        : (progress / 0.20).clamp(0.0, 1.0) * 0.08;
        
    final double borderAlpha = isThresholdReached
        ? 0.45
        : (progress / 0.20).clamp(0.0, 1.0) * 0.12;

    final Color bgColor = color.withValues(alpha: bgAlpha);
    final Color borderColor = color.withValues(alpha: borderAlpha);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 80),
      curve: Curves.easeOutQuad,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Align(
            alignment: alignment,
            child: Transform(
              transform: Matrix4.translationValues(xOffset, 0.0, 0.0)
                ..setEntry(3, 2, 0.004) // Perspektif derinliği
                ..rotateY(angle),
              alignment: Alignment.center,
              child: AnimatedScale(
                scale: isThresholdReached ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOutCubic,
                child: Opacity(
                  opacity: rotationProgress,
                  child: isLeftToRight
                      ? AnimatedCheckIcon(progress: progress, color: color)
                      : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.diagonal3Values(-1.0, 1.0, 1.0),
                          child: AnimatedTrashIcon(progress: progress, color: color),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Taslak İşlem Kartı
  Widget _buildDraftCard(BuildContext context) {
    final bool isTransfer = widget.draft.categoryId == 'transfer';

    // Kategori detaylarını TransactionCategoryData'dan çekelim
    final categories = widget.draft.isIncome
        ? TransactionCategoryData.getIncomeCategories(context, AppLocalizations.of(context)!)
        : TransactionCategoryData.getExpenseCategories(context, AppLocalizations.of(context)!);

    String? parentCatName;
    String? subCatName;
    IconData catIcon = Icons.help_outline;
    Color catColor = AppColors.getTextFaint(context);

    if (isTransfer) {
      parentCatName = AppLocalizations.of(context)!.vaultTransfer;
      catIcon = Icons.swap_horiz_rounded;
      catColor = Colors.blue;
    } else {
      for (var c in categories) {
        if (c['id'] == widget.draft.categoryId) {
          parentCatName = c['name'] as String?;
          catIcon = c['icon'] as IconData? ?? Icons.help_outline;
          catColor = c['color'] as Color? ?? AppColors.getTextFaint(context);
          break;
        }
        final subs = c['subModels'] as List?;
        if (subs != null) {
          for (var s in subs) {
            if (s['id'] == widget.draft.categoryId) {
              parentCatName = c['name'] as String?;
              subCatName = s['name'] as String?;
              catIcon = s['icon'] as IconData? ?? c['icon'] as IconData? ?? Icons.help_outline;
              catColor = c['color'] as Color? ?? AppColors.getTextFaint(context);
              break;
            }
          }
        }
        if (parentCatName != null) break;
      }
    }

    final String finalCatName = parentCatName ?? AppLocalizations.of(context)!.otherCategory;
    final categoryAccentColor = AppColors.getAccentDeep(context, catColor);
    final Widget categoryHeaderWidget;
    if (subCatName != null) {
      categoryHeaderWidget = Text.rich(
        TextSpan(
          children: [
            TextSpan(text: finalCatName),
            TextSpan(
              text: ' / ',
              style: TextStyle(
                color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: subCatName,
              style: TextStyle(
                color: categoryAccentColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 13,
          color: AppColors.getTextPrimary(context),
        ),
      );
    } else {
      categoryHeaderWidget = Text(
        finalCatName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 13,
          color: AppColors.getTextPrimary(context),
        ),
      );
    }

    final String? cardNote = () {
      if (widget.draft.title.isNotEmpty &&
          widget.draft.title != '__EMPTY_DRAFT__' &&
          widget.draft.title != '__RECEIPT_EXPENSE__' &&
          widget.draft.title != finalCatName &&
          widget.draft.title != subCatName) {
        return widget.draft.note != null && widget.draft.note!.isNotEmpty
            ? '${widget.draft.title} - ${widget.draft.note}'
            : widget.draft.title;
      }
      return widget.draft.note;
    }();

    final List<String> vaultNames = widget.vaults.map((v) => v.name).toList();
    
    int selectedIndex = 0;
    if (widget.vaults.isNotEmpty) {
      final index = widget.vaults.indexWhere((v) => v.id == widget.selectedVaultId);
      if (index != -1) {
        selectedIndex = index;
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final sf = (screenHeight / 812.0).clamp(0.85, 1.0);
    
    final Color typeColor;
    final Color amountColor;
    if (isTransfer) {
      typeColor = Colors.blue;
      amountColor = Colors.blueGrey;
    } else {
      typeColor = widget.draft.isIncome
          ? AppColors.getIncome(context)
          : AppColors.getExpense(context);
      amountColor = typeColor;
    }



    // 2. Plan Badge (if periodType > 0)
    final bool isPlan = widget.draft.periodType > 0;
    final IconData planIcon;
    final Color planColor = Colors.purple.shade600;

    if (isPlan) {
      if (widget.draft.remainingInstallments == 1) {
        planIcon = Icons.calendar_today_rounded;
      } else {
        planIcon = Icons.sync_rounded;
      }
    } else {
      planIcon = Icons.help;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CustomCard(
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.45],
                colors: [
                  typeColor.withValues(alpha: isDark ? 0.14 : 0.18),
                  Colors.transparent,
                ],
              ),
            ),
            child: Stack(
              children: [
                // 1. Arka Plan Watermark (Filigran) İkonu
                Positioned(
                  right: -15 * sf,
                  bottom: -10 * sf,
                  child: IgnorePointer(
                    child: Transform.rotate(
                      angle: -math.pi / 7, // ~25 derece eğim
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              catColor.withValues(alpha: isDark ? 0.16 : 0.09),
                              catColor.withValues(alpha: 0.0),
                            ],
                            stops: const [0.35, 1.0],
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.srcIn,
                        child: Icon(
                          catIcon,
                          size: 105 * sf,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                // 2. Kart İçeriği
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Üst Satır: Sol Sütun (İkon), Orta Sütun (Kategori & Not), Sağ Üst Sütun (Tutar)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sol Sütun: Sadece Kategori İkonu
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.getAccentDeep(context, catColor).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(catIcon, color: AppColors.getAccentDeep(context, catColor), size: 18),
                    ),
                    const SizedBox(width: 10),
                    
                    // Orta/Üst Sütun: Kategori Adı ve Kısaltılmış İşlem Notu + Plan İkonu
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Kategori Adı (Market • Gıda)
                          categoryHeaderWidget,
                          const SizedBox(height: 3),
                          // Kısaltılmış İşlem Notu (cardNote) + Plan İkonu (Aynı Satırda Kompakt Gösterim)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (cardNote != null && cardNote.isNotEmpty)
                                Flexible(
                                  child: Text(
                                    cardNote,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.getTextFaint(context),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              if (isPlan) ...[
                                if (cardNote != null && cardNote.isNotEmpty)
                                  const SizedBox(width: 4),
                                Icon(
                                  planIcon,
                                  size: 10,
                                  color: planColor,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    
                    // Sağ Üst: Tutar ve Tip İkonu (Yazısız, sadece ikon ile kompakt gösterim)
                    Text(
                      () {
                        final curr = widget.draft.currency ?? widget.currencySymbol;
                        if (widget.draft.minAmount != null || widget.draft.maxAmount != null) {
                          final minFormatted = CurrencyUtils.formatAmount(widget.draft.minAmount ?? 0, currencySymbol: curr);
                          final maxFormatted = CurrencyUtils.formatAmount(widget.draft.maxAmount ?? 0, currencySymbol: curr);
                          return "$minFormatted ~ $maxFormatted";
                        }
                        return CurrencyUtils.formatAmount(widget.draft.amount, currencySymbol: curr);
                      }(),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: amountColor,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 10),
                
                // Alt Satır (Aksiyon ve Meta Veri): Sol alta kasa seçici, sağ alta ise tarihler
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Kasa Seçici(leri)
                    if (isTransfer)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Kaynak Kasa
                          SizedBox(
                            width: 80,
                            height: 36,
                            child: InlinePicker(
                              items: vaultNames,
                              selectedIndex: selectedIndex,
                              onChanged: (index) {
                                if (index >= 0 && index < widget.vaults.length) {
                                  widget.onVaultSelected(widget.vaults[index].id);
                                }
                              },
                              width: 80,
                              height: 36,
                              scalingFactor: 0.95,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 12,
                              color: AppColors.getTextSecondary(context),
                            ),
                          ),
                          // Hedef Kasa
                          () {
                            int targetSelectedIndex = 0;
                            if (widget.vaults.isNotEmpty && widget.selectedTargetVaultId != null) {
                              final index = widget.vaults.indexWhere((v) => v.id == widget.selectedTargetVaultId);
                              if (index != -1) {
                                targetSelectedIndex = index;
                              }
                            }
                            return SizedBox(
                              width: 80,
                              height: 36,
                              child: InlinePicker(
                                items: vaultNames,
                                selectedIndex: targetSelectedIndex,
                                onChanged: (index) {
                                  if (index >= 0 && index < widget.vaults.length && widget.onTargetVaultSelected != null) {
                                    widget.onTargetVaultSelected!(widget.vaults[index].id);
                                  }
                                },
                                width: 80,
                                height: 36,
                                scalingFactor: 0.95,
                              ),
                            );
                          }(),
                        ],
                      )
                    else
                      SizedBox(
                        width: 125,
                        height: 36,
                        child: InlinePicker(
                          items: vaultNames,
                          selectedIndex: selectedIndex,
                          onChanged: (index) {
                            if (index >= 0 && index < widget.vaults.length) {
                              widget.onVaultSelected(widget.vaults[index].id);
                            }
                          },
                          width: 125,
                          height: 36,
                          scalingFactor: 0.95,
                        ),
                      ),
                    
                    const SizedBox(width: 4),

                    // Sağ Alt: Tarihler ve Hatırlatıcılar (FittedBox ile taşmayı önler ve tek satırda tutar)
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Hatırlatıcı varsa solunda gösterilsin
                            if (widget.draft.isNotificationEnabled) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade700.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: Colors.amber.shade700.withValues(alpha: 0.2),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.notifications_active_rounded,
                                      size: 9,
                                      color: Colors.amber.shade700,
                                    ),
                                    const SizedBox(width: 2.5),
                                    Text(
                                      '${widget.draft.notificationReminderDays == 0 ? AppLocalizations.of(context)!.today : AppLocalizations.of(context)!.daysShort(widget.draft.notificationReminderDays)} ${widget.draft.notificationHour.toString().padLeft(2, '0')}:${widget.draft.notificationMinute.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        fontSize: 7.5,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.amber.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              DateFormat('dd MMM, HH:mm').format(widget.draft.date),
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.getTextFaint(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
),
    );
  }


}



