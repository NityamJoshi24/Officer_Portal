// ─────────────────────────────────────────────────────────────────────────────
// InfoFieldPair — two-column label + value layout used in survey detail card
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../core/commons/app_colors.dart';
import '../core/commons/app_dimensions.dart';

class InfoFieldPair extends StatelessWidget {
  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;

  const InfoFieldPair({
    super.key,
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _InfoField(label: leftLabel, value: leftValue)),
        SizedBox(width: context.getWidth(12)),
        Expanded(child: _InfoField(label: rightLabel, value: rightValue)),
      ],
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final String value;

  const _InfoField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: context.getFontSize(AppDimens.fontXS),
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 0.7,
          ),
        ),
        SizedBox(height: context.getHeight(3)),
        Text(
          value,
          style: TextStyle(
            fontSize: context.getFontSize(AppDimens.fontM),
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
