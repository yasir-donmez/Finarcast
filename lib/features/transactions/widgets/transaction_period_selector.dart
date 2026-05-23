import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_constants.dart';
import '../../../l10n/app_localizations.dart';
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

  TransactionPeriodData({
    required this.periodType,
    this.expandedPeriodCategory,
    required this.selectedDay,
    required this.selectedDateForRecurrence,
    required this.duration,
  });
}

class TransactionPeriodSelector extends StatefulWidget {
  final TransactionPeriodData initialData;
  final ValueChanged<TransactionPeriodData> onChanged;
  final double scalingFactor;

  const TransactionPeriodSelector({
    super.key,
    required this.initialData,
    required this.onChanged,
    this.scalingFactor = 1.0,
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
  int _prevDuration = 0;

  @override
  void initState() {
    super.initState();
    _periodType = widget.initialData.periodType;
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
    _duration = widget.initialData.duration;
    _prevDuration = _duration;
  }

  void _notifyChanges() {
    widget.onChanged(TransactionPeriodData(
      periodType: _periodType,
      expandedPeriodCategory: _expandedPeriodCategory,
      selectedDay: _selectedDay,
      selectedDateForRecurrence: _selectedDateForRecurrence,
      duration: _duration,
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

    return Column(
      children: [
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
                    l10n.period.toUpperCase(),
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
              Container(
                height: 44 * scalingFactor,
                padding: EdgeInsets.all(4 * scalingFactor),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12 * scalingFactor),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final List<Map<String, dynamic>> cats = [
                      {'label': l10n.oneTime, 'type': 0, 'cat': null},
                      {'label': l10n.day, 'type': 101, 'cat': 'gun'},
                      {'label': l10n.week, 'type': 201, 'cat': 'hafta'},
                      {'label': l10n.month, 'type': 301, 'cat': 'ay'},
                      {'label': l10n.yearly, 'type': 401, 'cat': 'yil'},
                    ];

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
        
        // === BAŞLANGIÇ TARİHİ (TÜM PERİYOTLAR İÇİN - SABİT VE HİÇBİR ZAMAN ANİME EDİLMEZ) ===
        _buildStandardRow(
          _periodType == 0 ? l10n.selectDate : "Başlangıç Tarihi",
          "${_selectedDateForRecurrence.day} ${_getMonths(l10n)[_selectedDateForRecurrence.month - 1]} ${_selectedDateForRecurrence.year}",
          Icons.calendar_today_rounded,
          () => _showFullDatePicker(l10n),
        ),
        
        // === BİTİŞ SÜRESİ (Sadece periyodik durumlarda açılır, pürüzsüz animasyonlu) ===
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
            child: _periodType != 0
                ? Column(
                    key: const ValueKey('duration_panel_enabled'),
                    children: [
                      SizedBox(height: 16 * scalingFactor),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16 * scalingFactor, 
                          vertical: 8 * scalingFactor,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.timer_rounded,
                              size: 18 * scalingFactor,
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                            ),
                            SizedBox(width: 12 * scalingFactor),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.duration.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11 * scalingFactor,
                                      fontWeight: FontWeight.w900,
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  Text(
                                    _duration == 0 
                                        ? l10n.repeatsIndefinitely 
                                        : '$_duration ${l10n.endsAfter}',
                                    style: TextStyle(
                                      fontSize: 11 * scalingFactor,
                                      color: AppColors.getTextSecondary(context).withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                _buildDurationBtn(Icons.remove_rounded, () {
                                  if (_duration > 0) {
                                    setState(() { 
                                      _prevDuration = _duration;
                                      _duration--; 
                                    });
                                    _notifyChanges();
                                  }
                                }, scalingFactor),
                                SizedBox(width: 8 * scalingFactor),
                                SizedBox(
                                  width: 32 * scalingFactor,
                                  child: Center(
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 200),
                                      transitionBuilder: (Widget child, Animation<double> animation) {
                                        final isEntering = child.key == ValueKey<int>(_duration);
                                        final isIncreasing = _duration >= _prevDuration;
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
                                      child: Text(
                                        _duration == 0 ? "\u221E" : _duration.toString(),
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
                                _buildDurationBtn(Icons.add_rounded, () {
                                  if (_duration < 120) {
                                    setState(() { 
                                      _prevDuration = _duration;
                                      _duration++; 
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
                    key: ValueKey('duration_panel_disabled'),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildStandardRow(String label, String value, IconData icon, VoidCallback onTap) {
    final scalingFactor = widget.scalingFactor;
    return ClickableAction(
      onTap: onTap,
      color: Colors.transparent,
      showFlash: false,
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
                label.toUpperCase(),
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
              SizedBox(width: 4 * scalingFactor),
              Icon(
                Icons.chevron_right_rounded,
                size: 18 * scalingFactor,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        ],
      ),
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
    final String abb = label.isNotEmpty ? label[0].toUpperCase() : "";

    return ClickableAction(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          if (category == null) {
            _periodType = type;
            _expandedPeriodCategory = null;
            _duration = 0;
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
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
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
        _buildPeriodBtnSheet(isTr ? 'İçi' : 'Wkd', 250, scalingFactor),
        _buildPeriodBtnSheet(isTr ? 'Sonu' : 'Wke', 251, scalingFactor),
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

  Widget _buildDurationBtn(IconData icon, VoidCallback onTap, double scalingFactor) {
    return CustomIconButton(
      icon: icon,
      onTap: onTap,
      size: 18 * scalingFactor,
      padding: 7 * scalingFactor,
      borderRadius: 8 * scalingFactor,
      color: AppColors.getPrimary(context),
    );
  }



  void _showFullDatePicker(AppLocalizations l10n) {
    int tempDay = _selectedDateForRecurrence.day;
    int tempMonth = _selectedDateForRecurrence.month;
    int tempYear = _selectedDateForRecurrence.year;
    
    CustomBottomSheet.show(
      context: context,
      title: l10n.selectDate,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 240,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Day
                SizedBox(
                  width: 70,
                  child: WheelPicker.strings(
                    items: List.generate(31, (i) => (i + 1).toString()),
                    initialItem: tempDay - 1,
                    onSelectedItemChanged: (idx) => tempDay = idx + 1,
                  ),
                ),
                const SizedBox(width: 10),
                // Month
                SizedBox(
                  width: 130,
                  child: WheelPicker.strings(
                    items: List.generate(12, (i) => _getMonths(l10n)[i]),
                    initialItem: tempMonth - 1,
                    onSelectedItemChanged: (idx) => tempMonth = idx + 1,
                  ),
                ),
                const SizedBox(width: 10),
                // Year
                SizedBox(
                  width: 90,
                  child: WheelPicker.strings(
                    items: List.generate(11, (i) => (DateTime.now().year - 5 + i).toString()),
                    initialItem: tempYear - (DateTime.now().year - 5),
                    onSelectedItemChanged: (idx) => tempYear = DateTime.now().year - 5 + idx,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          CustomButton(
            label: l10n.ok,
            onTap: () {
              setState(() {
                _selectedDateForRecurrence = DateTime(tempYear, tempMonth, tempDay);
                _selectedDay = tempDay;
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
