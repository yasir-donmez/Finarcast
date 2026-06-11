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
import '../../../shared/widgets/custom_card.dart';
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
  bool _hasTriggeredStartHaptic = false;
  bool _hasTriggeredThresholdHaptic = false;
  double _cardWidth = 300.0;

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
    _hasTriggeredStartHaptic = false;
    _hasTriggeredThresholdHaptic = false;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent += details.primaryDelta!;
    });

    final ratio = _dragExtent.abs() / _cardWidth;

    // Trigger light haptic when swipe first reveals the background
    if (!_hasTriggeredStartHaptic && _dragExtent.abs() > 8) {
      _hasTriggeredStartHaptic = true;
      HapticFeedback.lightImpact();
    }

    // Trigger medium haptic when threshold is crossed (feedback for full transformation/action active)
    if (!_hasTriggeredThresholdHaptic && ratio >= _dismissThreshold) {
      _hasTriggeredThresholdHaptic = true;
      HapticFeedback.mediumImpact();
    } else if (_hasTriggeredThresholdHaptic && ratio < _dismissThreshold) {
      // Reset if user drags back below threshold
      _hasTriggeredThresholdHaptic = false;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dismissed) return;

    final ratio = _dragExtent.abs() / _cardWidth;
    final velocity = details.primaryVelocity ?? 0;

    // Eşiği geç veya hızlı fırlat → dismiss
    if (ratio > _dismissThreshold || velocity.abs() > 1200) {
      final target = _dragExtent > 0 ? _cardWidth * 1.2 : -_cardWidth * 1.2;
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
    return LayoutBuilder(
      builder: (context, constraints) {
        _cardWidth = constraints.maxWidth;
        // progress: 0.0 (hiç çekilmedi) → 1.0 (tam çekildi)
        final progress = (_dragExtent.abs() / _cardWidth).clamp(0.0, 1.0);
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
      },
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
    final alignment = isLeftToRight
        ? Alignment.centerLeft
        : Alignment.centerRight;
    final rotationSign = isLeftToRight ? -1.0 : 1.0;

    // İkon dönme açısı: çekme ilerledikçe 90° → 0° (yüzünü gösterir)
    // İlk %25 çekmede dönme tamamlanır, sonra ikon düz kalır
    final rotationProgress = (progress / 0.25).clamp(0.0, 1.0);
    final angle = (1.0 - rotationProgress) * (math.pi / 2) * rotationSign;

    // Slide in from outer edges towards center
    final slideSign = isLeftToRight ? -1.0 : 1.0;
    final slideProgress = (progress / 0.25).clamp(0.0, 1.0);
    final xOffset = 30.0 * (1.0 - slideProgress) * slideSign;

    final bool isThresholdReached = _hasTriggeredThresholdHaptic;
    
    // Proportional fade-in before threshold, solid active color at/after threshold
    final double bgAlpha = isThresholdReached
        ? 0.22
        : (progress / _dismissThreshold).clamp(0.0, 1.0) * 0.08;
        
    final double borderAlpha = isThresholdReached
        ? 0.45
        : (progress / _dismissThreshold).clamp(0.0, 1.0) * 0.12;

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
                      : AnimatedTrashIcon(progress: progress, color: color),
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
    final typeColor = widget.draft.isIncome
        ? AppColors.getIncome(context)
        : AppColors.getExpense(context);

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
                    
                    // Orta/Üst Sütun: Kategori Adı ve Kısaltılmış İşlem Notu
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Kategori Adı (Market • Gıda)
                          categoryHeaderWidget,
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
                          if (index >= 0 && index < widget.vaults.length) {
                            widget.onVaultSelected(widget.vaults[index].id);
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
                                  '${widget.draft.notificationReminderDays == 0 ? AppLocalizations.of(context)!.today : "${widget.draft.notificationReminderDays}g"} ${widget.draft.notificationHour.toString().padLeft(2, '0')}:${widget.draft.notificationMinute.toString().padLeft(2, '0')}',
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
    ),
  ),
),
    );
  }
}

// ==========================================
// CUSTOM ANIMATED ICONS FOR SWIPE ACTIONS
// ==========================================

/// Animasyonlu Çöp Kutusu İkonu (Kapak yukarı kalkar ve döner)
class AnimatedTrashIcon extends StatelessWidget {
  final double progress;
  final Color color;
  const AnimatedTrashIcon({super.key, required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 28,
      child: CustomPaint(
        painter: _TrashIconPainter(
          progress: progress,
          color: color,
        ),
      ),
    );
  }
}

class _TrashIconPainter extends CustomPainter {
  final double progress;
  final Color color;

  _TrashIconPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Lid lifts up (starts immediately on swipe)
    final lidLift = (progress * -18).clamp(-8.0, 0.0);
    // Lid rotates/tilts (goes from 0 to -0.35 radians)
    final lidRotation = (progress * -0.8).clamp(-0.35, 0.0);

    // 1. Draw Bin Body (Tapered trapezoid - enlarged and proportional)
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final bodyTopY = centerY - 2;
    final bodyBottomY = centerY + 11;
    final bodyTopHalfWidth = 8.0;
    final bodyBottomHalfWidth = 6.0;

    final bodyPath = Path()
      ..moveTo(centerX - bodyTopHalfWidth, bodyTopY)
      ..lineTo(centerX - bodyBottomHalfWidth, bodyBottomY)
      ..lineTo(centerX + bodyBottomHalfWidth, bodyBottomY)
      ..lineTo(centerX + bodyTopHalfWidth, bodyTopY)
      ..close();

    final bodyPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(bodyPath, bodyPaint);

    // Draw 2 vertical stripes inside the body (slanted to match the taper)
    final stripeY1 = bodyTopY + 3.0;
    final stripeY2 = bodyBottomY - 3.0;
    canvas.drawLine(
      Offset(centerX - 3.0, stripeY1),
      Offset(centerX - 2.5, stripeY2),
      paint..strokeWidth = 1.8,
    );
    canvas.drawLine(
      Offset(centerX + 3.0, stripeY1),
      Offset(centerX + 2.5, stripeY2),
      paint..strokeWidth = 1.8,
    );

    // 2. Draw Lid (with lift and rotate - aligned with the wider body)
    canvas.save();
    
    // Rotate around the left hinge of the lid
    final hingeX = centerX - 10.0;
    final hingeY = centerY - 4.0 + lidLift;
    canvas.translate(hingeX, hingeY);
    canvas.rotate(lidRotation);
    canvas.translate(-hingeX, -hingeY);

    final lidY = centerY - 4.0 + lidLift;

    // Draw lid line
    canvas.drawLine(
      Offset(centerX - 10.0, lidY),
      Offset(centerX + 10.0, lidY),
      paint..strokeWidth = 2.0,
    );

    // Draw lid handle
    final handlePath = Path()
      ..moveTo(centerX - 3.5, lidY)
      ..lineTo(centerX - 3.5, lidY - 3.5)
      ..lineTo(centerX + 3.5, lidY - 3.5)
      ..lineTo(centerX + 3.5, lidY);
    
    canvas.drawPath(handlePath, paint..strokeWidth = 1.8);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_TrashIconPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Animasyonlu Onaylama İkonu (Çizgi kendini soldan sağa çizer)
class AnimatedCheckIcon extends StatelessWidget {
  final double progress;
  final Color color;
  const AnimatedCheckIcon({super.key, required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    // Check işareti çizim ilerlemesi (%5 ile %25 kaydırma arasında çizim tamamlanır)
    final checkProgress = ((progress - 0.05) / 0.20).clamp(0.0, 1.0);

    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(
        painter: _CheckIconPainter(
          checkProgress: checkProgress,
          color: color,
        ),
      ),
    );
  }
}

class _CheckIconPainter extends CustomPainter {
  final double checkProgress;
  final Color color;

  _CheckIconPainter({
    required this.checkProgress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1.5;

    // Hafif renkli arka plan dairesi
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Dış daire çizgisi
    final outlinePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, outlinePaint);

    if (checkProgress > 0) {
      final path = Path();
      final start = Offset(size.width * 0.28, size.height * 0.5);
      final turn = Offset(size.width * 0.45, size.height * 0.68);
      final end = Offset(size.width * 0.72, size.height * 0.35);

      final checkPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      if (checkProgress < 0.4) {
        // İlk çizgi çiziliyor (soldan köşeye)
        final t = checkProgress / 0.4;
        final p = Offset.lerp(start, turn, t)!;
        path.moveTo(start.dx, start.dy);
        path.lineTo(p.dx, p.dy);
      } else {
        // İlk çizgi tamam, ikinci çizgi çiziliyor (köşeden yukarı)
        final t = (checkProgress - 0.4) / 0.6;
        final p = Offset.lerp(turn, end, t)!;
        path.moveTo(start.dx, start.dy);
        path.lineTo(turn.dx, turn.dy);
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, checkPaint);
    }
  }

  @override
  bool shouldRepaint(_CheckIconPainter oldDelegate) {
    return oldDelegate.checkProgress != checkProgress || oldDelegate.color != color;
  }
}

