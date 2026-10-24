import 'package:disciplaner_flutter/app/theme/neo_colors.dart';
import 'package:disciplaner_flutter/app/theme/neo_spacing.dart';
import 'package:flutter/material.dart';

class DenseCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;

  const DenseCheckbox({
    super.key,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      borderRadius: NeoSpacing.roundedSm,
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: value ? NeoColors.primary : Colors.transparent,
          borderRadius: NeoSpacing.roundedSm,
          border: Border.all(
            color: value ? NeoColors.primary : NeoColors.borderWhisper,
            width: 1.5,
          ),
        ),
        child: value
            ? const Center(
                child: Icon(
                  Icons.check,
                  size: 10,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }
}
