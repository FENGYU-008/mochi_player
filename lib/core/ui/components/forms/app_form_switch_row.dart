import 'package:flutter/material.dart';
import 'package:mochi_player/core/ui/components/forms/app_form_row.dart';
import 'package:mochi_player/core/ui/components/forms/app_switch.dart';

class AppFormSwitchRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const AppFormSwitchRow({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppFormRow(
      icon: icon,
      label: title,
      subtitle: subtitle,
      enabled: enabled,
      labelWidth: null,
      expandControl: false,
      control: AppSwitch(value: value, onChanged: enabled ? onChanged : null),
    );
  }
}
