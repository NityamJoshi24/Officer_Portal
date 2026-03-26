import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_dimensions.dart';

// ── Column definition ─────────────────────────────────────────────────────────
class _Col {
  final String header;
  final double width;
  const _Col(this.header, this.width);
}

const List<_Col> _columns = [
  _Col('Photo',                110),
  _Col('Land Usage',           110),
  _Col('Crop / Area Type',     130),
  _Col('Area',                  90),
  _Col('Crop Sowing Date',     130),
  _Col('Crop Status',          110),
  _Col('Crop Class Name',      120),
  _Col('Source of Irrigation', 150),
  _Col('Remarks',              160),
];

// ── Data model passed in from parent ─────────────────────────────────────────
class ReviewedImageRow {
  /// URL / asset path for the thumbnail.  Pass empty string for placeholder.
  final String imageUrl;
  final String landUsage;
  final String cropAreaType;
  final String area;
  final String cropSowingDate;
  final String cropStatus;
  final String cropClassName;
  final String irrigationSource;
  final String remarks;

  const ReviewedImageRow({
    required this.imageUrl,
    required this.landUsage,
    required this.cropAreaType,
    required this.area,
    required this.cropSowingDate,
    required this.cropStatus,
    required this.cropClassName,
    required this.irrigationSource,
    required this.remarks,
  });
}

// ── Public widget ─────────────────────────────────────────────────────────────
class ReviewedImagesTable extends StatelessWidget {
  /// One row per reviewed-image entry.
  final List<ReviewedImageRow> rows;

  /// Called when the user taps the thumbnail.
  final void Function(int index) onImageTap;

  /// Called when the user taps the view (eye) icon in the photo cell.
  final void Function(int index) onViewTap;

  const ReviewedImagesTable({
    super.key,
    required this.rows,
    required this.onImageTap,
    required this.onViewTap,
  });

  // ── helpers ─────────────────────────────────────────────────────────────────
  Color? _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'standing':  return AppColors.approved;
      case 'harvested': return AppColors.primaryDark;
      case 'damaged':   return AppColors.rejected;
      case 'not sown':  return AppColors.textMuted;
      default:          return null;
    }
  }

  static const List<Color> _thumbBg = [
    Color(0xFFD6E8D0),
    Color(0xFFD0DFF5),
    Color(0xFFF5E6D0),
    Color(0xFFE8D0F5),
    Color(0xFFD0F0F5),
  ];

  // ── build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      border: TableBorder(
        horizontalInside: BorderSide(color: AppColors.divider, width: 1),
        bottom:           BorderSide(color: AppColors.divider, width: 1),
        top:              BorderSide(color: AppColors.divider, width: 1),
        left:             BorderSide(color: AppColors.divider, width: 1),
        right:            BorderSide(color: AppColors.divider, width: 1),
        verticalInside:   BorderSide(color: AppColors.divider, width: 1),
      ),
      children: [
        _headerRow(context),
        ...List.generate(rows.length, (i) => _dataRow(context, i)),
      ],
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────
  TableRow _headerRow(BuildContext context) {
    return TableRow(
      decoration: const BoxDecoration(color: AppColors.background),
      children: _columns.map((col) {
        return _cell(
          width: col.width,
          child: Text(
            col.header,
            style: TextStyle(
              fontSize:   context.getFontSize(AppDimens.fontXS),
              fontWeight: FontWeight.w700,
              color:      AppColors.textSecondary,
              letterSpacing: 0.2,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Data row ─────────────────────────────────────────────────────────────────
  TableRow _dataRow(BuildContext context, int i) {
    final row = rows[i];
    final statusColor = _statusColor(row.cropStatus);

    return TableRow(
      decoration: BoxDecoration(
        color: i.isEven ? AppColors.surface : AppColors.background,
      ),
      children: [
        // ── Photo cell (thumbnail + view icon) ──────────────────────────────
        _cell(
          width: _columns[0].width,
          vPad: 8,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thumbnail
              GestureDetector(
                onTap: () => onImageTap(i),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width:  context.getWidth(48),
                    height: context.getWidth(48),
                    color:  _thumbBg[i % _thumbBg.length],
                    child: const Icon(
                      Icons.image_outlined,
                      size: 22,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
              SizedBox(width: context.getWidth(6)),
              // View icon
              GestureDetector(
                onTap: () => onViewTap(i),
                child: Container(
                  width:  context.getWidth(28),
                  height: context.getWidth(28),
                  decoration: BoxDecoration(
                    color:        AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Icon(
                    Icons.visibility_outlined,
                    size:  context.getWidth(14),
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Text cells ───────────────────────────────────────────────────────
        _textCell(context, row.landUsage),
        _textCell(context, row.cropAreaType),
        _textCell(context, row.area),
        _textCell(context, row.cropSowingDate),

        // Crop Status — plain coloured text, same style as other cells
        _cell(
          width: _columns[5].width,
          child: Text(
            row.cropStatus,
            style: TextStyle(
              fontSize:   context.getFontSize(AppDimens.fontS),
              fontWeight: FontWeight.w600,
              color:      statusColor ?? AppColors.textPrimary,
            ),
          ),
        ),

        _textCell(context, row.cropClassName),
        _textCell(context, row.irrigationSource),
        _textCell(context, row.remarks),
      ],
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  Widget _cell({
    required double width,
    required Widget child,
    double vPad = 10,
  }) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: vPad),
        child: child,
      ),
    );
  }

  Widget _textCell(BuildContext context, String value) {
    return _cell(
      width: 0, // will be set by column width via IntrinsicColumnWidth
      child: Text(
        value,
        style: TextStyle(
          fontSize:   context.getFontSize(AppDimens.fontS),
          color:      AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}