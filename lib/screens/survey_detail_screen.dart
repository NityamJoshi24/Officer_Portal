import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_dimensions.dart';
import '../models/survey_model.dart';
import '../widgets/survey_map_widget.dart';
import '../widgets/info_field_pair.dart';
import '../widgets/reviewed_images_table.dart';

// ── Dummy photo data ──────────────────────────────────────────────────────────
class SurveyPhoto {
  final String url;
  final String date;
  final String location;
  final String device;

  const SurveyPhoto({
    required this.url,
    required this.date,
    required this.location,
    required this.device,
  });
}

enum PhotoStatus { pending, approved, rejected }

// Each item gets all 3 dummy photos as its "multiple images"
const List<SurveyPhoto> _dummyPhotos = [
  SurveyPhoto(
    url: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800&q=80',
    date: 'Oct 24, 2023',
    location: '1.288, 38.817',
    device: 'iPhone 14',
  ),
  SurveyPhoto(
    url: 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=800&q=80',
    date: 'Oct 24, 2023',
    location: '1.289, 38.820',
    device: 'iPhone 14',
  ),
  SurveyPhoto(
    url: 'https://images.unsplash.com/photo-1595841696677-6489ff3f8cd1?w=800&q=80',
    date: 'Oct 24, 2023',
    location: '1.290, 38.825',
    device: 'iPhone 14',
  ),
];

// ── Per-item field data ───────────────────────────────────────────────────────
class _ItemFieldData {
  final String landUsage;
  final String cropAreaType;
  final String area;
  final String cropSowingDate;
  final String cropStatus;
  final String cropClassName;
  final String irrigationSource;
  final String remarks;

  const _ItemFieldData({
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

const List<_ItemFieldData> _dummyItemFields = [
  _ItemFieldData(
    landUsage: 'Agricultural',
    cropAreaType: 'Irrigated',
    area: '2.450 Ha',
    cropSowingDate: '10 Jun, 2023',
    cropStatus: 'Standing',
    cropClassName: 'Kharif',
    irrigationSource: 'Canal',
    remarks: 'No issues observed',
  ),
  _ItemFieldData(
    landUsage: 'Agricultural',
    cropAreaType: 'Rain-fed',
    area: '1.800 Ha',
    cropSowingDate: '15 Jun, 2023',
    cropStatus: 'Harvested',
    cropClassName: 'Kharif',
    irrigationSource: 'Borewell',
    remarks: 'Partial crop loss reported',
  ),
  _ItemFieldData(
    landUsage: 'Horticulture',
    cropAreaType: 'Irrigated',
    area: '3.100 Ha',
    cropSowingDate: '01 Nov, 2023',
    cropStatus: 'Standing',
    cropClassName: 'Rabi',
    irrigationSource: 'Drip Irrigation',
    remarks: '-',
  ),
  _ItemFieldData(
    landUsage: 'Agricultural',
    cropAreaType: 'Irrigated',
    area: '0.950 Ha',
    cropSowingDate: '05 Jun, 2023',
    cropStatus: 'Damaged',
    cropClassName: 'Kharif',
    irrigationSource: 'Tank/Pond',
    remarks: 'Flood damage in lower plot',
  ),
  _ItemFieldData(
    landUsage: 'Fallow',
    cropAreaType: '-',
    area: '1.200 Ha',
    cropSowingDate: '-',
    cropStatus: 'Not Sown',
    cropClassName: '-',
    irrigationSource: '-',
    remarks: 'Land left fallow this season',
  ),
];

// Rejection reasons
const List<String> _rejectionReasons = [
  'Poor image quality',
  'Incorrect boundary mapping',
  'Missing required photos',
  'Location mismatch',
  'Incomplete survey data',
  'Other',
];

// ─────────────────────────────────────────────────────────────────────────────

class SurveyDetailScreen extends StatefulWidget {
  final List<SurveyModel> surveys;
  final int initialIndex;

  const SurveyDetailScreen({
    super.key,
    required this.surveys,
    required this.initialIndex,
  });

  @override
  State<SurveyDetailScreen> createState() => _SurveyDetailScreenState();
}

class _SurveyDetailScreenState extends State<SurveyDetailScreen>
    with TickerProviderStateMixin {
  late int _idx;
  late TabController _tabController;

  int _selection = 0;

  // Change: bottom loader — visible after scrolled to end
  bool _hasScrolledToBottom = false;
  bool _showBottomLoader = false;

  // Rejection form state
  String? _selectedRejectionReason;
  final TextEditingController _remarksController = TextEditingController();

  final Map<String, List<PhotoStatus>> _photoStatuses = {};

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _idx = widget.initialIndex;
    _tabController = TabController(length: 4, vsync: this);
    _initPhotosForSurvey();
  }

  // // Change: show loader briefly when scrolled to bottom
  // void _onScroll() {
  //   if (!_scrollController.hasClients) return;
  //   final max = _scrollController.position.maxScrollExtent;
  //   final cur = _scrollController.offset;
  //   if (cur >= max - 1 && !_hasScrolledToBottom) {
  //     setState(() {
  //       _hasScrolledToBottom = true;
  //       _showBottomLoader = true;
  //     });
  //     // Auto-hide the loader after 1.2 s
  //     Future.delayed(const Duration(milliseconds: 1200), () {
  //       if (mounted) setState(() => _showBottomLoader = false);
  //     });
  //   }
  // }

  void _initPhotosForSurvey() {
    final id = _survey.id;
    if (!_photoStatuses.containsKey(id)) {
      _photoStatuses[id] =
          List.generate(_dummyPhotos.length, (_) => PhotoStatus.pending);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  SurveyModel get _survey => widget.surveys[_idx];

  List<PhotoStatus> get _currentStatuses =>
      _photoStatuses[_survey.id] ??
          List.generate(_dummyPhotos.length, (_) => PhotoStatus.pending);

  bool get _hasRejectedPhoto =>
      _currentStatuses.any((s) => s == PhotoStatus.rejected);

  bool get _isActioned =>
      _survey.status == SurveyStatus.approved ||
          _survey.status == SurveyStatus.rejected;

  void _goPrevious() {
    if (_idx > 0) {
      setState(() {
        _idx--;
        _selection = 0;
        _hasScrolledToBottom = false;
        _showBottomLoader = false;
        _selectedRejectionReason = null;
        _remarksController.clear();
        _tabController.index = 0;
        _initPhotosForSurvey();
      });
    }
  }

  void _goNext() {
    if (_idx < widget.surveys.length - 1) {
      setState(() {
        _idx++;
        _selection = 0;
        _hasScrolledToBottom = false;
        _showBottomLoader = false;
        _selectedRejectionReason = null;
        _remarksController.clear();
        _tabController.index = 0;
        _initPhotosForSurvey();
      });
    }
  }

  void _submit() {
    if (_selection == 0) {
      _showSnack(
          'Please select Approve or Reject before submitting.', AppColors.pending);
      return;
    }
    if (_selection == 1 && _hasRejectedPhoto) {
      _showSnack(
          'Cannot approve: one or more survey photos have been rejected.',
          AppColors.rejected);
      return;
    }
    if (_selection == 2 && _selectedRejectionReason == null) {
      _showSnack('Please select a reason for rejection.', AppColors.rejected);
      return;
    }

    final approve = _selection == 1;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.getWidth(16)),
        ),
        title: Text(
          approve ? 'Approve Survey?' : 'Reject Survey?',
          style: TextStyle(
            color: approve ? AppColors.approved : AppColors.rejected,
            fontWeight: FontWeight.w700,
            fontSize: context.getFontSize(AppDimens.fontL),
          ),
        ),
        content: Text(
          approve
              ? 'Survey ${_survey.surveyNo} will be marked as approved.'
              : 'Survey ${_survey.surveyNo} will be rejected and sent for re-verification.\n\nReason: $_selectedRejectionReason',
          style: TextStyle(
            fontSize: context.getFontSize(AppDimens.fontM),
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: context.getFontSize(AppDimens.fontM))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _survey.status =
                approve ? SurveyStatus.approved : SurveyStatus.rejected;
              });
              if (_idx < widget.surveys.length - 1) {
                Future.delayed(const Duration(milliseconds: 400), _goNext);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
              approve ? AppColors.approved : AppColors.rejected,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.getWidth(8))),
            ),
            child: Text(approve ? 'Approve' : 'Reject',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: context.getFontSize(AppDimens.fontM))),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(context.getWidth(16)),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.getWidth(10))),
    ));
  }

  void _cancel() => setState(() {
    _selection = 0;
    _selectedRejectionReason = null;
    _remarksController.clear();
  });

  String _fmt(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour < 12 ? 'AM' : 'PM';
    return '$d/$mo/${dt.year} $h:$mi $ap';
  }

  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildSequenceNav(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildFirstSurveyTab(),
                  _buildEmptyTab('2nd Survey', Icons.image_search_rounded),
                  _buildEmptyTab('Verification Survey', Icons.verified_outlined),
                  _buildEmptyTab(
                      'Inspection Officer Review', Icons.reviews_outlined),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(context.getWidth(4), context.getHeight(6),
          context.getWidth(12), context.getHeight(6)),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
                size: context.getWidth(AppDimens.iconL)),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('SURVEYOR TASK MANAGEMENT',
                    style: TextStyle(
                        fontSize: context.getFontSize(9),
                        color: AppColors.textMuted,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w600)),
                Text('Review Survey Details',
                    style: TextStyle(
                        fontSize: context.getFontSize(AppDimens.fontL),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showOwnersSheet,
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: context.getWidth(12),
                  vertical: context.getHeight(7)),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(context.getWidth(8)),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Text('View Owners',
                  style: TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: context.getFontSize(AppDimens.fontS),
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSequenceNav() {
    final canPrev = _idx > 0;
    final canNext = _idx < widget.surveys.length - 1;
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(
          horizontal: context.getWidth(AppDimens.spaceM),
          vertical: context.getHeight(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navBtn(
              label: 'Previous',
              icon: Icons.chevron_left_rounded,
              leading: true,
              enabled: canPrev,
              onTap: _goPrevious),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('SURVEY SEQUENCE',
                  style: TextStyle(
                      fontSize: context.getFontSize(AppDimens.fontXS),
                      color: AppColors.textMuted,
                      letterSpacing: 0.7,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: context.getHeight(2)),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                      fontSize: context.getFontSize(13),
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500),
                  children: [
                    TextSpan(
                        text: '${_idx + 1}',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: context.getFontSize(15),
                            color: AppColors.textPrimary)),
                    const TextSpan(text: ' of '),
                    TextSpan(text: '${_survey.totalSequence}'),
                  ],
                ),
              ),
            ],
          ),
          _navBtn(
              label: 'Next',
              icon: Icons.chevron_right_rounded,
              leading: false,
              enabled: canNext,
              onTap: _goNext),
        ],
      ),
    );
  }

  Widget _navBtn({
    required String label,
    required IconData icon,
    required bool leading,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final color = enabled ? AppColors.primaryDark : AppColors.textMuted;
    final iconW = Icon(icon, size: context.getWidth(18), color: color);
    final labelW = Text(label,
        style: TextStyle(
            fontSize: context.getFontSize(AppDimens.fontS),
            color: color,
            fontWeight: FontWeight.w600));
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: leading ? [iconW, labelW] : [labelW, iconW],
      ),
    );
  }

  // Widget _buildWarningBanner() {
  //   return Container(
  //     width: double.infinity,
  //     color: AppColors.pendingBg,
  //     padding: EdgeInsets.symmetric(
  //         horizontal: context.getWidth(14), vertical: context.getHeight(8)),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Icon(Icons.info_outline_rounded,
  //             size: context.getWidth(14), color: AppColors.pending),
  //         SizedBox(width: context.getWidth(6)),
  //         // Expanded(
  //         //   child: RichText(
  //         //     text: TextSpan(
  //         //       style: TextStyle(
  //         //           fontSize: context.getFontSize(AppDimens.fontXS + 1),
  //         //           color: const Color(0xFFB45309),
  //         //           fontWeight: FontWeight.w500),
  //         //       children: const [
  //         //         TextSpan(
  //         //             text: 'Important Reminder: ',
  //         //             style: TextStyle(fontWeight: FontWeight.w700)),
  //         //         TextSpan(
  //         //             text:
  //         //             'Before giving final approval or rejection of a survey, '
  //         //                 'please review all the surveyed images carefully.'),
  //         //       ],
  //         //     ),
  //         //   ),
  //         // ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.surface,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryDark,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 2.5,
        isScrollable: false,
        labelPadding:
        EdgeInsets.symmetric(horizontal: context.getWidth(4)),
        labelStyle: TextStyle(
            fontSize: context.getFontSize(AppDimens.fontS),
            fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(
            fontSize: context.getFontSize(AppDimens.fontS),
            fontWeight: FontWeight.w500),
        tabs: const [
          Tab(text: '1st Survey'),
          Tab(text: '2nd Survey'),
          Tab(text: 'Verification'),
          Tab(text: 'IO Review'),
        ],
      ),
    );
  }

  Widget _buildFirstSurveyTab() {
    final s = _survey;
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.all(context.getWidth(AppDimens.spaceM)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Survey Details',
              style: TextStyle(
                  fontSize: context.getFontSize(AppDimens.fontXL),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          SizedBox(height: context.getHeight(12)),
          SurveyMapWidget(
              coordinateLabel: s.mapCoordinateLabel,
              isActual: s.status == SurveyStatus.pending),
          SizedBox(height: context.getHeight(16)),
          _buildInfoCard(s),
          SizedBox(height: context.getHeight(14)),
          _buildReviewedImagesCard(s),
          SizedBox(height: context.getHeight(16)),
          _buildBottomBar(),
          SizedBox(height: context.getHeight(8)),
          // Change: bottom loader — shown briefly after scrolling to end
          if (_showBottomLoader)
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.getHeight(12)),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: context.getWidth(18),
                      height: context.getWidth(18),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: context.getWidth(8)),
                    Text(
                      'Loading more details…',
                      style: TextStyle(
                        fontSize: context.getFontSize(AppDimens.fontS),
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(SurveyModel s) {
    return _card(
      child: Column(
        children: [
          InfoFieldPair(
              leftLabel: 'Owner Name',
              leftValue: s.ownerName,
              rightLabel: 'Taluka',
              rightValue: s.taluka),
          _divider(),
          InfoFieldPair(
              leftLabel: 'Village',
              leftValue: s.village,
              rightLabel: 'Survey No.',
              rightValue: s.surveyNo),
          _divider(),
          InfoFieldPair(
              leftLabel: 'Farmland Plot ID',
              leftValue: s.farmlandPlotId,
              rightLabel: 'Farmer Total Area',
              rightValue: '${s.farmerTotalArea.toStringAsFixed(3)} -'),
          _divider(),
          InfoFieldPair(
              leftLabel: 'Farm Allocation',
              leftValue: _fmt(s.farmAllocation),
              rightLabel: 'Surveyor Name',
              rightValue: s.surveyorName),
          _divider(),
          InfoFieldPair(
              leftLabel: 'Survey Date',
              leftValue: _fmt(s.surveyDate),
              rightLabel: 'Submission Date',
              rightValue: _fmt(s.submissionDate)),
          _divider(),
          InfoFieldPair(
              leftLabel: 'Latitude',
              leftValue: s.latitude.toStringAsFixed(6),
              rightLabel: 'Longitude',
              rightValue: s.longitude.toStringAsFixed(5)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
// PASTE THIS HELPER inside _SurveyDetailScreenState
// (replaces / adds beside _buildReviewedImagesCard)
// ─────────────────────────────────────────────────────────────────────────────

/// Converts the survey's reviewedImages list into ReviewedImageRow objects
/// so the table has real field data per row.
List<ReviewedImageRow> _buildTableRows(SurveyModel s) {
  return List.generate(s.reviewedImages.length, (i) {
    final f = _dummyItemFields[i % _dummyItemFields.length];
    final photo = _dummyPhotos[i % _dummyPhotos.length];
    return ReviewedImageRow(
      imageUrl:         photo.url,
      landUsage:        f.landUsage,
      cropAreaType:     f.cropAreaType,
      area:             f.area,
      cropSowingDate:   f.cropSowingDate,
      cropStatus:       f.cropStatus,
      cropClassName:    f.cropClassName,
      irrigationSource: f.irrigationSource,
      remarks:          f.remarks,
    );
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// REPLACE the existing _buildReviewedImagesCard with this version
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildReviewedImagesCard(SurveyModel s) {
  final totalCount = s.reviewedImages.length;
  final rows       = _buildTableRows(s);

  return _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header row ──────────────────────────────────────────────────────
        Row(
          children: [
            Text(
              'Total Reviewed Images',
              style: TextStyle(
                fontSize:   context.getFontSize(AppDimens.fontM),
                fontWeight: FontWeight.w700,
                color:      AppColors.textPrimary,
              ),
            ),
            SizedBox(width: context.getWidth(6)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.getWidth(7),
                vertical:   context.getHeight(2),
              ),
              decoration: BoxDecoration(
                color:        AppColors.primary,
                borderRadius: BorderRadius.circular(
                    context.getWidth(AppDimens.radiusFull)),
              ),
              child: Text(
                '$totalCount/$totalCount',
                style: TextStyle(
                  color:      Colors.white,
                  fontSize:   context.getFontSize(AppDimens.fontXS),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(width: context.getWidth(4)),
            Icon(Icons.info_outline_rounded,
                size: context.getWidth(14), color: AppColors.textMuted),
          ],
        ),

        SizedBox(height: context.getHeight(4)),

        Text(
          'Tap the view icon (👁) to inspect image details  •  Tap thumbnail for fullscreen',
          style: TextStyle(
            fontSize:   context.getFontSize(AppDimens.fontXS),
            color:      AppColors.textMuted,
            fontStyle:  FontStyle.italic,
          ),
        ),

        SizedBox(height: context.getHeight(12)),

        // ── Horizontally scrollable table ───────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(context.getWidth(AppDimens.radiusS)),
            child: ReviewedImagesTable(
              rows:        rows,
              onImageTap:  _openFullscreen,
              onViewTap:   (index) => _openImageDetailViewer(s, index),
            ),
          ),
        ),
      ],
    ),
  );
}

  // Single photo, no swipe
  void _openFullscreen(int startIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _FullscreenPhotoViewer(
          photos: [_dummyPhotos[startIndex % _dummyPhotos.length]],
          initialIndex: 0,
          photoStatuses: [
            _currentStatuses[startIndex % _currentStatuses.length]
          ],
          onStatusChanged: (_, status) {
            final id = _survey.id;
            final list = List<PhotoStatus>.from(_currentStatuses);
            list[startIndex % list.length] = status;
            setState(() => _photoStatuses[id] = list);
          },
        ),
      ),
    );
  }

  // Opens Image Details bottom sheet starting at tapped item
  void _openImageDetailViewer(SurveyModel s, int startIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ImageDetailViewer(
        survey: s,
        initialIndex: startIndex,
        photosPerItem: _dummyPhotos,
        photoStatuses: _currentStatuses,
        onStatusChanged: (itemIdx, photoIdx, status) {
          final id = _survey.id;
          final list = List<PhotoStatus>.from(_currentStatuses);
          list[photoIdx] = status;
          setState(() => _photoStatuses[id] = list);
        },
      ),
    );
  }

  Widget _buildEmptyTab(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: context.getWidth(52), color: AppColors.divider),
          SizedBox(height: context.getHeight(16)),
          Text('No $title Data',
              style: TextStyle(
                  fontSize: context.getFontSize(AppDimens.fontL),
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: context.getHeight(6)),
          Text('Data has not been submitted yet.',
              style: TextStyle(
                  fontSize: context.getFontSize(AppDimens.fontS),
                  color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(context.getWidth(14), context.getHeight(12),
          context.getWidth(14), context.getHeight(16)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.getWidth(AppDimens.radiusM)),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 10,
              offset: Offset(0, -3))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_hasRejectedPhoto && !_isActioned)
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: context.getHeight(8)),
              padding: EdgeInsets.symmetric(
                  horizontal: context.getWidth(12),
                  vertical: context.getHeight(7)),
              decoration: BoxDecoration(
                color: AppColors.rejectedBg,
                borderRadius: BorderRadius.circular(context.getWidth(8)),
                border: Border.all(
                    color: AppColors.rejected.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.block_rounded,
                      color: AppColors.rejected,
                      size: context.getWidth(14)),
                  SizedBox(width: context.getWidth(6)),
                  Expanded(
                    child: Text(
                      'Survey approval is blocked: one or more photos were rejected.',
                      style: TextStyle(
                          color: AppColors.rejected,
                          fontSize:
                          context.getFontSize(AppDimens.fontXS + 1),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

          if (_isActioned)
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: context.getHeight(10)),
              padding: EdgeInsets.symmetric(vertical: context.getHeight(9)),
              decoration: BoxDecoration(
                color: _survey.status == SurveyStatus.approved
                    ? AppColors.approvedBg
                    : AppColors.rejectedBg,
                borderRadius: BorderRadius.circular(context.getWidth(8)),
                border: Border.all(
                  color: _survey.status == SurveyStatus.approved
                      ? AppColors.approved
                      : AppColors.rejected,
                ),
              ),
              child: Text(
                _survey.status == SurveyStatus.approved
                    ? '✓  Survey Approved'
                    : '✕  Rejected & Sent for Reverification',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _survey.status == SurveyStatus.approved
                        ? AppColors.approved
                        : AppColors.rejected,
                    fontWeight: FontWeight.w700,
                    fontSize: context.getFontSize(AppDimens.fontM)),
              ),
            ),

          if (!_isActioned) ...[
            Row(
              children: [
                _radioOption(
                    value: 1,
                    label: 'Approve',
                    activeColor: AppColors.approved,
                    disabled: _hasRejectedPhoto),
                SizedBox(width: context.getWidth(8)),
                _radioOption(
                    value: 2,
                    label: 'Reject & send for Reverification',
                    activeColor: AppColors.rejected,
                    disabled: false),
              ],
            ),

            // Rejection form — visible only when Reject is selected
            if (_selection == 2) ...[
              SizedBox(height: context.getHeight(12)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                    horizontal: context.getWidth(12),
                    vertical: context.getHeight(2)),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(context.getWidth(8)),
                  border: Border.all(
                      color: _selectedRejectionReason == null
                          ? AppColors.rejected.withValues(alpha: 0.5)
                          : AppColors.divider),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedRejectionReason,
                    hint: Text(
                      'Select reason for rejection *',
                      style: TextStyle(
                          fontSize: context.getFontSize(AppDimens.fontS),
                          color: AppColors.textMuted),
                    ),
                    items: _rejectionReasons
                        .map((r) => DropdownMenuItem(
                      value: r,
                      child: Text(r,
                          style: TextStyle(
                              fontSize: context
                                  .getFontSize(AppDimens.fontS),
                              color: AppColors.textPrimary)),
                    ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedRejectionReason = v),
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textMuted),
                    dropdownColor: AppColors.surface,
                  ),
                ),
              ),
              SizedBox(height: context.getHeight(8)),
              TextField(
                controller: _remarksController,
                maxLines: 3,
                style: TextStyle(
                    fontSize: context.getFontSize(AppDimens.fontS),
                    color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Add remarks (optional)',
                  hintStyle: TextStyle(
                      fontSize: context.getFontSize(AppDimens.fontS),
                      color: AppColors.textMuted),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: context.getWidth(12),
                      vertical: context.getHeight(10)),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(context.getWidth(8)),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(context.getWidth(8)),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(context.getWidth(8)),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ],

            SizedBox(height: context.getHeight(10)),
          ],

          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: context.getHeight(44),
                  child: OutlinedButton(
                    onPressed: _isActioned ? null : _cancel,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.divider),
                      backgroundColor: AppColors.surfaceMuted,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              context.getWidth(AppDimens.radiusS))),
                    ),
                    child: Text('Cancel',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize:
                            context.getFontSize(AppDimens.fontM))),
                  ),
                ),
              ),
              SizedBox(width: context.getWidth(10)),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: context.getHeight(44),
                  child: ElevatedButton(
                    onPressed: _isActioned ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.4),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              context.getWidth(AppDimens.radiusS))),
                    ),
                    child: Text('Submit Selection',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize:
                            context.getFontSize(AppDimens.fontM))),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _radioOption({
    required int value,
    required String label,
    required Color activeColor,
    required bool disabled,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: disabled ? null : () => setState(() => _selection = value),
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: disabled ? 0.4 : 1.0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: context.getWidth(20),
                height: context.getWidth(20),
                child: Radio<int>(
                  value: value,
                  groupValue: _selection,
                  onChanged: disabled
                      ? null
                      : (v) => setState(() => _selection = v!),
                  activeColor: activeColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              SizedBox(width: context.getWidth(4)),
              Flexible(
                child: Text(label,
                    style: TextStyle(
                        fontSize: context.getFontSize(AppDimens.fontS),
                        fontWeight: FontWeight.w600,
                        color: (_selection == value && !disabled)
                            ? AppColors.textPrimary
                            : AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.getWidth(14)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        BorderRadius.circular(context.getWidth(AppDimens.radiusM)),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: Offset(0, 3))
        ],
      ),
      child: child,
    );
  }

  Widget _divider() => Padding(
    padding: EdgeInsets.symmetric(vertical: context.getHeight(10)),
    child: const Divider(height: 1, color: AppColors.divider),
  );

  void _showOwnersSheet() {
    final s = _survey;
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(context.getWidth(AppDimens.radiusL))),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.all(context.getWidth(AppDimens.spaceM)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: context.getWidth(36),
                height: context.getHeight(4),
                decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            SizedBox(height: context.getHeight(14)),
            Text('Survey Owners',
                style: TextStyle(
                    fontSize: context.getFontSize(AppDimens.fontXL),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            SizedBox(height: context.getHeight(16)),
            _ownerTile(
                ctx, 'Primary Owner', s.ownerName, Icons.person_rounded),
            Divider(color: AppColors.divider, height: context.getHeight(1)),
            _ownerTile(
                ctx, 'Surveyor', s.surveyorName, Icons.engineering_rounded),
            Divider(color: AppColors.divider, height: context.getHeight(1)),
            _ownerTile(ctx, 'Region', '${s.village}, ${s.taluka}',
                Icons.location_on_rounded),
            SizedBox(height: context.getHeight(20)),
          ],
        ),
      ),
    );
  }

  Widget _ownerTile(
      BuildContext ctx, String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.getHeight(10)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.getWidth(8)),
            decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(context.getWidth(8))),
            child: Icon(icon,
                color: AppColors.primaryDark,
                size: context.getWidth(AppDimens.iconM)),
          ),
          SizedBox(width: context.getWidth(12)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: context.getFontSize(AppDimens.fontXS),
                      color: AppColors.textMuted)),
              Text(value,
                  style: TextStyle(
                      fontSize: context.getFontSize(AppDimens.fontM),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Image Detail Viewer (Bottom Sheet)
// ─────────────────────────────────────────────────────────────────────────────
class _ImageDetailViewer extends StatefulWidget {
  final SurveyModel survey;
  final int initialIndex;
  final List<SurveyPhoto> photosPerItem;
  final List<PhotoStatus> photoStatuses;
  final void Function(int itemIdx, int photoIdx, PhotoStatus status)
  onStatusChanged;

  const _ImageDetailViewer({
    required this.survey,
    required this.initialIndex,
    required this.photosPerItem,
    required this.photoStatuses,
    required this.onStatusChanged,
  });

  @override
  State<_ImageDetailViewer> createState() => _ImageDetailViewerState();
}

class _ImageDetailViewerState extends State<_ImageDetailViewer> {
  late PageController _itemPageController;
  late int _currentItem;
  late List<int> _imageIndexPerItem;

  static const List<Color> _placeholderColors = [
    Color(0xFFD6E8D0),
    Color(0xFFD0DFF5),
    Color(0xFFF5E6D0),
    Color(0xFFE8D0F5),
    Color(0xFFD0F0F5),
  ];

  @override
  void initState() {
    super.initState();
    _currentItem = widget.initialIndex;
    _itemPageController = PageController(initialPage: _currentItem);
    _imageIndexPerItem =
        List.filled(widget.survey.reviewedImages.length, 0);
  }

  @override
  void dispose() {
    _itemPageController.dispose();
    super.dispose();
  }

  _ItemFieldData _fieldsForItem(int idx) =>
      _dummyItemFields[idx % _dummyItemFields.length];

  Color? _cropStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'standing':
        return AppColors.approved;
      case 'harvested':
        return AppColors.primaryDark;
      case 'damaged':
        return AppColors.rejected;
      case 'not sown':
        return AppColors.textMuted;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.survey.reviewedImages.length;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.getWidth(AppDimens.radiusL)),
        ),
      ),
      child: Column(
        children: [
          // Handle + header
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.getWidth(AppDimens.spaceM),
              context.getHeight(12),
              context.getWidth(AppDimens.spaceM),
              0,
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: context.getWidth(36),
                    height: context.getHeight(4),
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: context.getHeight(14)),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Image Details',
                            style: TextStyle(
                              fontSize:
                              context.getFontSize(AppDimens.fontXL),
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: context.getHeight(2)),
                          Text(
                            // Change: image swiping not allowed — updated hint text
                            'Swipe page ↔ to navigate between items',
                            style: TextStyle(
                              fontSize: context.getFontSize(AppDimens.fontS),
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.getWidth(10),
                        vertical: context.getHeight(5),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(
                          context.getWidth(AppDimens.radiusFull),
                        ),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '${_currentItem + 1} / $total',
                        style: TextStyle(
                          fontSize: context.getFontSize(AppDimens.fontS),
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: context.getWidth(8)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: context.getWidth(32),
                        height: context.getWidth(32),
                        decoration: BoxDecoration(
                          color: AppColors.iconBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: context.getWidth(16),
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: context.getHeight(12)),
          Divider(color: AppColors.divider, height: 1),

          // Outer PageView: swipe to navigate items
          Expanded(
            child: PageView.builder(
              controller: _itemPageController,
              scrollDirection: Axis.horizontal,
              itemCount: total,
              onPageChanged: (i) => setState(() => _currentItem = i),
              itemBuilder: (ctx, itemIdx) {
                final currentImageIdx = _imageIndexPerItem[itemIdx];
                final photos = widget.photosPerItem;
                final photoCount = photos.length;
                final fields = _fieldsForItem(itemIdx);

                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.all(
                      context.getWidth(AppDimens.spaceM)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.getWidth(8),
                          vertical: context.getHeight(3),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          borderRadius: BorderRadius.circular(
                              context.getWidth(AppDimens.radiusFull)),
                        ),
                        child: Text(
                          'ITEM ${itemIdx + 1} OF $total',
                          style: TextStyle(
                            fontSize: context
                                .getFontSize(AppDimens.fontXS),
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      SizedBox(height: context.getHeight(12)),

                      // Change: image swiping NOT allowed — static image display
                      // using an IndexedStack + manual prev/next arrows instead of a swipeable PageView
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                                context.getWidth(AppDimens.radiusM)),
                            child: SizedBox(
                              height: context.getHeight(200),
                              width: double.infinity,
                              // Static placeholder — no PageView swipe
                              child: SizedBox(
                                height: context.getHeight(200),
                                width: double.infinity,
                                child: PageView.builder(
                                  itemCount: photoCount,
                                  controller: PageController(initialPage: currentImageIdx),
                                  onPageChanged: (index) {
                                    setState(() {
                                      _imageIndexPerItem[itemIdx] = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return Container(
                                      color: _placeholderColors[
                                      (itemIdx + index) % _placeholderColors.length],
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => _FullscreenPhotoViewer(
                                                photos: [photos[index]],
                                                initialIndex: 0,
                                                photoStatuses: [
                                                  widget.photoStatuses[index]
                                                ],
                                                onStatusChanged: (i, status) {
                                                  widget.onStatusChanged(itemIdx, index, status);
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                        behavior: HitTestBehavior.opaque,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.image_outlined,
                                              size: context.getWidth(40),
                                              color: AppColors.textMuted,
                                            ),
                                            SizedBox(height: context.getHeight(8)),
                                            Text(
                                              'Photo ${index + 1} of $photoCount',
                                              style: TextStyle(
                                                fontSize: context.getFontSize(AppDimens.fontM),
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          // Left arrow — navigate photos via buttons, NOT swipe
                          if (currentImageIdx > 0)
                            Positioned(
                              left: context.getWidth(6),
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _imageIndexPerItem[itemIdx] =
                                        currentImageIdx - 1;
                                  }),
                                  child: Container(
                                    width: context.getWidth(28),
                                    height: context.getWidth(28),
                                    decoration: BoxDecoration(
                                      color: Colors.black
                                          .withValues(alpha: 0.35),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.chevron_left_rounded,
                                      color: Colors.white,
                                      size: context.getWidth(18),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Right arrow
                          if (currentImageIdx < photoCount - 1)
                            Positioned(
                              right: context.getWidth(6),
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _imageIndexPerItem[itemIdx] =
                                        currentImageIdx + 1;
                                  }),
                                  child: Container(
                                    width: context.getWidth(28),
                                    height: context.getWidth(28),
                                    decoration: BoxDecoration(
                                      color: Colors.black
                                          .withValues(alpha: 0.35),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.chevron_right_rounded,
                                      color: Colors.white,
                                      size: context.getWidth(18),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Dot indicators (still useful as position indicator)
                          if (photoCount > 1)
                            Positioned(
                              bottom: context.getHeight(8),
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: List.generate(
                                  photoCount,
                                      (i) => AnimatedContainer(
                                    duration: const Duration(
                                        milliseconds: 200),
                                    margin: EdgeInsets.symmetric(
                                        horizontal:
                                        context.getWidth(3)),
                                    width: context.getWidth(
                                        currentImageIdx == i ? 16 : 6),
                                    height: context.getWidth(6),
                                    decoration: BoxDecoration(
                                      color: currentImageIdx == i
                                          ? Colors.white
                                          : Colors.white
                                          .withValues(alpha: 0.5),
                                      borderRadius:
                                      BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: context.getHeight(16)),

                      // Field data card
                      _detailCard(
                        children: [
                          _detailRow(
                            icon: Icons.landscape_outlined,
                            label: 'Land Usage',
                            value: fields.landUsage,
                          ),
                          _detailDivider(),
                          _detailRow(
                            icon: Icons.crop_square_rounded,
                            label: 'Crop / Area Type',
                            value: fields.cropAreaType,
                          ),
                          _detailDivider(),
                          _detailRow(
                            icon: Icons.straighten_rounded,
                            label: 'Area',
                            value: fields.area,
                          ),
                          _detailDivider(),
                          _detailRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Crop Sowing Date',
                            value: fields.cropSowingDate,
                          ),
                          _detailDivider(),
                          _detailRow(
                            icon: Icons.grass_rounded,
                            label: 'Crop Status',
                            value: fields.cropStatus,
                            valueColor:
                            _cropStatusColor(fields.cropStatus),
                          ),
                          _detailDivider(),
                          _detailRow(
                            icon: Icons.category_outlined,
                            label: 'Crop Class Name',
                            value: fields.cropClassName,
                          ),
                          _detailDivider(),
                          _detailRow(
                            icon: Icons.water_drop_outlined,
                            label: 'Source of Irrigation',
                            value: fields.irrigationSource,
                          ),
                          _detailDivider(),
                          _detailRow(
                            icon: Icons.notes_rounded,
                            label: 'Remarks',
                            value: fields.remarks,
                          ),
                        ],
                      ),

                      SizedBox(height: context.getHeight(16)),
                    ],
                  ),
                );
              },
            ),
          ),

          // Item-level dot indicators
          if (total > 1)
            Padding(
              padding:
              EdgeInsets.symmetric(vertical: context.getHeight(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  total,
                      (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.symmetric(
                        horizontal: context.getWidth(3)),
                    width:
                    context.getWidth(_currentItem == i ? 18 : 6),
                    height: context.getWidth(6),
                    decoration: BoxDecoration(
                      color: _currentItem == i
                          ? AppColors.primary
                          : AppColors.divider,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _detailCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(
            context.getWidth(AppDimens.radiusM)),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(children: children),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.getWidth(14),
        vertical: context.getHeight(12),
      ),
      child:Row(
        children: [
          Icon(icon,
              size: context.getWidth(16), color: AppColors.textMuted),
          SizedBox(width: context.getWidth(10)),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: context.getFontSize(AppDimens.fontS),
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: context.getWidth(12)), // 👈 spacing fix
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: context.getFontSize(AppDimens.fontS),
                      color: valueColor ?? AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailDivider() =>
      const Divider(height: 1, color: AppColors.divider);
}

// ─────────────────────────────────────────────────────────────────────────────
// Fullscreen Photo Viewer
// Single photo — no swipe navigation
// ─────────────────────────────────────────────────────────────────────────────
class _FullscreenPhotoViewer extends StatefulWidget {
  final List<SurveyPhoto> photos;
  final int initialIndex;
  final List<PhotoStatus> photoStatuses;
  final void Function(int index, PhotoStatus status) onStatusChanged;

  const _FullscreenPhotoViewer({
    required this.photos,
    required this.initialIndex,
    required this.photoStatuses,
    required this.onStatusChanged,
  });

  @override
  State<_FullscreenPhotoViewer> createState() =>
      _FullscreenPhotoViewerState();
}

class _FullscreenPhotoViewerState
    extends State<_FullscreenPhotoViewer> {
  late List<PhotoStatus> _statuses;

  int _currentIndex = 0;

  /// 🔥 3 Dummy Images (colors for now)
  final List<Color> _dummyImages = [
    Colors.red,
    Colors.green,
    Colors.blue,
  ];

  @override
  void initState() {
    super.initState();
    _statuses = List<PhotoStatus>.from(widget.photoStatuses);
    _currentIndex = widget.initialIndex;
  }

  void _toggleStatus(PhotoStatus s) {
    final idx = _currentIndex % _statuses.length;

    final next =
    _statuses[idx] == s ? PhotoStatus.pending : s;

    setState(() => _statuses[idx] = next);

    widget.onStatusChanged(idx, next);
  }

  @override
  Widget build(BuildContext context) {
    final photo =
    widget.photos[_currentIndex % widget.photos.length];

    final status =
    _statuses[_currentIndex % _statuses.length];

    final isApproved = status == PhotoStatus.approved;
    final isRejected = status == PhotoStatus.rejected;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// 📸 IMAGE VIEW (DUMMY)
          Positioned.fill(
            top: MediaQuery.of(context).padding.top + 70,   // below top bar
            bottom: MediaQuery.of(context).padding.bottom + 140, // above buttons
            child: Container(
              color: Colors.black,
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Container(
                  color: _dummyImages[_currentIndex],
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.image_outlined,
                            size: 64, color: Colors.white24),
                        const SizedBox(height: 12),
                        Text(
                          'Image ${_currentIndex + 1} of 3',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// ⬅️ LEFT BUTTON (same style)
          if (_currentIndex > 0)
            Positioned(
              left: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _currentIndex--);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_left,
                        color: Colors.white, size: 22),
                  ),
                ),
              ),
            ),

          /// ➡️ RIGHT BUTTON (same style)
          if (_currentIndex < 2)
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _currentIndex++);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_right,
                        color: Colors.white, size: 22),
                  ),
                ),
              ),
            ),

          /// 🔝 TOP BAR (UNCHANGED)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withValues(alpha: 0.6),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                bottom: 12,
                left: 8,
                right: 16,
              ),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.approved,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'REVIEW IMAGE',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 26),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),

          /// 🔽 BOTTOM ACTIONS (UNCHANGED)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withValues(alpha: 0.75),
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _toggleStatus(PhotoStatus.rejected);
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.cancel_rounded,
                              size: 18,
                              color: isRejected
                                  ? Colors.white
                                  : AppColors.rejected,
                            ),
                            label: Text(
                              'Reject Photo',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: isRejected
                                    ? Colors.white
                                    : AppColors.rejected,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isRejected
                                  ? AppColors.rejected
                                  : Colors.white.withValues(alpha: 0.12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(10),
                                side: BorderSide(
                                  color: AppColors.rejected
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _toggleStatus(PhotoStatus.approved),
                            icon: Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: isApproved
                                  ? Colors.white
                                  : AppColors.approved,
                            ),
                            label: Text(
                              'Approve Photo',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: isApproved
                                    ? Colors.white
                                    : AppColors.approved,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isApproved
                                  ? AppColors.approved
                                  : Colors.white.withValues(alpha: 0.12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(10),
                                side: BorderSide(
                                  color: AppColors.approved
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// INFO (SAFE)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: Colors.white54, size: 12),
                      const SizedBox(width: 4),
                      Text(photo.date,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on_rounded,
                          color: Colors.white54, size: 12),
                      const SizedBox(width: 4),
                      Text(photo.location,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                      const SizedBox(width: 12),
                      const Icon(Icons.smartphone_rounded,
                          color: Colors.white54, size: 12),
                      const SizedBox(width: 4),
                      Text(photo.device,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}