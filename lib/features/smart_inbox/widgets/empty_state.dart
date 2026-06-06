import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/inset_container.dart';
import '../../../l10n/app_localizations.dart';

class SmartInboxEmptyState extends ConsumerStatefulWidget {
  const SmartInboxEmptyState({super.key});

  @override
  ConsumerState<SmartInboxEmptyState> createState() => _SmartInboxEmptyStateState();
}

class _SmartInboxEmptyStateState extends ConsumerState<SmartInboxEmptyState> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Kasalar sayfasındaki gibi yaylanan InsetContainer yapısı
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1200),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return InsetContainer(
                  size: 100,
                  child: Transform.scale(
                    scale: 0.4 + (0.6 * value),
                    child: Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: child,
                    ),
                  ),
                );
              },
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 40,
                color: AppColors.getTextSecondary(context).withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 24),

            // Kasalar sayfasıyla aynı sade ve şık yazı stili
            Text(
              AppLocalizations.of(context)!.inboxEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.getTextSecondary(context).withValues(alpha: 0.7),
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
