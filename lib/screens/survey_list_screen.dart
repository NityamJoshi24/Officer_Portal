import 'package:dcs_supervisor/core/app_dimensions.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_state.dart';
import '../data/survey_dummy_data.dart';
import '../models/survey_model.dart';
import 'survey_detail_screen.dart';
import 'login_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Filter model
// ─────────────────────────────────────────────────────────────────────────────
class _ActiveFilters {
  // Year
  String? year; // e.g. '2025-26'

  // Location (hierarchical — store the deepest selected)
  String? district; // 'Ahmedabad'
  String? taluka;   // 'Daskroi'
  String? village;  // 'Enasan'

  // Date range
  DateTimeRange? dateRange;

  // Status
  SurveyStatus? status;

  bool get hasAny =>
      year != null ||
      district != null ||
      taluka != null ||
      village != null ||
      dateRange != null ||
      status != null;

  _ActiveFilters copyWith({
    Object? year = _sentinel,
    Object? district = _sentinel,
    Object? taluka = _sentinel,
    Object? village = _sentinel,
    Object? dateRange = _sentinel,
    Object? status = _sentinel,
  }) {
    final f = _ActiveFilters();
    f.year = year == _sentinel ? this.year : year as String?;
    f.district = district == _sentinel ? this.district : district as String?;
    f.taluka = taluka == _sentinel ? this.taluka : taluka as String?;
    f.village = village == _sentinel ? this.village : village as String?;
    f.dateRange = dateRange == _sentinel ? this.dateRange : dateRange as DateTimeRange?;
    f.status = status == _sentinel ? this.status : status as SurveyStatus?;
    return f;
  }

  static const _sentinel = Object();
}

// ─────────────────────────────────────────────────────────────────────────────

class SurveyListScreen extends StatefulWidget {
  const SurveyListScreen({super.key});

  @override
  State<SurveyListScreen> createState() => _SurveyListScreenState();
}

class _SurveyListScreenState extends State<SurveyListScreen> {
  final List<SurveyModel> _allSurveys = dummySurveys;

  _ActiveFilters _filters = _ActiveFilters();

  // ── Filtered surveys ──────────────────────────────────────────────────
  List<SurveyModel> get _filteredSurveys {
    return _allSurveys.where((s) {
      if (_filters.village != null &&
          s.village.toLowerCase() != _filters.village!.toLowerCase()) {
        return false;
      }
      if (_filters.taluka != null &&
          s.taluka.toLowerCase() != _filters.taluka!.toLowerCase()) {
        return false;
      }
      if (_filters.status != null && s.status != _filters.status) {
        return false;
      }
      if (_filters.dateRange != null) {
        final d = s.surveyDate;
        if (d.isBefore(_filters.dateRange!.start) ||
            d.isAfter(_filters.dateRange!.end)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  // ── Stats (on filtered set) ───────────────────────────────────────────
  int get _pendingCount =>
      _filteredSurveys.where((s) => s.status == SurveyStatus.pending).length;
  int get _approvedCount =>
      _filteredSurveys.where((s) => s.status == SurveyStatus.approved).length;
  int get _rejectedCount =>
      _filteredSurveys.where((s) => s.status == SurveyStatus.rejected).length;

  // ── Month helper ──────────────────────────────────────────────────────
  String _mon(int m) => const [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][m];

  // ── Navigation ────────────────────────────────────────────────────────
  void _openDetail(int index) {
    final surveys = _filteredSurveys;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SurveyDetailScreen(
          surveys: surveys,
          initialIndex: index,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  void _logout() {
    AppState.instance.logout();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // ── Drawer ────────────────────────────────────────────────────────────
  Widget _buildDrawer() {
    final user = AppState.instance.currentUser;
    final initials = (user?.name ?? 'U')
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join()
        .toUpperCase();

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(context.getWidth(AppDimens.spaceM)),
              color: AppColors.primaryLight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: context.getWidth(52),
                    height: context.getWidth(52),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.getFontSize(AppDimens.fontXL),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(height: context.getHeight(10)),
                  Text(
                    user?.name ?? 'Supervisor',
                    style: TextStyle(
                      fontSize: context.getFontSize(AppDimens.fontL),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: context.getHeight(2)),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                      fontSize: context.getFontSize(AppDimens.fontS),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.getHeight(8)),
            _drawerItem(
              icon: Icons.grid_view_rounded,
              label: 'Surveys',
              onTap: () => Navigator.pop(context),
              active: true,
            ),
            _drawerItem(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Bank Details',
              onTap: () => Navigator.pop(context),
            ),
            _drawerItem(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              onTap: () => Navigator.pop(context),
            ),
            _drawerItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () => Navigator.pop(context),
            ),
            const Spacer(),
            Divider(color: AppColors.divider, height: context.getHeight(1)),
            SizedBox(height: context.getHeight(4)),
            _drawerItem(
              icon: Icons.logout_rounded,
              label: 'Logout',
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
              iconColor: AppColors.rejected,
              labelColor: AppColors.rejected,
            ),
            SizedBox(height: context.getHeight(12)),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
    Color? iconColor,
    Color? labelColor,
  }) {
    final ic = iconColor ??
        (active ? AppColors.primaryDark : AppColors.textSecondary);
    final lc = labelColor ??
        (active ? AppColors.primaryDark : AppColors.textSecondary);

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: context.getWidth(8),
          vertical: context.getHeight(2),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: context.getWidth(12),
          vertical: context.getHeight(12),
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryLight : Colors.transparent,
          borderRadius:
              BorderRadius.circular(context.getWidth(AppDimens.radiusS)),
        ),
        child: Row(
          children: [
            Icon(icon, size: context.getWidth(AppDimens.iconM), color: ic),
            SizedBox(width: context.getWidth(12)),
            Text(
              label,
              style: TextStyle(
                fontSize: context.getFontSize(AppDimens.fontM),
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: lc,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App bar — Change #4: filter icon opens filter sheet ───────────────
  Widget _buildAppBar() {
    final hasActiveFilters = _filters.hasAny;
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(
        context.getWidth(16),
        context.getHeight(10),
        context.getWidth(12),
        context.getHeight(8),
      ),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => Scaffold.of(ctx).openDrawer(),
              child: Container(
                width: context.getWidth(36),
                height: context.getWidth(36),
                decoration: const BoxDecoration(
                  color: AppColors.iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.menu_rounded,
                  color: AppColors.textSecondary,
                  size: context.getWidth(AppDimens.iconM),
                ),
              ),
            ),
          ),
          SizedBox(width: context.getWidth(10)),
          Expanded(
            child: Text(
              'Supervisor Portal',
              style: TextStyle(
                fontSize: context.getFontSize(AppDimens.fontL),
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // Change #4: Filter button with badge if filters active
          GestureDetector(
            onTap: _showFilterSheet,
            child: Stack(
              children: [
                Container(
                  width: context.getWidth(36),
                  height: context.getWidth(36),
                  decoration: BoxDecoration(
                    color: hasActiveFilters
                        ? AppColors.primaryLight
                        : AppColors.iconBg,
                    shape: BoxShape.circle,
                    border: hasActiveFilters
                        ? Border.all(
                            color: AppColors.primary.withValues(alpha: 0.4))
                        : null,
                  ),
                  child: Icon(
                    Icons.filter_alt_rounded,
                    color: hasActiveFilters
                        ? AppColors.primaryDark
                        : AppColors.textSecondary,
                    size: context.getWidth(AppDimens.iconM - 1),
                  ),
                ),
                if (hasActiveFilters)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: context.getWidth(10),
                      height: context.getWidth(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: context.getWidth(AppDimens.spaceS)),
          _actionButton(Icons.search_rounded),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon) {
    return Container(
      width: context.getWidth(36),
      height: context.getWidth(36),
      decoration: const BoxDecoration(
        color: AppColors.iconBg,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: AppColors.textSecondary,
        size: context.getWidth(AppDimens.iconM - 1),
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────
  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusBar(),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.getWidth(AppDimens.spaceM),
              vertical: context.getHeight(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsCards(),
                SizedBox(height: context.getHeight(14)),
                // Change #5: Active filter chips
                if (_filters.hasAny) _buildActiveFilterChips(),
                if (_filters.hasAny) SizedBox(height: context.getHeight(10)),
                _buildSurveyListHeader(),
                SizedBox(height: context.getHeight(8)),
                _buildSurveyList(),
                SizedBox(height: context.getHeight(16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Status bar ────────────────────────────────────────────────────────
  Widget _buildStatusBar() {
    return Container(
      color: AppColors.surface,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        context.getWidth(12),
        0,
        context.getWidth(12),
        context.getHeight(12),
      ),
      child: Wrap(
        spacing: context.getWidth(8),
        runSpacing: context.getHeight(8),
        children: [
          _statusBadge(
              color: AppColors.pending,
              bg: AppColors.pendingBg,
              label: 'Pending: $_pendingCount'),
          _statusBadge(
              color: AppColors.approved,
              bg: AppColors.approvedBg,
              label: 'Approved: $_approvedCount'),
          _statusBadge(
              color: AppColors.rejected,
              bg: AppColors.rejectedBg,
              label: 'Rejected: $_rejectedCount'),
        ],
      ),
    );
  }

  Widget _statusBadge({
    required Color color,
    required Color bg,
    required String label,
  }) {
    final textColor =
        color == AppColors.pending ? const Color(0xFFB45309) : color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.getWidth(10),
        vertical: context.getHeight(7),
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(context.getWidth(9)),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: context.getWidth(7),
            height: context.getWidth(7),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: context.getWidth(6)),
          Text(
            label,
            style: TextStyle(
              fontSize: context.getFontSize(11),
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Stat cards ────────────────────────────────────────────────────────
  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _statCard(title: 'TOTAL PENDING', value: '$_pendingCount'),
        ),
        SizedBox(width: context.getWidth(AppDimens.spaceS)),
        Expanded(
          child: _statCard(title: 'REVIEWED TODAY', value: '$_approvedCount'),
        ),
      ],
    );
  }

  Widget _statCard({required String title, required String value}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.getWidth(14),
        vertical: context.getHeight(16),
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.getWidth(14)),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: context.getWidth(10),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: context.getFontSize(AppDimens.fontXS),
              color: AppColors.textMuted,
              letterSpacing: 0.9,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.getHeight(6)),
          Text(
            value,
            style: TextStyle(
              fontSize: context.getFontSize(AppDimens.fontXXL),
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  // ── Change #5: Active filter chips ────────────────────────────────────
  Widget _buildActiveFilterChips() {
    final chips = <Widget>[];

    if (_filters.year != null) {
      chips.add(_filterChip(
        label: _filters.year!,
        icon: Icons.calendar_view_month_outlined,
        onRemove: () => setState(() => _filters = _filters.copyWith(year: null)),
      ));
    }

    // Show deepest location selected
    if (_filters.village != null) {
      chips.add(_filterChip(
        label: _filters.village!,
        icon: Icons.location_on_outlined,
        onRemove: () => setState(
            () => _filters = _filters.copyWith(village: null)),
      ));
    } else if (_filters.taluka != null) {
      chips.add(_filterChip(
        label: _filters.taluka!,
        icon: Icons.location_city_outlined,
        onRemove: () =>
            setState(() => _filters = _filters.copyWith(taluka: null, village: null)),
      ));
    } else if (_filters.district != null) {
      chips.add(_filterChip(
        label: _filters.district!,
        icon: Icons.map_outlined,
        onRemove: () => setState(() =>
            _filters = _filters.copyWith(district: null, taluka: null, village: null)),
      ));
    }

    if (_filters.dateRange != null) {
      final dr = _filters.dateRange!;
      final label =
          '${dr.start.day} ${_mon(dr.start.month)} – ${dr.end.day} ${_mon(dr.end.month)}';
      chips.add(_filterChip(
        label: label,
        icon: Icons.date_range_outlined,
        onRemove: () =>
            setState(() => _filters = _filters.copyWith(dateRange: null)),
      ));
    }

    if (_filters.status != null) {
      final statusLabel = _filters.status == SurveyStatus.pending
          ? 'Pending'
          : _filters.status == SurveyStatus.approved
              ? 'Approved'
              : 'Rejected';
      chips.add(_filterChip(
        label: statusLabel,
        icon: Icons.info_outline_rounded,
        onRemove: () =>
            setState(() => _filters = _filters.copyWith(status: null)),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Active Filters',
              style: TextStyle(
                fontSize: context.getFontSize(AppDimens.fontXS),
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() => _filters = _ActiveFilters()),
              child: Text(
                'Clear All',
                style: TextStyle(
                  fontSize: context.getFontSize(AppDimens.fontXS),
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: context.getHeight(8)),
        Wrap(spacing: context.getWidth(8), runSpacing: context.getHeight(6),
            children: chips),
      ],
    );
  }

  Widget _filterChip({
    required String label,
    required IconData icon,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: context.getWidth(10), vertical: context.getHeight(6)),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(context.getWidth(999)),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: context.getWidth(12), color: AppColors.primaryDark),
          SizedBox(width: context.getWidth(5)),
          Text(
            label,
            style: TextStyle(
              fontSize: context.getFontSize(AppDimens.fontXS + 1),
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: context.getWidth(5)),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded,
                size: context.getWidth(13), color: AppColors.primaryDark),
          ),
        ],
      ),
    );
  }

  // ── Survey list header ────────────────────────────────────────────────
  Widget _buildSurveyListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Survey Plots',
          style: TextStyle(
            fontSize: context.getFontSize(AppDimens.fontL),
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.getWidth(8),
            vertical: context.getHeight(4),
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryTint,
            borderRadius: BorderRadius.circular(
              context.getWidth(AppDimens.radiusFull),
            ),
          ),
          child: Text(
            '${_filteredSurveys.length} SURVEYS',
            style: TextStyle(
              fontSize: context.getFontSize(AppDimens.fontXS),
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  // ── Survey list ───────────────────────────────────────────────────────
  Widget _buildSurveyList() {
    final surveys = _filteredSurveys;
    if (surveys.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: context.getHeight(40)),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.search_off_rounded,
                size: context.getWidth(40), color: AppColors.divider),
            SizedBox(height: context.getHeight(12)),
            Text(
              'No surveys match your filters.',
              style: TextStyle(
                fontSize: context.getFontSize(AppDimens.fontM),
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: context.getHeight(8)),
            GestureDetector(
              onTap: () => setState(() => _filters = _ActiveFilters()),
              child: Text(
                'Clear Filters',
                style: TextStyle(
                  fontSize: context.getFontSize(AppDimens.fontS),
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.getWidth(14)),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: context.getWidth(12),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: surveys
            .asMap()
            .entries
            .map((e) =>
                _surveyItem(e.value, isLast: e.key == surveys.length - 1, filteredIndex: e.key))
            .toList(),
      ),
    );
  }

  Widget _surveyItem(SurveyModel s,
      {required bool isLast, required int filteredIndex}) {
    String statusStr;
    switch (s.status) {
      case SurveyStatus.approved:
        statusStr = 'APPROVED';
        break;
      case SurveyStatus.rejected:
        statusStr = 'REJECTED';
        break;
      default:
        statusStr = 'PENDING';
    }
    final dateStr =
        '${s.surveyDate.day} ${_mon(s.surveyDate.month)}, ${s.surveyDate.year}';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openDetail(filteredIndex),
      child: Container(
        constraints: BoxConstraints(minHeight: context.getHeight(70)),
        padding: EdgeInsets.symmetric(
          horizontal: context.getWidth(12),
          vertical: context.getHeight(12),
        ),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: context.getWidth(36),
              height: context.getWidth(36),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(context.getWidth(8)),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '${s.sequenceNumber}',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w700,
                  fontSize: context.getFontSize(15),
                ),
              ),
            ),
            SizedBox(width: context.getWidth(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Survey ${s.id}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: context.getFontSize(14),
                          color: AppColors.textPrimary,
                        ),
                      ),
                      _statusPill(statusStr),
                    ],
                  ),
                  SizedBox(height: context.getHeight(3)),
                  Text(
                    s.ownerName,
                    style: TextStyle(
                      fontSize: context.getFontSize(12),
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: context.getHeight(4)),
                  Row(
                    children: [
                      Icon(Icons.location_city_outlined,
                          size: context.getWidth(12),
                          color: AppColors.textMuted),
                      SizedBox(width: context.getWidth(4)),
                      Text(
                        '${s.taluka} Taluka',
                        style: TextStyle(
                          fontSize: context.getFontSize(10),
                          color: AppColors.textMuted,
                        ),
                      ),
                      SizedBox(width: context.getWidth(10)),
                      Icon(Icons.calendar_today_outlined,
                          size: context.getWidth(12),
                          color: AppColors.textMuted),
                      SizedBox(width: context.getWidth(4)),
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: context.getFontSize(10),
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: context.getWidth(6)),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: context.getWidth(18)),
          ],
        ),
      ),
    );
  }

  Widget _statusPill(String status) {
    Color dot, bg, text;
    switch (status) {
      case 'APPROVED':
        dot = AppColors.approved;
        bg = AppColors.approvedBg;
        text = AppColors.approved;
        break;
      case 'REJECTED':
        dot = AppColors.rejected;
        bg = AppColors.rejectedBg;
        text = AppColors.rejected;
        break;
      default:
        dot = AppColors.pending;
        bg = AppColors.pendingBg;
        text = const Color(0xFFB45309);
    }
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.getWidth(8),
        vertical: context.getHeight(3),
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(context.getWidth(999)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: context.getWidth(6),
            height: context.getWidth(6),
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          SizedBox(width: context.getWidth(4)),
          Text(
            status,
            style: TextStyle(
              fontSize: context.getFontSize(10),
              color: text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Change #4: Filter bottom sheet
  // ─────────────────────────────────────────────────────────────────────
  void _showFilterSheet() {
    // Mutable copy for the sheet
    _ActiveFilters draft = _filters.copyWith();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            height: MediaQuery.of(ctx).size.height * 0.85,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(context.getWidth(AppDimens.radiusL))),
            ),
            child: Column(
              children: [
                // Handle
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      context.getWidth(AppDimens.spaceM),
                      context.getHeight(12),
                      context.getWidth(AppDimens.spaceM),
                      0),
                  child: Column(
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
                      Row(
                        children: [
                          Text('Filter Surveys',
                              style: TextStyle(
                                  fontSize: context.getFontSize(AppDimens.fontXL),
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              setSheetState(() => draft = _ActiveFilters());
                            },
                            child: Text('Reset',
                                style: TextStyle(
                                    fontSize: context.getFontSize(AppDimens.fontS),
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.getHeight(8)),
                Divider(color: AppColors.divider, height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(context.getWidth(AppDimens.spaceM)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Year ──────────────────────────────────────
                        _filterSectionTitle('Year'),
                        SizedBox(height: context.getHeight(8)),
                        Wrap(
                          spacing: context.getWidth(8),
                          runSpacing: context.getHeight(8),
                          children: ['2023-24', '2024-25', '2025-26'].map((y) {
                            final selected = draft.year == y;
                            return GestureDetector(
                              onTap: () => setSheetState(() =>
                                  draft = draft.copyWith(
                                      year: selected ? null : y)),
                              child: _selectableChip(label: y, selected: selected),
                            );
                          }).toList(),
                        ),

                        SizedBox(height: context.getHeight(20)),

                        // ── Location ──────────────────────────────────
                        _filterSectionTitle('District'),
                        SizedBox(height: context.getHeight(8)),
                        Wrap(
                          spacing: context.getWidth(8),
                          runSpacing: context.getHeight(8),
                          children:
                              ['Ahmedabad', 'Gandhinagar', 'Anand'].map((d) {
                            final selected = draft.district == d;
                            return GestureDetector(
                              onTap: () => setSheetState(() => draft =
                                  draft.copyWith(
                                      district: selected ? null : d,
                                      taluka: null,
                                      village: null)),
                              child: _selectableChip(label: d, selected: selected),
                            );
                          }).toList(),
                        ),

                        if (draft.district != null) ...[
                          SizedBox(height: context.getHeight(14)),
                          _filterSectionTitle('Taluka'),
                          SizedBox(height: context.getHeight(8)),
                          Wrap(
                            spacing: context.getWidth(8),
                            runSpacing: context.getHeight(8),
                            children: _talukaFor(draft.district!).map((t) {
                              final selected = draft.taluka == t;
                              return GestureDetector(
                                onTap: () => setSheetState(() => draft =
                                    draft.copyWith(
                                        taluka: selected ? null : t,
                                        village: null)),
                                child: _selectableChip(
                                    label: t, selected: selected),
                              );
                            }).toList(),
                          ),
                        ],

                        if (draft.taluka != null) ...[
                          SizedBox(height: context.getHeight(14)),
                          _filterSectionTitle('Village'),
                          SizedBox(height: context.getHeight(8)),
                          Wrap(
                            spacing: context.getWidth(8),
                            runSpacing: context.getHeight(8),
                            children: _villageFor(draft.taluka!).map((v) {
                              final selected = draft.village == v;
                              return GestureDetector(
                                onTap: () => setSheetState(() => draft =
                                    draft.copyWith(
                                        village: selected ? null : v)),
                                child: _selectableChip(
                                    label: v, selected: selected),
                              );
                            }).toList(),
                          ),
                        ],

                        SizedBox(height: context.getHeight(20)),

                        // ── Date range ────────────────────────────────
                        _filterSectionTitle('Date Range'),
                        SizedBox(height: context.getHeight(8)),
                        Wrap(
                          spacing: context.getWidth(8),
                          runSpacing: context.getHeight(8),
                          children: [
                            _quickDateRange('Last 7 days', 7),
                            _quickDateRange('Last 14 days', 14),
                            _quickDateRange('Last 30 days', 30),
                          ].map((entry) {
                            final isSelected = draft.dateRange != null &&
                                draft.dateRange!.start
                                    .isAtSameMomentAs(entry.start) &&
                                draft.dateRange!.end
                                    .isAtSameMomentAs(entry.end);
                            return GestureDetector(
                              onTap: () => setSheetState(() => draft =
                                  draft.copyWith(
                                      dateRange:
                                          isSelected ? null : entry)),
                              child: _selectableChip(
                                  label: _dateRangeLabel(entry),
                                  selected: isSelected),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: context.getHeight(8)),
                        // Custom date range picker
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDateRangePicker(
                              context: ctx,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                              initialDateRange: draft.dateRange,
                              builder: (context, child) => Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: AppColors.primary,
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                            if (picked != null) {
                              setSheetState(
                                  () => draft = draft.copyWith(dateRange: picked));
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: context.getWidth(12),
                                vertical: context.getHeight(10)),
                            decoration: BoxDecoration(
                              color: draft.dateRange != null
                                  ? AppColors.primaryLight
                                  : AppColors.background,
                              borderRadius:
                                  BorderRadius.circular(context.getWidth(8)),
                              border: Border.all(
                                  color: draft.dateRange != null
                                      ? AppColors.primary.withValues(alpha: 0.4)
                                      : AppColors.divider),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.date_range_outlined,
                                    size: context.getWidth(16),
                                    color: draft.dateRange != null
                                        ? AppColors.primaryDark
                                        : AppColors.textMuted),
                                SizedBox(width: context.getWidth(8)),
                                Text(
                                  draft.dateRange != null
                                      ? '${draft.dateRange!.start.day} ${_mon(draft.dateRange!.start.month)} – ${draft.dateRange!.end.day} ${_mon(draft.dateRange!.end.month)}'
                                      : 'Pick custom range',
                                  style: TextStyle(
                                    fontSize: context.getFontSize(AppDimens.fontS),
                                    color: draft.dateRange != null
                                        ? AppColors.primaryDark
                                        : AppColors.textMuted,
                                    fontWeight: draft.dateRange != null
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: context.getHeight(20)),

                        // ── Status ────────────────────────────────────
                        _filterSectionTitle('Status'),
                        SizedBox(height: context.getHeight(8)),
                        Wrap(
                          spacing: context.getWidth(8),
                          runSpacing: context.getHeight(8),
                          children: [
                            MapEntry(SurveyStatus.pending, 'Pending'),
                            MapEntry(SurveyStatus.approved, 'Approved'),
                            MapEntry(SurveyStatus.rejected, 'Rejected'),
                          ].map((entry) {
                            final selected = draft.status == entry.key;
                            return GestureDetector(
                              onTap: () => setSheetState(() => draft =
                                  draft.copyWith(
                                      status: selected ? null : entry.key)),
                              child: _selectableChip(
                                  label: entry.value, selected: selected),
                            );
                          }).toList(),
                        ),

                        SizedBox(height: context.getHeight(20)),
                      ],
                    ),
                  ),
                ),
                // Apply button
                Container(
                  padding: EdgeInsets.fromLTRB(
                      context.getWidth(AppDimens.spaceM),
                      context.getHeight(12),
                      context.getWidth(AppDimens.spaceM),
                      context.getHeight(20)),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.divider)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: context.getHeight(48),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _filters = draft);
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                context.getWidth(AppDimens.radiusS))),
                      ),
                      child: Text('Apply Filters',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: context.getFontSize(AppDimens.fontM))),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _filterSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: context.getFontSize(AppDimens.fontS),
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _selectableChip({required String label, required bool selected}) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: context.getWidth(12), vertical: context.getHeight(7)),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.background,
        borderRadius: BorderRadius.circular(context.getWidth(999)),
        border: Border.all(
          color: selected
              ? AppColors.primary
              : AppColors.divider,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: context.getFontSize(AppDimens.fontS),
          color: selected ? Colors.white : AppColors.textSecondary,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }

  // Dummy location hierarchy data
  List<String> _talukaFor(String district) {
    const map = {
      'Ahmedabad': ['Daskroi', 'Dholka', 'Sanand'],
      'Gandhinagar': ['Kalol', 'Mansa', 'Dehgam'],
      'Anand': ['Anand', 'Petlad', 'Khambhat'],
    };
    return map[district] ?? [];
  }

  List<String> _villageFor(String taluka) {
    const map = {
      'Daskroi': ['Enasan', 'Vautha', 'Narol'],
      'Dholka': ['Dholka', 'Bagodara', 'Limbdi'],
      'Sanand': ['Sanand', 'Changodar'],
      'Kalol': ['Kalol', 'Pethapur'],
      'Mansa': ['Mansa', 'Kadi'],
      'Dehgam': ['Dehgam', 'Raska'],
      'Anand': ['Anand', 'Vallabh Vidyanagar'],
      'Petlad': ['Petlad', 'Sojitra'],
      'Khambhat': ['Khambhat', 'Borsad'],
    };
    return map[taluka] ?? [];
  }

  DateTimeRange _quickDateRange(String label, int days) {
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days));
    return DateTimeRange(start: start, end: end);
  }

  String _dateRangeLabel(DateTimeRange dr) {
    final diff = dr.end.difference(dr.start).inDays;
    if (diff == 7) return 'Last 7 days';
    if (diff == 14) return 'Last 14 days';
    if (diff == 30) return 'Last 30 days';
    return '${dr.start.day} ${_mon(dr.start.month)} – ${dr.end.day} ${_mon(dr.end.month)}';
  }
}