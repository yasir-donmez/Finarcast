import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_constants.dart';
import '../../../core/database/models/vault.dart';
import '../../../l10n/app_localizations.dart';
import '../../transactions/widgets/transaction_category_data.dart';
import '../../../shared/widgets/inline_picker.dart';
import '../services/draft_service.dart';


class DismissibleDraftCard extends StatefulWidget {
  final DraftTransaction draft;
  final List<Vault> vaults;
  final String currencySymbol;
  final int selectedVaultId;
  final ValueChanged<int> onVaultSelected;
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
    required this.onEdit,
    required this.onApprove,
    required this.onDelete,
  });

  @override
  State<DismissibleDraftCard> createState() => _DismissibleDraftCardState();
}

class _DismissibleDraftCardState extends State<DismissibleDraftCard>
    with SingleTickerProviderStateMixin {
  double _dragExtent = 0.0;
  double _scale = 1.0;
  late AnimationController _animController;
  late Animation<double> _animation;
  bool _dismissed = false;

  // %20 genişliği aşarsa dismiss olur
  static const double _dismissThreshold = 0.20;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = _animController.drive(Tween(begin: 0.0, end: 0.0));
    _animController.addListener(() {
      if (mounted) {
        setState(() {
          _dragExtent = _animation.value;
        });
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails details) {
    _animController.stop();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent += details.primaryDelta!;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dismissed) return;

    final width = context.size?.width ?? 300;
    final ratio = _dragExtent.abs() / width;
    final velocity = details.primaryVelocity ?? 0;

    // Eşiği geç veya hızlı fırlat → dismiss
    if (ratio > _dismissThreshold || velocity.abs() > 1200) {
      final target = _dragExtent > 0 ? width * 1.2 : -width * 1.2;
      _dismissed = true;

      _animation = Tween(begin: _dragExtent, end: target).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeInCubic),
      );
      _animController.forward(from: 0).then((_) {
        if (_dragExtent > 0) {
          widget.onApprove();
        } else {
          widget.onDelete();
        }
      });
      HapticFeedback.mediumImpact();
    } else {
      // Geri yay
      _animation = Tween(begin: _dragExtent, end: 0.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
      );
      _animController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // progress: 0.0 (hiç çekilmedi) → 1.0 (tam çekildi)
    final progress = (_dragExtent.abs() / width).clamp(0.0, 1.0);
    final isLeftToRight = _dragExtent > 0;
    final showBackground = _dragExtent.abs() > 2;

    return Stack(
      children: [
        // Arka plan (swipe yönüne göre)
        if (showBackground)
          Positioned.fill(
            child: _buildSwipeBackground(
              isLeftToRight: isLeftToRight,
              progress: progress,
            ),
          ),

        // Kart (sürüklenen)
        Transform.translate(
          offset: Offset(_dragExtent, 0),
          child: GestureDetector(
            onHorizontalDragStart: _onDragStart,
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
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
        ),
      ],
    );
  }

  /// Swipe arka plan — ikon 3D perspektifli, çekme oranına bağlı döner
  Widget _buildSwipeBackground({
    required bool isLeftToRight,
    required double progress,
  }) {
    final color = isLeftToRight
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);
    final icon = isLeftToRight
        ? Icons.check_circle_rounded
        : Icons.delete_rounded;
    final alignment = isLeftToRight
        ? Alignment.centerLeft
        : Alignment.centerRight;
    final rotationSign = isLeftToRight ? -1.0 : 1.0;

    // İkon dönme açısı: çekme ilerledikçe 90° → 0° (yüzünü gösterir)
    // İlk %25 çekmede dönme tamamlanır, sonra ikon düz kalır
    final rotationProgress = (progress / 0.25).clamp(0.0, 1.0);
    final angle = (1.0 - rotationProgress) * (math.pi / 2) * rotationSign;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08 + progress * 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.15 + progress * 0.25),
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
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.004) // Perspektif derinliği
                ..rotateY(angle),
              alignment: Alignment.center,
              child: Opacity(
                opacity: rotationProgress,
                child: Icon(
                  icon,
                  color: color.withValues(alpha: 0.5 + progress * 0.5),
                  size: 28,
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
    // Kategori detaylarını TransactionCategoryData'dan çekelim
    final categories = widget.draft.isIncome
        ? TransactionCategoryData.getIncomeCategories(context, AppLocalizations.of(context)!)
        : TransactionCategoryData.getExpenseCategories(context, AppLocalizations.of(context)!);

    String? parentCatName;
    String? subCatName;
    IconData catIcon = Icons.help_outline;
    Color catColor = AppColors.getTextFaint(context);

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

    final String finalCatName = parentCatName ?? 'Diğer';
    final String displayCategoryHeader = subCatName != null
        ? '$finalCatName • $subCatName'
        : finalCatName;

    final String? cardNote = () {
      if (widget.draft.title.isNotEmpty &&
          widget.draft.title != 'Boş Taslak' &&
          widget.draft.title != 'Fiş Harcaması' &&
          widget.draft.title != finalCatName &&
          widget.draft.title != subCatName) {
        return widget.draft.note != null && widget.draft.note!.isNotEmpty
            ? '${widget.draft.title} - ${widget.draft.note}'
            : widget.draft.title;
      }
      return widget.draft.note;
    }();

    final List<String> vaultNames = [
      AppLocalizations.of(context)!.mainVault,
      ...widget.vaults.map((v) => v.name),
    ];
    
    int selectedIndex = 0;
    if (widget.selectedVaultId != -1) {
      final index = widget.vaults.indexWhere((v) => v.id == widget.selectedVaultId);
      if (index != -1) {
        selectedIndex = index + 1;
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseSurfaceColor = AppColors.getThemeSurface(context, 1);
    
    // Premium yumuşak gradyan (gelir/gider tipine göre köşede hafif bir renk ışıltısı verir)
    // Color.lerp ile tamamen opaque (katı) renk üretiyoruz — arka plan sızmaz
    final typeColor = widget.draft.isIncome
        ? AppColors.getIncome(context)
        : AppColors.getExpense(context);
    final tintedColor = Color.lerp(baseSurfaceColor, typeColor, isDark ? 0.06 : 0.08)!;
    
    final cardGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        baseSurfaceColor,
        baseSurfaceColor,
        tintedColor,
      ],
    );
    
    final activeBorderColor = Color.lerp(
      AppColors.getThemeBorder(context, 1),
      typeColor,
      isDark ? 0.15 : 0.20,
    )!;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: activeBorderColor,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 1. Arka Plan Watermark (Filigran) İkonu
          Positioned(
            right: -12,
            bottom: -12,
            child: IgnorePointer(
              child: Transform.rotate(
                angle: -math.pi / 7, // ~25 derece eğim
                child: Icon(
                  catIcon,
                  size: 85,
                  color: catColor.withValues(alpha: isDark ? 0.05 : 0.06),
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
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(catIcon, color: catColor, size: 20),
                    ),
                    const SizedBox(width: 10),
                    
                    // Orta/Üst Sütun: Kategori Adı ve Kısaltılmış İşlem Notu
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Kategori Adı (Market • Gıda)
                          Text(
                            displayCategoryHeader,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 3),
                          // Kısaltılmış İşlem Notu (cardNote)
                          if (cardNote != null && cardNote.isNotEmpty)
                            Text(
                              cardNote,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.getTextFaint(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    
                    // Sağ Üst: Tutar (En belirgin yer)
                    Text(
                      () {
                        final sign = widget.draft.isIncome ? "+" : "-";
                        final curr = widget.draft.currency ?? widget.currencySymbol;
                        if (widget.draft.minAmount != null || widget.draft.maxAmount != null) {
                          final minStr = widget.draft.minAmount?.toStringAsFixed(0) ?? "0";
                          final maxStr = widget.draft.maxAmount?.toStringAsFixed(0) ?? "0";
                          return "$sign$minStr-$maxStr $curr";
                        }
                        return "$sign${widget.draft.amount.toStringAsFixed(0)} $curr";
                      }(),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: widget.draft.isIncome
                            ? AppColors.getIncome(context)
                            : AppColors.getExpense(context),
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
                    // Sol Alt: Kasa Seçici (InlinePicker)
                    SizedBox(
                      width: 125,
                      height: 36,
                      child: InlinePicker(
                        items: vaultNames,
                        selectedIndex: selectedIndex,
                        onChanged: (index) {
                          if (index == 0) {
                            widget.onVaultSelected(-1);
                          } else {
                            widget.onVaultSelected(widget.vaults[index - 1].id);
                          }
                        },
                        width: 125,
                        height: 36,
                        scalingFactor: 0.95,
                      ),
                    ),
                    
                    // Sağ Alt: Tarihler ve Hatırlatıcılar
                    Row(
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
                                  '${widget.draft.notificationReminderDays == 0 ? "Bugün" : "${widget.draft.notificationReminderDays}g"} ${widget.draft.notificationHour.toString().padLeft(2, '0')}:${widget.draft.notificationMinute.toString().padLeft(2, '0')}',
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
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

