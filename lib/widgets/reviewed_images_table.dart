import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_dimensions.dart';
import '../models/survey_model.dart';

// Fixed column widths for the horizontally-scrollable table
const double _colPhoto  = 40;
const double _colLand   = 150;
const double _colCrop   = 110;
const double _colArea   = 80;
const double _colView   = 36;

class ReviewedImagesTable extends StatelessWidget {
  final List<SurveyImage> images;
  final void Function(int index)? onImageTap;
  final void Function(int index)? onViewTap;

  const ReviewedImagesTable({
    super.key,
    required this.images,
    this.onImageTap,
    this.onViewTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        ...images.asMap().entries.map(
              (e) => _buildRow(context, e.value, e.key,
                  isLast: e.key == images.length - 1),
            ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: context.getHeight(8)),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _colPhoto,
            child: Text('PHOTOS', style: _headerStyle(context)),
          ),
          SizedBox(
            width: context.getWidth(50),
          ),
          SizedBox(
            width: _colLand,
            child: Text('LAND USAGE ↕', style: _headerStyle(context)),
          ),
          SizedBox(
            width: _colCrop,
            child: Text('CROP /\nAREA TYPE ↕', style: _headerStyle(context)),
          ),
          SizedBox(
            width: _colArea,
            child: Text('AREA ↕',
                style: _headerStyle(context), textAlign: TextAlign.right),
          ),
          if (onViewTap != null) SizedBox(width: _colView),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    SurveyImage img,
    int index, {
    required bool isLast,
  }) {
    final canTap  = onImageTap != null;
    final canView = onViewTap  != null;

    return Container(
      padding: EdgeInsets.symmetric(vertical: context.getHeight(10)),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Thumbnail ───────────────────────────────────────────────
          SizedBox(
            width: _colPhoto,
            child: GestureDetector(
              onTap: canTap ? () => onImageTap!(index) : null,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(context.getWidth(6)),
                    child: SizedBox(
                      width: context.getWidth(40),
                      height: context.getHeight(30),
                      child: CustomPaint(
                        painter: _MiniFieldPainter(Color(img.colorHex)),
                      ),
                    ),
                  ),
                  if (canTap)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(context.getWidth(6)),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.22),
                          child: Icon(Icons.zoom_in_rounded,
                              color: Colors.white,
                              size: context.getWidth(14)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── View icon ───────────────────────────────────────────────
          if (canView)
            SizedBox(
              width: _colView,
              child: GestureDetector(
                onTap: () => onViewTap!(index),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(context.getWidth(4)),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius:
                      BorderRadius.circular(context.getWidth(6)),
                      border: Border.all(
                          color:
                          AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Icon(Icons.info_outline_rounded,
                        size: context.getWidth(14),
                        color: AppColors.primaryDark),
                  ),
                ),
              ),
            ),
          
          
          SizedBox(
            width: context.getWidth(15),
          ),

          // ── Land Usage ──────────────────────────────────────────────
          SizedBox(
            width: _colLand,
            child: Text(
              img.landUsage,
              style: TextStyle(
                fontSize: context.getFontSize(AppDimens.fontS),
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // ── Crop / Area Type ────────────────────────────────────────
          SizedBox(
            width: _colCrop,
            child: Text(
              img.cropAreaType,
              style: TextStyle(
                fontSize: context.getFontSize(AppDimens.fontS),
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // ── Area ────────────────────────────────────────────────────
          SizedBox(
            width: _colArea,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  img.area.toStringAsFixed(3),
                  style: TextStyle(
                    fontSize: context.getFontSize(AppDimens.fontS),
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  img.areaUnit,
                  style: TextStyle(
                    fontSize: context.getFontSize(AppDimens.fontXS),
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _headerStyle(BuildContext context) => TextStyle(
        fontSize: context.getFontSize(AppDimens.fontXS),
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.4,
      );
}

class _MiniFieldPainter extends CustomPainter {
  final Color base;
  _MiniFieldPainter(this.base);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = base);
    final p = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    for (double i = -size.height; i < size.width; i += 5) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}