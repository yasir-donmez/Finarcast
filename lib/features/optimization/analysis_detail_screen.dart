import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_constants.dart';
import '../../core/database/database_service.dart';
import '../../core/database/models/financial_goal.dart';
import 'ai_service.dart';
import 'optimization_providers.dart';
import '../../l10n/app_localizations.dart';

import 'widgets/result/analysis_sliver_header.dart';
import 'widgets/result/analysis_status_section.dart';
import 'widgets/result/analysis_optimization_section.dart';
import 'widgets/result/analysis_feedback_section.dart';

import '../auth/widgets/precision_background.dart';

class AnalysisDetailScreen extends StatefulWidget {
  final FinancialGoal goal;
  const AnalysisDetailScreen({super.key, required this.goal});

  @override
  State<AnalysisDetailScreen> createState() => _AnalysisDetailScreenState();
}

class _AnalysisDetailScreenState extends State<AnalysisDetailScreen> {
  final _currencyFormat = NumberFormat('#,##0', 'tr_TR');
  late AnalysisResult _result;
  bool? _userApproval;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _userApproval = widget.goal.userApproved;
    _parseData();
  }

  void _parseData() {
    if (widget.goal.analysisRawData == null) {
      setState(() => _hasError = true);
      return;
    }

    try {
      final data = jsonDecode(widget.goal.analysisRawData!);
      final snapData = data['snapshot'];
      final optData = data['optimization'];

      final snapshot = AnalysisSnapshot(
        currentBalance: (snapData['currentBalance'] as num).toDouble(),
        targetAmount: (snapData['targetAmount'] as num).toDouble(),
        gap: (snapData['gap'] as num).toDouble(),
        monthlyIncome: (snapData['monthlyIncome'] as num).toDouble(),
        monthlyExpense: (snapData['monthlyExpense'] as num).toDouble(),
        monthlySurplus: (snapData['monthlySurplus'] as num).toDouble(),
        months: snapData['months'],
        requiredMonthlySaving: (snapData['requiredMonthlySaving'] as num).toDouble(),
        isAlreadyOnTrack: snapData['isAlreadyOnTrack'],
        currencySymbol: snapData['currencySymbol'] ?? widget.goal.currencySymbol,
      );

      OptimizationResult? opt;
      if (optData != null) {
        opt = OptimizationResult(
          coachMessage: optData['coachMessage'],
          isFeasible: optData['isFeasible'] ?? true,
          cuts: (optData['cuts'] as List)
              .map(
                (c) => CutSuggestion(
                  category: c['category'],
                  currentAmount: (c['currentAmount'] as num).toDouble(),
                  suggestedAmount: (c['suggestedAmount'] as num).toDouble(),
                  saving: (c['saving'] as num).toDouble(),
                  reason: c['reason'],
                ),
              )
              .toList(),
        );
      }

      _result = AnalysisResult(
        snapshot: snapshot,
        optimizationResult: opt,
        persona: data['persona'],
        usedAi: data['usedAi'] ?? false,
      );
    } catch (e) {
      setState(() => _hasError = true);
    }
  }

  Future<void> _submitFeedback(bool approved) async {
    setState(() => _userApproval = approved);
    final goal = await DatabaseService.getGoal(widget.goal.id);
    if (goal == null) return;
    goal
      ..userApproved = approved
      ..rejectedCategories = approved
          ? []
          : (_result.optimizationResult?.cuts.map((c) => c.category).toList() ?? []);
    await DatabaseService.updateGoal(goal);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        const Positioned.fill(
          child: PrecisionBackground(useSystemBackground: false),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: _hasError
              ? _buildErrorState(l10n)
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    AnalysisSliverHeader(
                      goal: widget.goal,
                      l10n: l10n,
                      currencyFormat: _currencyFormat,
                      currencySymbol: _result.snapshot.currencySymbol,
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          AnalysisStatusSection(
                            snapshot: _result.snapshot,
                            l10n: l10n,
                            currencyFormat: _currencyFormat,
                          ),
                          const SizedBox(height: 32),
                          if (_result.optimizationResult != null) ...[
                            AnalysisOptimizationSection(
                              opt: _result.optimizationResult!,
                              l10n: l10n,
                              currencyFormat: _currencyFormat,
                              currencySymbol: _result.snapshot.currencySymbol,
                            ),
                            const SizedBox(height: 24),
                          ],
                          AnalysisFeedbackSection(
                            l10n: l10n,
                            userApproval: _userApproval,
                            onSubmitFeedback: _submitFeedback,
                          ),
                          const SizedBox(height: 60),
                        ]),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildErrorState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: AppColors.getError(context).withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.error.toUpperCase(),
            style: TextStyle(
              color: AppColors.getError(context),
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Bu analize ait veri bulunamadı veya bozulmuş.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.getTextSecondary(context)),
            ),
          ),
        ],
      ),
    );
  }
}
