import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../vaults_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/database/models/transaction_status.dart';

class HistoryRecordTile extends StatefulWidget {
  final TransactionUI transaction;
  final Future<void> Function() onReviewed;
  final Future<void> Function() onSkipped;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const HistoryRecordTile({
    super.key,
    required this.transaction,
    required this.onReviewed,
    required this.onSkipped,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<HistoryRecordTile> createState() => _HistoryRecordTileState();
}

class _HistoryRecordTileState extends State<HistoryRecordTile>
    with SingleTickerProviderStateMixin {
  double _dragExtent = 0.0;
  double _scale = 1.0;
  late AnimationController _animController;
  late Animation<double> _animation;
  bool _dismissed = false;
  bool _hasTriggeredStartHaptic = false;
  bool _hasTriggeredThresholdHaptic = false;
  double _cardWidth = 300.0;

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
    final tx = widget.transaction;
    final bool isSkipped = tx.status == TransactionStatus.skipped;
    final bool isReviewed = tx.isReviewed;

    double delta = details.primaryDelta!;
    setState(() {
      _dragExtent += delta;
      if (isSkipped) {
        // Skipped transactions can only be swiped right (to review/unskip)
        _dragExtent = _dragExtent.clamp(0.0, double.infinity);
      } else if (isReviewed) {
        // Reviewed transactions can only be swiped left (to skip)
        _dragExtent = _dragExtent.clamp(-double.infinity, 0.0);
      }
    });

    final ratio = _dragExtent.abs() / _cardWidth;

    if (!_hasTriggeredStartHaptic && _dragExtent.abs() > 8) {
      _hasTriggeredStartHaptic = true;
      HapticFeedback.lightImpact();
    }

    if (!_hasTriggeredThresholdHaptic && ratio >= _dismissThreshold) {
      _hasTriggeredThresholdHaptic = true;
      HapticFeedback.mediumImpact();
    } else if (_hasTriggeredThresholdHaptic && ratio < _dismissThreshold) {
      _hasTriggeredThresholdHaptic = false;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dismissed) return;

    final ratio = _dragExtent.abs() / _cardWidth;
    final velocity = details.primaryVelocity ?? 0;

    if (ratio > _dismissThreshold || velocity.abs() > 1200) {
      final target = _dragExtent > 0 ? _cardWidth * 1.2 : -_cardWidth * 1.2;
      _dismissed = true;

      _animation = Tween(begin: _dragExtent, end: target).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeInCubic),
      );
      _animController.forward(from: 0).then((_) {
        if (_dragExtent > 0) {
          widget.onReviewed().then((_) {
            if (mounted) {
              setState(() {
                _dragExtent = 0.0;
                _dismissed = false;
              });
            }
          });
        } else {
          widget.onSkipped().then((_) {
            if (mounted) {
              setState(() {
                _dragExtent = 0.0;
                _dismissed = false;
              });
            }
          });
        }
      });
      HapticFeedback.mediumImpact();
    } else {
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
        final progress = (_dragExtent.abs() / _cardWidth).clamp(0.0, 1.0);
        final isLeftToRight = _dragExtent > 0;
        final showBackground = _dragExtent.abs() > 2;

        return Stack(
          children: [
            if (showBackground)
              Positioned.fill(
                child: _buildSwipeBackground(
                  isLeftToRight: isLeftToRight,
                  progress: progress,
                ),
              ),

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
                  widget.onTap();
                },
                onLongPress: () {
                  HapticFeedback.heavyImpact();
                  widget.onLongPress();
                },
                child: AnimatedScale(
                  scale: _scale,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeInOut,
                  child: _buildCardContent(context),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSwipeBackground({
    required bool isLeftToRight,
    required double progress,
  }) {
    final color = isLeftToRight
        ? const Color(0xFF10B981)
        : const Color(0xFFF59E0B);
    final alignment = isLeftToRight
        ? Alignment.centerLeft
        : Alignment.centerRight;
    final rotationSign = isLeftToRight ? -1.0 : 1.0;

    final rotationProgress = (progress / 0.25).clamp(0.0, 1.0);
    final angle = (1.0 - rotationProgress) * (math.pi / 2) * rotationSign;

    final slideSign = isLeftToRight ? -1.0 : 1.0;
    final slideProgress = (progress / 0.25).clamp(0.0, 1.0);
    final xOffset = 30.0 * (1.0 - slideProgress) * slideSign;

    final bool isThresholdReached = _hasTriggeredThresholdHaptic;
    
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
      margin: const EdgeInsets.only(bottom: 8),
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
                ..setEntry(3, 2, 0.004)
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
                      : AnimatedSkipIcon(progress: progress, color: color),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    final tx = widget.transaction;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    
    final bool isSkipped = tx.status == TransactionStatus.skipped;
    final bool isReviewed = tx.isReviewed;

    final double opacity = isSkipped ? 0.45 : 1.0;
    final TextDecoration textDecoration = isSkipped ? TextDecoration.lineThrough : TextDecoration.none;

    final amountColor = isSkipped
        ? AppColors.getTextSecondary(context).withValues(alpha: 0.5)
        : (tx.isIncome ? AppColors.getIncome(context) : AppColors.getExpense(context));

    final String amountText = tx.minAmount != null && tx.maxAmount != null
        ? "${tx.isIncome ? '+' : '-'}${CurrencyUtils.formatAmount(tx.minAmount!, currencySymbol: tx.currency ?? "₺")} - ${CurrencyUtils.formatAmount(tx.maxAmount!, currencySymbol: tx.currency ?? "₺")}"
        : "${tx.isIncome ? '+' : '-'}${CurrencyUtils.formatAmount(tx.effectiveAmount, currencySymbol: tx.currency ?? "₺")}";

    String? installmentLabel;
    if (tx.installmentNumber != null && tx.totalInstallments != null) {
      installmentLabel = '${tx.installmentNumber}/${tx.totalInstallments}';
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final sf = (screenHeight / 812.0).clamp(0.85, 1.0);

    Widget cardContent = Opacity(
      opacity: opacity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16 * sf),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.45],
              colors: [
                tx.color.withValues(alpha: isDark ? 0.14 : 0.18),
                Colors.transparent,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -15 * sf,
                bottom: -10 * sf,
                child: IgnorePointer(
                  child: Transform.rotate(
                    angle: -math.pi / 7,
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            tx.color.withValues(alpha: isDark ? 0.16 : 0.09),
                            tx.color.withValues(alpha: 0.0),
                          ],
                          stops: const [0.35, 1.0],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcIn,
                      child: Icon(
                        tx.icon,
                        size: 105 * sf,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.getAccentDeep(context, tx.color).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(tx.icon, color: AppColors.getAccentDeep(context, tx.color), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  tx.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.getTextPrimary(context),
                                    decoration: textDecoration,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                tx.isIncome ? l10n.income : l10n.expense,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.getTextSecondary(context).withValues(alpha: 0.6)),
                              ),
                              Text(
                                ' • ',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.getTextSecondary(context).withValues(alpha: 0.3),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  DateFormat('d MMMM yyyy', locale).format(tx.date),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.getTextSecondary(context).withValues(alpha: 0.6),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (installmentLabel != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  installmentLabel,
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.getTextSecondary(context),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              amountText,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: amountColor,
                                  decoration: textDecoration),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (isSkipped)
                          Icon(
                            Icons.skip_next_rounded,
                            size: 14,
                            color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                          )
                        else if (!isReviewed)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 3, top: 3, bottom: 3),
                            decoration: BoxDecoration(
                              color: AppColors.getPrimary(context),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.getPrimary(context).withValues(alpha: 0.4),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          )
                        else
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 14,
                            color: AppColors.getIncome(context).withValues(alpha: 0.7),
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
    );

    final cardContainer = CustomCard(
      padding: EdgeInsets.zero,
      child: cardContent,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: cardContainer,
    );
  }
}

// ==========================================
// CUSTOM ANIMATED ICONS FOR SWIPE ACTIONS
// ==========================================

class AnimatedCheckIcon extends StatelessWidget {
  final double progress;
  final Color color;
  const AnimatedCheckIcon({super.key, required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
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

    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

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
        final t = checkProgress / 0.4;
        final p = Offset.lerp(start, turn, t)!;
        path.moveTo(start.dx, start.dy);
        path.lineTo(p.dx, p.dy);
      } else {
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

class AnimatedSkipIcon extends StatelessWidget {
  final double progress;
  final Color color;
  const AnimatedSkipIcon({super.key, required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    final skipProgress = ((progress - 0.05) / 0.20).clamp(0.0, 1.0);

    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(
        painter: _SkipIconPainter(
          skipProgress: skipProgress,
          color: color,
        ),
      ),
    );
  }
}

class _SkipIconPainter extends CustomPainter {
  final double skipProgress;
  final Color color;

  _SkipIconPainter({
    required this.skipProgress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1.5;

    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    final outlinePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, outlinePaint);

    if (skipProgress > 0) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      // Draw two chevrons pointing to the right (fast forward)
      final start1 = Offset(size.width * 0.32, size.height * 0.32);
      final mid1 = Offset(size.width * 0.5, size.height * 0.5);
      final end1 = Offset(size.width * 0.32, size.height * 0.68);

      final start2 = Offset(size.width * 0.54, size.height * 0.32);
      final mid2 = Offset(size.width * 0.72, size.height * 0.5);
      final end2 = Offset(size.width * 0.54, size.height * 0.68);

      if (skipProgress < 0.5) {
        final t = skipProgress / 0.5;
        final pStart = Offset.lerp(start1, mid1, t)!;
        final pEnd = Offset.lerp(end1, mid1, t)!;
        final path = Path()
          ..moveTo(start1.dx, start1.dy)
          ..lineTo(pStart.dx, pStart.dy)
          ..moveTo(end1.dx, end1.dy)
          ..lineTo(pEnd.dx, pEnd.dy);
        canvas.drawPath(path, paint);
      } else {
        final path1 = Path()
          ..moveTo(start1.dx, start1.dy)
          ..lineTo(mid1.dx, mid1.dy)
          ..lineTo(end1.dx, end1.dy);
        canvas.drawPath(path1, paint);

        final t = (skipProgress - 0.5) / 0.5;
        final pStart = Offset.lerp(start2, mid2, t)!;
        final pEnd = Offset.lerp(end2, mid2, t)!;
        final path2 = Path()
          ..moveTo(start2.dx, start2.dy)
          ..lineTo(pStart.dx, pStart.dy)
          ..moveTo(end2.dx, end2.dy)
          ..lineTo(pEnd.dx, pEnd.dy);
        canvas.drawPath(path2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_SkipIconPainter oldDelegate) {
    return oldDelegate.skipProgress != skipProgress || oldDelegate.color != color;
  }
}
