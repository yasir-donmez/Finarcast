import 'package:flutter/material.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/precision_action.dart';
import '../../../shared/widgets/precision_toggle.dart';
import '../../../shared/widgets/precision_animated_icon.dart';

class ProfileListItems {
  static Widget buildSectionTitle(String title, Color activeColor, {Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.only(left: 0, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Colors.grey.withValues(alpha: 0.5),
          letterSpacing: 2,
        ),
      ),
    );
  }

  static Widget buildSetting({
    required IconData icon,
    required String title,
    String? trailing,
    required VoidCallback onTap,
    required Color activeColor,
    required BuildContext context,
    bool isAction = false,
  }) {
    return PrecisionAction(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: activeColor.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Icon(icon, size: 22, color: activeColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.getTextPrimary(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (trailing != null) ...[
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                layoutBuilder: (currentChild, previousChildren) => Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                ),
                transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                child: Text(
                  trailing,
                  key: ValueKey(trailing),
                  style: TextStyle(
                    color: activeColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (trailing == null && !isAction)
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.getTextSecondary(context).withValues(alpha: 0.3),
              ),
            if (isAction)
              Icon(
                Icons.arrow_outward_rounded,
                color: activeColor.withValues(alpha: 0.5),
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  static Widget buildToggle({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color activeColor,
    required BuildContext context,
    IconData? activeIcon,
    IconData? inactiveIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: activeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: activeColor.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: PrecisionAnimatedIcon(
              activeIcon: activeIcon ?? icon,
              inactiveIcon: inactiveIcon ?? icon,
              isActive: value,
              color: activeColor.withValues(alpha: value ? 1.0 : 0.4),
              size: 22,
              duration: const Duration(milliseconds: 400),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.getTextPrimary(context),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          PrecisionToggle(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
            activeIcon: activeIcon,
            inactiveIcon: inactiveIcon,
          ),
        ],
      ),
    );
  }

  static Widget buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 72,
      endIndent: 20,
      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
    );
  }
}
