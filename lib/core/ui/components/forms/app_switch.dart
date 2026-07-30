import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/theme/app_colors.dart';
import 'package:mochi_player/core/ui/theme/app_control_metrics.dart';

class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const AppSwitch({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppControlMetrics.switchWidth,
      height: AppControlMetrics.switchHeight,
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
    );
  }
}
