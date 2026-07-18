import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_spacing.dart';

const _switchRowHeight = 40.0;
const _fieldGap = 6.0;

class AppFormSwitchRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const AppFormSwitchRow({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: _switchRowHeight),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.compact),
      child: Row(
        children: [
          Icon(icon, size: 17, color: AppColors.textSecondary(context)),
          const SizedBox(width: _fieldGap),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            width: 38,
            height: 24,
            child: FittedBox(
              fit: BoxFit.contain,
              child: CupertinoSwitch(
                value: value,
                onChanged: onChanged,
                activeTrackColor: AppColors.primary(context),
                inactiveTrackColor: AppColors.separator(context),
                thumbColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
