import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/string_utils.dart';
import '../../../shared/widgets/custom_bottom_sheet.dart';
import '../../../shared/widgets/clickable_action.dart';
import '../../../shared/widgets/wheel_picker.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_icon_button.dart';


class TransactionPeriodData {
  final int periodType;
  final String? expandedPeriodCategory;
  final int selectedDay;
  final DateTime selectedDateForRecurrence;
  final int duration;

  final int? totalInstallments;

  TransactionPeriodData({
    required this.periodType,
    this.expandedPeriodCategory,
    required this.selectedDay,
    required this.selectedDateForRecurrence,
    required this.duration,

    this.totalInstallments,
  });
}

class TransactionPeriodSelector extends StatefulWidget {
  final TransactionPeriodData initialData;
  final ValueChanged<TransactionPeriodData> onChanged;
  final double scalingFactor;
  final bool hidePeriodSelection;
  final bool hideOneTime;
  final bool disablePastDates;
  final bool disableFutureDates;
  final int minDuration;
  /// Periyot ve taksit seçimini kilitle (şablon düzenleme modu)
  final bool readOnlyPeriod;

  const TransactionPeriodSelector({
    super.key,
    required this.initialData,
    required this.onChanged,
    this.scalingFactor = 1.0,
    this.hidePeriodSelection = false,
    this.hideOneTime = false,
    this.disablePastDates = false,
    this.disableFutureDates = false,
    this.minDuration = 0,
    this.readOnlyPeriod = false,
  });

  @override
  State<TransactionPeriodSelector> createState() => _TransactionPeriodSelectorState();
}

class _TransactionPeriodSelectorState extends State<TransactionPeriodSelector> {
  late int _periodType;
  late String? _expandedPeriodCategory;
  late int _selectedDay;
  late DateTime _selectedDateForRecurrence;
  
  late int _duration;
  int _prevValue = 0;

  @override
  void initState() {
    super.initState();
    _periodType = widget.initialData.periodType;
    if (widget.hideOneTime && _periodType == 0) {
      _periodType = 301;
    }
    _expandedPeriodCategory = widget.initialData.expandedPeriodCategory;
    
    // Eğer null gönderildiyse (Düzenleme modu vb.), periodType'a göre otomatik çıkarım yap
    if (_expandedPeriodCategory == null) {
      final unit = _periodType ~/ 100;
      if (unit == 1) {
        _expandedPeriodCategory = 'gun';
      } else if (unit == 2 || [250, 251].contains(_periodType)) {
        _expandedPeriodCategory = 'hafta';
      } else if (unit == 3) {
        _expandedPeriodCategory = 'ay';
      } else if (unit == 4) {
        _expandedPeriodCategory = 'yil';
      }
    }
    
    _selectedDay = widget.initialData.selectedDay;
    _selectedDateForRecurrence = widget.initialData.selectedDateForRecurrence;
    
    if (widget.initialData.totalInstallments != null && widget.initialData.totalInstallments! > 0) {
      _duration = widget.initialData.totalInstallments!;

    } else if (widget.initialData.duration > 0) {
      _duration = widget.initialData.duration;
    } else {
      _duration = 0;
    }
    _prevValue = _duration;
  }

  @override
  void didUpdateWidget(covariant TransactionPeriodSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialData.periodType != oldWidget.initialData.periodType ||
        widget.initialData.selectedDateForRecurrence != oldWidget.initialData.selectedDateForRecurrence ||
        widget.initialData.totalInstallments != oldWidget.initialData.totalInstallments) {
      setState(() {
        _periodType = widget.initialData.periodType;
        if (widget.hideOneTime && _periodType == 0) {
          _periodType = 301;
        }
        _expandedPeriodCategory = widget.initialData.expandedPeriodCategory;
        
        if (_expandedPeriodCategory == null) {
          final unit = _periodType ~/ 100;
          if (unit == 1) {
            _expandedPeriodCategory = 'gun';
          } else if (unit == 2 || [250, 251].contains(_periodType)) {
            _expandedPeriodCategory = 'hafta';
          } else if (unit == 3) {
            _expandedPeriodCategory = 'ay';
          } else if (unit == 4) {
            _expandedPeriodCategory = 'yil';
          }
        }
        
        _selectedDay = widget.initialData.selectedDay;
        _selectedDateForRecurrence = widget.initialData.selectedDateForRecurrence;
        
        if (widget.initialData.totalInstallments != null && widget.initialData.totalInstallments! > 0) {
          _duration = widget.initialData.totalInstallments!;
        } else if (widget.initialData.duration > 0) {
          _duration = widget.initialData.duration;
        } else {
          _duration = 0;
        }
        _prevValue = _duration;
      });
    }
  }

  void _notifyChanges() {
    widget.onChanged(TransactionPeriodData(
      periodType: _periodType,
      expandedPeriodCategory: _expandedPeriodCategory,
      selectedDay: _selectedDay,
      selectedDateForRecurrence: _selectedDateForRecurrence,
      duration: _duration,

      totalInstallments: _duration > 0 ? _duration : null,
    ));
  }




  List<String> _getMonths(AppLocalizations l10n) => [
    l10n.january, l10n.february, l10n.march, l10n.april,
    l10n.may, l10n.june, l10n.july, l10n.august,
    l10n.september, l10n.october, l10n.november, l10n.december,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scalingFactor = widget.scalingFactor;
    final langCode = Localizations.localeOf(context).languageCode;

    return Column(
      children: [
        if (!widget.hidePeriodSelection) ...[
          // --- ESNEK PERİYOT ŞERİDİ (INLINE EXPANSION) ---
          Padding(
            padding: EdgeInsets.symmetric(vertical: 2 * scalingFactor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.event_repeat_rounded,
                      size: 20,
                      color: AppColors.getPrimary(context).withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.period.toSafeUpperCase(context),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.getTextPrimary(context).withValues(alpha: 0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                IgnorePointer(
                  ignoring: widget.readOnlyPeriod,
                  child: Opacity(
                    opacity: widget.readOnlyPeriod ? 0.6 : 1.0,
                    child: Container(
                      height: 44 * scalingFactor,
                      padding: EdgeInsets.all(4 * scalingFactor),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12 * scalingFactor),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final List<Map<String, dynamic>> allCats = [
                            {'label': l10n.oneTime, 'type': 0, 'cat': null},
                            {'label': l10n.day, 'type': 101, 'cat': 'gun'},
                            {'label': l10n.week, 'type': 201, 'cat': 'hafta'},
                            {'label': l10n.month, 'type': 301, 'cat': 'ay'},
                            {'label': l10n.yearly, 'type': 401, 'cat': 'yil'},
                          ];
                          final List<Map<String, dynamic>> cats = widget.hideOneTime
                              ? allCats.where((c) => c['cat'] != null).toList()
                              : allCats;

                          final double spacing = 4.0 * scalingFactor;
                          final double totalWidth = constraints.maxWidth;
                          final double availableWidth = totalWidth - (spacing * (cats.length - 1));

                          // Karakter bazlı ağırlıklandırma (Precision uyumlu)
                          double getWeight(int i) {
                            final c = cats[i];
                            final bool isSelected = (c['cat'] == null)
                                ? (_periodType == c['type'] && _expandedPeriodCategory == null)
                                : (_expandedPeriodCategory == c['cat']);
                            
                            if (!isSelected) return 1.0;

                            final String labelText = c['label'] as String;
                            final double charWeight = labelText.length * 0.12;

                            if (c['cat'] != null) {
                              int subCount = 0;
                              if (c['cat'] == 'gun') {
                                subCount = 4;
                              } else if (c['cat'] == 'hafta') {
                                subCount = 5;
                              } else if (c['cat'] == 'ay') {
                                subCount = 4;
                              } else if (c['cat'] == 'yil') {
                                subCount = 2;
                              }
                              return 1.8 + (subCount * 0.45) + charWeight;
                            } else {
                              return 0.8 + charWeight;
                            }
                          }

                          double totalWeight = 0;
                          for (int i = 0; i < cats.length; i++) {
                            totalWeight += getWeight(i);
                          }

                          List<double> widths = [];
                          List<double> lefts = [];
                          double currentLeft = 0;

                          for (int i = 0; i < cats.length; i++) {
                            double w = (getWeight(i) / totalWeight) * availableWidth;
                            widths.add(w);
                            lefts.add(currentLeft);
                            currentLeft += w + spacing;
                          }

                          return Stack(
                            children: List.generate(cats.length, (index) {
                              return AnimatedPositioned(
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeInOutQuart,
                                left: lefts[index],
                                width: widths[index],
                                top: 0,
                                bottom: 0,
                                child: _buildAnimatedCategoryBtnInner(cats[index], scalingFactor),
                              );
                            }),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16 * scalingFactor),
          Divider(
            height: 1, 
            thickness: 0.5, 
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
          ),
          SizedBox(height: 16 * scalingFactor),
        ],
        
          if (!widget.readOnlyPeriod)
            _buildStandardRow(
              _periodType == 0 ? l10n.selectDate : l10n.startDate,
              "${_selectedDateForRecurrence.day} ${_getMonths(l10n)[_selectedDateForRecurrence.month - 1]} ${_selectedDateForRecurrence.year}",
              Icons.calendar_today_rounded,
              widget.readOnlyPeriod ? null : () => _showFullDatePicker(l10n),
            ),
          if ((widget.hidePeriodSelection || widget.readOnlyPeriod) && _periodType != 0) ...[
            SizedBox(height: 8 * scalingFactor),
            if (_periodType ~/ 100 == 3) // Monthly
              _buildStandardRow(
                langCode == 'tr' ? 'Tekrarlama Günü' : 'Day of Month',
                langCode == 'tr' ? 'Ayın $_selectedDay. Günü' : 'Day $_selectedDay of Month',
                Icons.calendar_month_rounded,
                () => _showRecurrenceDayPicker(l10n),
              ),
            if (_periodType ~/ 100 == 4) // Yearly
              _buildStandardRow(
                langCode == 'tr' ? 'Tekrarlama Tarihi' : 'Yearly Date',
                "${_selectedDateForRecurrence.day} ${_getMonths(l10n)[_selectedDateForRecurrence.month - 1]}",
                Icons.calendar_month_rounded,
                () => _showRecurrenceMonthDayPicker(l10n),
              ),
            if (_periodType ~/ 100 == 2 && ![250, 251].contains(_periodType)) // Weekly
              _buildStandardRow(
                langCode == 'tr' ? 'Haftanın Günü' : 'Day of Week',
                _getWeekdays(l10n)[_selectedDateForRecurrence.weekday - 1],
                Icons.calendar_view_week_rounded,
                () => _showRecurrenceWeekdayPicker(l10n),
              ),
          ],
        
        // === BİTİŞ SÜRESİ / LİMİT TİPİ SEÇİCİ (Sadece periyodik durumlarda açılır, pürüzsüz animasyonlu) ===
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutQuart,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.05),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation, 
                    curve: Curves.easeOutQuart,
                  )),
                  child: child,
                ),
              );
            },
            child: (_periodType != 0 && !widget.hidePeriodSelection && !widget.readOnlyPeriod)
                ? Column(
                    key: const ValueKey('limit_panel_enabled'),
                    children: [
                      SizedBox(height: 4 * scalingFactor),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16 * scalingFactor, vertical: 12 * scalingFactor),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      size: 18 * scalingFactor,
                                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                                    ),
                                    SizedBox(width: 12 * scalingFactor),
                                    Text(
                                      (langCode == 'tr' ? 'Bitiş Süresi' : l10n.duration).toSafeUpperCase(context),
                                      style: TextStyle(
                                        fontSize: 11 * scalingFactor,
                                        fontWeight: FontWeight.w900,
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4 * scalingFactor),
                                Padding(
                                  padding: EdgeInsets.only(left: 30 * scalingFactor),
                                  child: Text(
                                    _duration == 0 
                                      ? (langCode == 'tr' ? 'Sürekli Tekrar Eder' : 'Repeats Indefinitely')
                                      : (langCode == 'tr' ? '$_duration Kez / Taksit' : '$_duration Occurrences'),
                                    style: TextStyle(
                                      fontSize: 11 * scalingFactor,
                                      color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _buildDurationBtn(Icons.remove_rounded, widget.readOnlyPeriod ? null : () {
                                  final canDecrement = _duration > 0 && _duration > widget.minDuration;
                                  if (canDecrement) {
                                    HapticFeedback.lightImpact();
                                    setState(() {
                                      _prevValue = _duration;
                                      _duration--;
                                    });
                                    _notifyChanges();
                                  } else if (_duration <= widget.minDuration && widget.minDuration > 0) {
                                    HapticFeedback.vibrate();
                                  }
                                }, scalingFactor),
                                SizedBox(width: 8 * scalingFactor),
                                SizedBox(
                                  width: 32 * scalingFactor,
                                  child: Center(
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 200),
                                      transitionBuilder: (Widget child, Animation<double> animation) {
                                        final isEntering = child.key == const ValueKey<int>(0) || child.key == ValueKey<int>(_duration);
                                        final isIncreasing = _duration >= _prevValue;
                                        double beginOffset = isIncreasing ? -1.0 : 1.0;
                                        if (!isEntering) beginOffset = -beginOffset;
 
                                        return ClipRect(
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: Offset(0.0, beginOffset),
                                              end: Offset.zero,
                                            ).animate(CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.easeInOutQuart,
                                            )),
                                            child: FadeTransition(
                                              opacity: animation,
                                              child: ScaleTransition(
                                                scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
                                                child: child,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: _duration == 0
                                          ? Icon(
                                              Icons.all_inclusive_rounded,
                                              key: const ValueKey<int>(0),
                                              size: 24 * scalingFactor,
                                              color: AppColors.getPrimary(context),
                                            )
                                          : Text(
                                              _duration.toString(),
                                              key: ValueKey<int>(_duration),
                                              style: TextStyle(
                                                fontSize: 16 * scalingFactor,
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.getPrimary(context),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8 * scalingFactor),
                                _buildDurationBtn(Icons.add_rounded, widget.readOnlyPeriod ? null : () {
                                  if (_duration < 120) {
                                    HapticFeedback.lightImpact();
                                    setState(() {
                                      _prevValue = _duration;
                                      if (_duration == 0) {
                                        _duration = 1;
                                      } else {
                                        _duration++;
                                      }
                                    });
                                    _notifyChanges();
                                  }
                                }, scalingFactor),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(
                    key: ValueKey('limit_panel_disabled'),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildStandardRow(String label, String value, IconData icon, VoidCallback? onTap) {
    final scalingFactor = widget.scalingFactor;
    final content = Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * scalingFactor, vertical: 12 * scalingFactor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18 * scalingFactor,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
              ),
              SizedBox(width: 12 * scalingFactor),
              Text(
                label.toSafeUpperCase(context),
                style: TextStyle(
                  fontSize: 11 * scalingFactor,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14 * scalingFactor,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              if (onTap != null) ...[
                SizedBox(width: 4 * scalingFactor),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18 * scalingFactor,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return ClickableAction(
      onTap: onTap,
      color: Colors.transparent,
      showFlash: false,
      padding: EdgeInsets.zero,
      child: content,
    );
  }

  Widget _buildAnimatedCategoryBtnInner(Map<String, dynamic> catData, double scalingFactor) {
    final l10n = AppLocalizations.of(context)!;
    final String label = catData['label'];
    final int type = catData['type'];
    final String? category = catData['cat'];

    final bool isThisExpanded = (category == null)
        ? (_periodType == type && _expandedPeriodCategory == null)
        : (_expandedPeriodCategory == category);

    final bool isAnyOtherExpanded = _expandedPeriodCategory != null && !isThisExpanded;
    final String abb = label.isNotEmpty ? label[0].toSafeUpperCase(context) : "";

    return ClickableAction(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          if (category == null) {
            _periodType = type;
            _expandedPeriodCategory = null;
            _selectedDay = 1;
          } else {
            if (_expandedPeriodCategory != category) {
              _expandedPeriodCategory = category;
              _periodType = type;
            }
          }
        });
        _notifyChanges();
      },
      color: Colors.transparent,
      padding: EdgeInsets.zero,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutQuart,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: isThisExpanded 
              ? AppColors.getPrimary(context).withValues(alpha: 0.15) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8 * scalingFactor),
          border: Border.all(
            color: isThisExpanded 
                ? AppColors.getPrimary(context).withValues(alpha: 0.2) 
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8 * scalingFactor),
          child: Center(
            child: ClipRect(
              child: OverflowBox(
                maxWidth: double.infinity,
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 8 * scalingFactor),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        (isAnyOtherExpanded) ? abb : label,
                        key: ValueKey((isAnyOtherExpanded) ? abb : label),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontSize: 11 * scalingFactor,
                          fontWeight: isThisExpanded ? FontWeight.w900 : FontWeight.w600,
                          color: isThisExpanded ? AppColors.getPrimary(context) : AppColors.getTextSecondary(context).withValues(alpha: 0.6),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 550),
                      curve: Curves.easeInOutQuart,
                      alignment: Alignment.centerLeft,
                      child: (isThisExpanded && category != null)
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 6 * scalingFactor),
                              Container(width: 1, height: 12 * scalingFactor, color: AppColors.getPrimary(context).withValues(alpha: 0.3)),
                              SizedBox(width: 4 * scalingFactor),
                              _buildSubPeriodInlineOptions(category, l10n, scalingFactor),
                            ],
                          )
                        : const SizedBox.shrink(),
                    ),
                    SizedBox(width: 8 * scalingFactor),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubPeriodInlineOptions(String category, AppLocalizations l10n, double scalingFactor) {
    List<Widget> options = [];
    if (category == 'gun') {
      options = [
        _buildPeriodBtnSheet('1g', 101, scalingFactor),
        _buildPeriodBtnSheet('2g', 102, scalingFactor),
        _buildPeriodBtnSheet('3g', 103, scalingFactor),
        _buildPeriodBtnSheet('4g', 104, scalingFactor),
      ];
    } else if (category == 'hafta') {
      options = [
        _buildPeriodBtnSheet('1h', 201, scalingFactor),
        _buildPeriodBtnSheet('2h', 202, scalingFactor),
        _buildPeriodBtnSheet('3h', 203, scalingFactor),
        _buildPeriodBtnSheet(l10n.weekdaysShort, 250, scalingFactor),
        _buildPeriodBtnSheet(l10n.weekendsShort, 251, scalingFactor),
      ];
    } else if (category == 'ay') {
      options = [
        _buildPeriodBtnSheet('1a', 301, scalingFactor),
        _buildPeriodBtnSheet('2a', 302, scalingFactor),
        _buildPeriodBtnSheet('3a', 303, scalingFactor),
        _buildPeriodBtnSheet('6a', 306, scalingFactor),
      ];
    } else if (category == 'yil') {
      options = [
        _buildPeriodBtnSheet('1y', 401, scalingFactor),
        _buildPeriodBtnSheet('2y', 402, scalingFactor),
      ];
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: options.expand((w) => [w, SizedBox(width: 4 * scalingFactor)]).toList()..removeLast(),
    );
  }

  Widget _buildPeriodBtnSheet(String label, int type, double scalingFactor) {
    final bool isActive = _periodType == type;
    return ClickableAction(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _periodType = type);
        _notifyChanges();
      },
      color: isActive ? AppColors.getPrimary(context).withValues(alpha: 0.2) : Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: 4 * scalingFactor, vertical: 4 * scalingFactor),
      borderRadius: BorderRadius.circular(6 * scalingFactor),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9 * scalingFactor,
          fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
          color: isActive ? AppColors.getPrimary(context) : AppColors.getTextSecondary(context).withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildDurationBtn(IconData icon, VoidCallback? onTap, double scalingFactor) {
    return CustomIconButton(
      icon: icon,
      onTap: onTap ?? () {},
      size: 18 * scalingFactor,
      padding: 7 * scalingFactor,
      borderRadius: 8 * scalingFactor,
      color: onTap == null ? Colors.grey : AppColors.getPrimary(context),
    );
  }



  void _showFullDatePicker(AppLocalizations l10n) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final minDate = widget.disablePastDates ? today : DateTime(now.year - 5, 1, 1);
    final maxDate = widget.disableFutureDates ? today : DateTime(now.year + 5, 12, 31);

    // Sınır dışındaysa düzelt
    DateTime effectiveInitial = _selectedDateForRecurrence;
    if (widget.disablePastDates && effectiveInitial.isBefore(today)) {
      effectiveInitial = today;
    }
    if (widget.disableFutureDates && effectiveInitial.isAfter(today)) {
      effectiveInitial = today;
    }

    int tempDay = effectiveInitial.day;
    int tempMonth = effectiveInitial.month;
    int tempYear = effectiveInitial.year;

    final int startYear = minDate.year;
    final int endYear = maxDate.year;
    final List<String> yearItems = List.generate(endYear - startYear + 1, (i) => (startYear + i).toString());
    final int initialYearIndex = (tempYear - startYear).clamp(0, yearItems.length - 1);

    CustomBottomSheet.show(
      context: context,
      title: l10n.selectDate,
      child: StatefulBuilder(
        builder: (ctx, setPickerState) {
          // Kısıtlı ay listesini hesapla
          int maxMonth = 12;
          int minMonth = 1;
          if (widget.disableFutureDates && tempYear == today.year) {
            maxMonth = today.month;
          }
          if (widget.disablePastDates && tempYear == today.year) {
            minMonth = today.month;
          }
          final monthCount = maxMonth - minMonth + 1;
          final monthItems = List.generate(monthCount, (i) => _getMonths(l10n)[minMonth - 1 + i]);

          // Ay dışındaysa düzelt
          if (tempMonth < minMonth) {
            tempMonth = minMonth;
          } else if (tempMonth > maxMonth) {
            tempMonth = maxMonth;
          }

          // Kısıtlı gün listesini hesapla
          final daysInMonth = DateTime(tempYear, tempMonth + 1, 0).day;
          int maxDay = daysInMonth;
          int minDay = 1;
          if (widget.disableFutureDates && tempYear == today.year && tempMonth == today.month) {
            maxDay = today.day;
          }
          if (widget.disablePastDates && tempYear == today.year && tempMonth == today.month) {
            minDay = today.day;
          }
          final dayCount = maxDay - minDay + 1;
          final dayItems = List.generate(dayCount, (i) => (minDay + i).toString());

          // Gün dışındaysa düzelt
          if (tempDay < minDay) tempDay = minDay;
          if (tempDay > maxDay) tempDay = maxDay;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 240,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Day
                    Expanded(
                      flex: 7,
                      child: WheelPicker.strings(
                        key: ValueKey('day_${tempMonth}_$tempYear'),
                        items: dayItems,
                        initialItem: (tempDay - minDay).clamp(0, dayCount - 1),
                        onSelectedItemChanged: (idx) {
                          tempDay = minDay + idx;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Month
                    Expanded(
                      flex: 13,
                      child: WheelPicker.strings(
                        key: ValueKey('month_$tempYear'),
                        items: monthItems,
                        initialItem: (tempMonth - minMonth).clamp(0, monthCount - 1),
                        onSelectedItemChanged: (idx) {
                          setPickerState(() {
                            tempMonth = minMonth + idx;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Year
                    Expanded(
                      flex: 9,
                      child: WheelPicker.strings(
                        items: yearItems,
                        initialItem: initialYearIndex,
                        onSelectedItemChanged: (idx) {
                          setPickerState(() {
                            tempYear = startYear + idx;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                label: l10n.ok,
                onTap: () {
                  final selected = DateTime(tempYear, tempMonth, tempDay);
                  setState(() {
                    _selectedDateForRecurrence = selected;
                    _selectedDay = selected.day;
                  });
                  _notifyChanges();
                  Navigator.pop(context);
                  HapticFeedback.mediumImpact();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  List<String> _getWeekdays(AppLocalizations l10n) => [
    l10n.monday, l10n.tuesday, l10n.wednesday, l10n.thursday,
    l10n.friday, l10n.saturday, l10n.sunday,
  ];

  void _showRecurrenceDayPicker(AppLocalizations l10n) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    int tempDay = _selectedDay;
    final dayItems = List.generate(31, (i) => (i + 1).toString());

    CustomBottomSheet.show(
      context: context,
      title: l10n.selectDate,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 200,
            child: WheelPicker.strings(
              items: dayItems,
              initialItem: (tempDay - 1).clamp(0, 30),
              onSelectedItemChanged: (idx) {
                tempDay = idx + 1;
              },
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            label: l10n.ok,
            onTap: () {
              setState(() {
                _selectedDay = tempDay;
                final lastDay = DateTime(_selectedDateForRecurrence.year, _selectedDateForRecurrence.month + 1, 0).day;
                final finalDay = _selectedDay > lastDay ? lastDay : _selectedDay;
                _selectedDateForRecurrence = DateTime(_selectedDateForRecurrence.year, _selectedDateForRecurrence.month, finalDay);
              });
              _notifyChanges();
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
            },
          ),
        ],
      ),
    );
  }

  void _showRecurrenceMonthDayPicker(AppLocalizations l10n) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    int tempDay = _selectedDateForRecurrence.day;
    int tempMonth = _selectedDateForRecurrence.month;
    final months = _getMonths(l10n);

    CustomBottomSheet.show(
      context: context,
      title: l10n.selectDate,
      child: StatefulBuilder(
        builder: (ctx, setPickerState) {
          final daysInMonth = DateTime(_selectedDateForRecurrence.year, tempMonth + 1, 0).day;
          final dayItems = List.generate(daysInMonth, (i) => (i + 1).toString());
          if (tempDay > daysInMonth) tempDay = daysInMonth;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Day
                    Expanded(
                      flex: 8,
                      child: WheelPicker.strings(
                        key: ValueKey('recur_day_$tempMonth'),
                        items: dayItems,
                        initialItem: (tempDay - 1).clamp(0, daysInMonth - 1),
                        onSelectedItemChanged: (idx) {
                          tempDay = idx + 1;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Month
                    Expanded(
                      flex: 15,
                      child: WheelPicker.strings(
                        items: months,
                        initialItem: tempMonth - 1,
                        onSelectedItemChanged: (idx) {
                          setPickerState(() {
                            tempMonth = idx + 1;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: l10n.ok,
                onTap: () {
                  setState(() {
                    final lastDay = DateTime(_selectedDateForRecurrence.year, tempMonth + 1, 0).day;
                    final finalDay = tempDay > lastDay ? lastDay : tempDay;
                    _selectedDateForRecurrence = DateTime(_selectedDateForRecurrence.year, tempMonth, finalDay);
                    _selectedDay = finalDay;
                  });
                  _notifyChanges();
                  Navigator.pop(context);
                  HapticFeedback.mediumImpact();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRecurrenceWeekdayPicker(AppLocalizations l10n) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    int tempWeekday = _selectedDateForRecurrence.weekday;
    final weekdays = _getWeekdays(l10n);

    CustomBottomSheet.show(
      context: context,
      title: l10n.selectDate,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 200,
            child: WheelPicker.strings(
              items: weekdays,
              initialItem: tempWeekday - 1,
              onSelectedItemChanged: (idx) {
                tempWeekday = idx + 1;
              },
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            label: l10n.ok,
            onTap: () {
              setState(() {
                final int currentWeekday = _selectedDateForRecurrence.weekday;
                final int difference = tempWeekday - currentWeekday;
                _selectedDateForRecurrence = _selectedDateForRecurrence.add(Duration(days: difference));
                _selectedDay = _selectedDateForRecurrence.day;
              });
              _notifyChanges();
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
            },
          ),
        ],
      ),
    );
  }
}
