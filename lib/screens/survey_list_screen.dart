import 'package:dcs_supervisor/core/commons/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/commons/app_colors.dart';
import '../core/providers.dart';
import '../core/state/survey_filters_state.dart';
import '../data/survey_dummy_data.dart';
import '../models/survey_model.dart';
import 'survey_detail_screen.dart';
import 'login_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Filter model
// ─────────────────────────────────────────────────────────────────────────────
typedef _ActiveFilters = SurveyFiltersState;

class SurveyListScreen extends ConsumerStatefulWidget {
  const SurveyListScreen({super.key});

  @override
  ConsumerState<SurveyListScreen> createState() => _SurveyListScreenState();
}

class _SurveyListScreenState extends ConsumerState<SurveyListScreen> {
  final List<SurveyModel> _allSurveys = dummySurveys;

  final ScrollController _scrollController = ScrollController();
  bool _showBottomLoader = false;

  _ActiveFilters get _filters => ref.read(surveyFiltersProvider);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final isNearBottom = position.pixels >= position.maxScrollExtent - 100;

    if (isNearBottom && !_showBottomLoader) {
      setState(() {
        _showBottomLoader = true;
      });

      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _showBottomLoader = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _updateFilters(_ActiveFilters nextFilters) async {
    await ref.read(surveyFiltersProvider.notifier).update(nextFilters);
  }

  Future<void> _clearAllFilters() async {
    await ref.read(surveyFiltersProvider.notifier).clear();
  }
  // Filtered surveys ──────────────────────────────────────────────────
  List<SurveyModel> get _filteredSurveys {
    return _allSurveys.where((s) {
      if (_filters.season != null &&
          !_isSurveyInSeason(s.surveyDate, _filters.season!)) {
        return false;
      }
      if (_filters.village != null &&
          s.village.toLowerCase() != _filters.village!.toLowerCase()) {
        return false;
      }
      if (_filters.taluka != null &&
          s.taluka.toLowerCase() != _filters.taluka!.toLowerCase()) {
        return false;
      }
      if (_filters.statuses != null &&
          _filters.statuses!.isNotEmpty &&
          !_filters.statuses!.contains(s.status)) {
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

  int get _pendingCount =>
      _filteredSurveys.where((s) => s.status == SurveyStatus.pending).length;
  int get _approvedCount =>
      _filteredSurveys.where((s) => s.status == SurveyStatus.approved).length;
  int get _rejectedCount =>
      _filteredSurveys.where((s) => s.status == SurveyStatus.rejected).length;

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
    'Dec',
  ][m];

  void _openDetail(int index) {
    final surveys = _filteredSurveys;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SurveyDetailScreen(surveys: surveys, initialIndex: index),
      ),
    ).then((_) => setState(() {}));
  }

  Future<void> _logout() async {
    final user = ref.read(authControllerProvider).currentUser;

    if (user != null) {
      final apiManager = ref.read(apiManagerProvider);
      final result = await apiManager.logout(user.userToken, user.userId);
      if (result.isSuccess) {
        debugPrint('[Logout] API logout successful for userId: ${user.userId}');
      } else {
        debugPrint('[Logout] API logout failed: ${result.error}');
        // We still proceed with local logout even if API call fails
      }
    }

    await ref.read(authControllerProvider.notifier).logout();
    ref.read(surveyFiltersProvider.notifier).clear();

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        const LoginScreen(),
        transitionsBuilder: (context, anim, secondaryAnimation, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    ref.watch(authControllerProvider);
    ref.watch(surveyFiltersProvider);

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
    final authState = ref.read(authControllerProvider);
    final user = authState.currentUser;
    final selectedState = user?.districtName;
    final initials = (user?.userFullName ?? 'U')
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
                    selectedState == null || selectedState.isEmpty
                        ? (user?.userFullName ?? 'Supervisor')
                        : '${user?.userFullName ?? 'Supervisor'} • $selectedState',
                    style: TextStyle(
                      fontSize: context.getFontSize(AppDimens.fontL),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: context.getHeight(2)),
                  Text(
                    user?.userName ?? '',
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
    final ic =
        iconColor ?? (active ? AppColors.primaryDark : AppColors.textSecondary);
    final lc =
        labelColor ??
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
          borderRadius: BorderRadius.circular(
            context.getWidth(AppDimens.radiusS),
          ),
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

  // ── App bar ───────────────────────────────────────────────────────────
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
                            color: AppColors.primary.withValues(alpha: 0.4),
                          )
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
                        border: Border.all(
                          color: AppColors.surface,
                          width: 1.5,
                        ),
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

  Widget _actionButton(IconData icon) => Container(
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

  // ── Body ──────────────────────────────────────────────────────────────
  Widget _buildBody() {
    return SingleChildScrollView(
      controller: _scrollController,
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
                if (_filters.hasAny) _buildActiveFilterChips(),
                if (_filters.hasAny) SizedBox(height: context.getHeight(10)),
                _buildSurveyListHeader(),
                SizedBox(height: context.getHeight(8)),
                _buildSurveyList(),
                SizedBox(height: context.getHeight(16)),
              ],
            ),
          ),
          // Bottom loader — appears briefly after scrolling to the very end
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _showBottomLoader
                ? Container(
                    key: const ValueKey('loader'),
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: context.getHeight(18),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: context.getWidth(16),
                          height: context.getWidth(16),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: context.getWidth(10)),
                        Text(
                          'Refreshing survey list…',
                          style: TextStyle(
                            fontSize: context.getFontSize(AppDimens.fontS),
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
        ],
      ),
    );
  }

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
            label: 'Pending: $_pendingCount',
          ),
          _statusBadge(
            color: AppColors.approved,
            bg: AppColors.approvedBg,
            label: 'Approved: $_approvedCount',
          ),
          _statusBadge(
            color: AppColors.rejected,
            bg: AppColors.rejectedBg,
            label: 'Rejected: $_rejectedCount',
          ),
        ],
      ),
    );
  }

  Widget _statusBadge({
    required Color color,
    required Color bg,
    required String label,
  }) {
    final textColor = color == AppColors.pending
        ? const Color(0xFFB45309)
        : color;
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

  Widget _buildActiveFilterChips() {
    final chips = <Widget>[];

    if (_filters.year != null) {
      chips.add(
        _filterChip(
          label: _filters.year!,
          icon: Icons.calendar_view_month_outlined,
          onRemove: () => _updateFilters(_filters.copyWith(year: null)),
        ),
      );
    }
    if (_filters.season != null) {
      chips.add(
        _filterChip(
          label: _filters.season!,
          icon: Icons.wb_sunny_outlined,
          onRemove: () => _updateFilters(_filters.copyWith(season: null)),
        ),
      );
    }
    if (_filters.village != null) {
      chips.add(
        _filterChip(
          label: _filters.village!,
          icon: Icons.location_on_outlined,
          onRemove: () => _updateFilters(_filters.copyWith(village: null)),
        ),
      );
    } else if (_filters.taluka != null) {
      chips.add(
        _filterChip(
          label: _filters.taluka!,
          icon: Icons.location_city_outlined,
          onRemove: () =>
              _updateFilters(_filters.copyWith(taluka: null, village: null)),
        ),
      );
    } else if (_filters.district != null) {
      chips.add(
        _filterChip(
          label: _filters.district!,
          icon: Icons.map_outlined,
          onRemove: () => _updateFilters(
            _filters.copyWith(district: null, taluka: null, village: null),
          ),
        ),
      );
    }

    if (_filters.dateRange != null) {
      final dr = _filters.dateRange!;
      final label =
          '${dr.start.day} ${_mon(dr.start.month)} – ${dr.end.day} ${_mon(dr.end.month)}';
      chips.add(
        _filterChip(
          label: label,
          icon: Icons.date_range_outlined,
          onRemove: () => _updateFilters(_filters.copyWith(dateRange: null)),
        ),
      );
    }

    if (_filters.statuses != null && _filters.statuses!.isNotEmpty) {
      final labels = _filters.statuses!
          .map((s) {
            return s == SurveyStatus.pending
                ? 'Pending'
                : s == SurveyStatus.approved
                ? 'Approved'
                : 'Rejected';
          })
          .join(', ');

      chips.add(
        _filterChip(
          label: labels,
          icon: Icons.info_outline_rounded,
          onRemove: () => _updateFilters(_filters.copyWith(statuses: null)),
        ),
      );
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
              onTap: _clearAllFilters,
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
        Wrap(
          spacing: context.getWidth(8),
          runSpacing: context.getHeight(6),
          children: chips,
        ),
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
        horizontal: context.getWidth(10),
        vertical: context.getHeight(6),
      ),
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
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(context.getWidth(6)),
              child: Icon(
                Icons.close_rounded,
                size: context.getWidth(13),
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildSurveyList() {
    final surveys = _filteredSurveys;
    if (surveys.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: context.getHeight(40)),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: context.getWidth(40),
              color: AppColors.divider,
            ),
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
              onTap: _clearAllFilters,
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
            .map(
              (e) => _surveyItem(
                e.value,
                isLast: e.key == surveys.length - 1,
                filteredIndex: e.key,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _surveyItem(
    SurveyModel s, {
    required bool isLast,
    required int filteredIndex,
  }) {
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
                      Icon(
                        Icons.location_city_outlined,
                        size: context.getWidth(12),
                        color: AppColors.textMuted,
                      ),
                      SizedBox(width: context.getWidth(4)),
                      Text(
                        '${s.taluka} Taluka',
                        style: TextStyle(
                          fontSize: context.getFontSize(10),
                          color: AppColors.textMuted,
                        ),
                      ),
                      SizedBox(width: context.getWidth(10)),
                      Icon(
                        Icons.calendar_today_outlined,
                        size: context.getWidth(12),
                        color: AppColors.textMuted,
                      ),
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
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: context.getWidth(18),
            ),
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
  // Change: Filter bottom sheet — all sections use DropdownButtonFormField
  // instead of chip selectors
  // ─────────────────────────────────────────────────────────────────────
  void _showFilterSheet() {
    _ActiveFilters draft = _filters.copyWith();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          // Reusable styled dropdown builder
          Widget buildDropdown<T>({
            required String hint,
            required T? value,
            required List<T> items,
            required String Function(T) labelOf,
            required void Function(T?) onChanged,
          }) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: context.getWidth(12),
                vertical: context.getHeight(2),
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(context.getWidth(10)),
                border: Border.all(
                  color: value != null
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : AppColors.divider,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                  isExpanded: true,
                  value: value,
                  hint: Text(
                    hint,
                    style: TextStyle(
                      fontSize: context.getFontSize(AppDimens.fontS),
                      color: AppColors.textMuted,
                    ),
                  ),
                  items: [
                    // "All" / clear option
                    DropdownMenuItem<T>(
                      value: null,
                      child: Text(
                        'All',
                        style: TextStyle(
                          fontSize: context.getFontSize(AppDimens.fontS),
                          color: AppColors.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    ...items.map(
                      (item) => DropdownMenuItem<T>(
                        value: item,
                        child: Text(
                          labelOf(item),
                          style: TextStyle(
                            fontSize: context.getFontSize(AppDimens.fontS),
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                  onChanged: onChanged,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: value != null
                        ? AppColors.primaryDark
                        : AppColors.textMuted,
                  ),
                  dropdownColor: AppColors.surface,
                  style: TextStyle(
                    fontSize: context.getFontSize(AppDimens.fontS),
                    color: value != null
                        ? AppColors.primaryDark
                        : AppColors.textPrimary,
                    fontWeight: value != null
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
            );
          }

          return Container(
            height: MediaQuery.of(ctx).size.height * 0.88,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(context.getWidth(AppDimens.radiusL)),
              ),
            ),
            child: Column(
              children: [
                // Handle + title
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
                          Text(
                            'Filter Surveys',
                            style: TextStyle(
                              fontSize: context.getFontSize(AppDimens.fontXL),
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () =>
                                setSheetState(() => draft = _ActiveFilters()),
                            child: Text(
                              'Reset',
                              style: TextStyle(
                                fontSize: context.getFontSize(AppDimens.fontS),
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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
                        // ── Year ─────────────────────────────────────
                        _filterSectionTitle('Year'),
                        SizedBox(height: context.getHeight(8)),
                        buildDropdown<String>(
                          hint: 'Select year',
                          value: draft.year,
                          items: ['2023-24', '2024-25', '2025-26'],
                          labelOf: (y) => y,
                          onChanged: (v) => setSheetState(
                            () => draft = draft.copyWith(year: v),
                          ),
                        ),

                        SizedBox(height: context.getHeight(20)),

                        // ── District ──────────────────────────────────
                        _filterSectionTitle('Season'),
                        SizedBox(height: context.getHeight(8)),
                        buildDropdown<String>(
                          hint: 'Select season',
                          value: draft.season,
                          items: const ['Summer', 'Kharif', 'Rabi'],
                          labelOf: (season) => season,
                          onChanged: (v) => setSheetState(
                            () => draft = draft.copyWith(
                              season: v,
                              dateRange: _clampDateRangeToSeason(
                                draft.dateRange,
                                v,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: context.getHeight(20)),

                        _filterSectionTitle('District'),
                        SizedBox(height: context.getHeight(8)),
                        buildDropdown<String>(
                          hint: 'Select district',
                          value: draft.district,
                          items: ['Ahmedabad', 'Gandhinagar', 'Anand'],
                          labelOf: (d) => d,
                          onChanged: (v) => setSheetState(
                            () => draft = draft.copyWith(
                              district: v,
                              taluka: null,
                              village: null,
                            ),
                          ),
                        ),

                        // ── Taluka (shown once district is picked) ────
                        if (draft.district != null) ...[
                          SizedBox(height: context.getHeight(14)),
                          _filterSectionTitle('Taluka'),
                          SizedBox(height: context.getHeight(8)),
                          buildDropdown<String>(
                            hint: 'Select taluka',
                            value: draft.taluka,
                            items: _talukaFor(draft.district!),
                            labelOf: (t) => t,
                            onChanged: (v) => setSheetState(
                              () => draft = draft.copyWith(
                                taluka: v,
                                village: null,
                              ),
                            ),
                          ),
                        ],

                        // ── Village (shown once taluka is picked) ─────
                        if (draft.taluka != null) ...[
                          SizedBox(height: context.getHeight(14)),
                          _filterSectionTitle('Village'),
                          SizedBox(height: context.getHeight(8)),
                          buildDropdown<String>(
                            hint: 'Select village',
                            value: draft.village,
                            items: _villageFor(draft.taluka!),
                            labelOf: (v) => v,
                            onChanged: (v) => setSheetState(
                              () => draft = draft.copyWith(village: v),
                            ),
                          ),
                        ],

                        SizedBox(height: context.getHeight(20)),

                        // ── Date Range ────────────────────────────────
                        _filterSectionTitle('Date Range'),
                        SizedBox(height: context.getHeight(2)),
                        // // Quick preset dropdown
                        // buildDropdown<DateTimeRange>(
                        //   hint: 'Select date range',
                        //   value: draft.dateRange != null
                        //       ? _findMatchingPreset(draft.dateRange!)
                        //       : null,
                        //   items: [
                        //     _quickDateRange(7),
                        //     _quickDateRange(14),
                        //     _quickDateRange(30),
                        //   ],
                        //   labelOf: (dr) => _dateRangeLabel(dr),
                        //   onChanged: (v) => setSheetState(
                        //           () => draft = draft.copyWith(dateRange: v)),
                        // ),
                        SizedBox(height: context.getHeight(8)),
                        // Custom date range picker
                        GestureDetector(
                          onTap: () async {
                            final seasonRange = draft.season == null
                                ? null
                                : _seasonRangeFor(draft.season!);
                            final firstDate = seasonRange == null
                                ? DateTime(2020)
                                : seasonRange['start'] as DateTime;
                            final lastDate = seasonRange == null
                                ? DateTime.now()
                                : seasonRange['end'] as DateTime;
                            final initialDateRange = draft.dateRange == null
                                ? (seasonRange == null
                                      ? null
                                      : DateTimeRange(
                                          start: firstDate,
                                          end: lastDate,
                                        ))
                                : _clampDateRangeToSeason(
                                    draft.dateRange,
                                    draft.season,
                                  );

                            final picked = await showDateRangePicker(
                              context: ctx,
                              firstDate: firstDate,
                              lastDate: lastDate,
                              initialDateRange: initialDateRange,
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: AppColors.primary,
                                      onPrimary: Colors.white,
                                      surface: Colors.white,
                                      onSurface: AppColors.textPrimary,
                                    ),

                                    /// 🧊 Dialog styling
                                    dialogTheme: DialogThemeData(
                                      elevation: 12,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),

                                    /// 🔘 Buttons styling
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    ),

                                    /// 📅 Date Picker Theme
                                    datePickerTheme: DatePickerThemeData(
                                      backgroundColor: Colors.white,

                                      /// 🔥 HEADER (top section)
                                      headerBackgroundColor: AppColors.primary,
                                      headerForegroundColor: Colors.white,
                                      headerHeadlineStyle: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      headerHelpStyle: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                      ),

                                      /// 📆 DAY CELLS
                                      dayStyle: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),

                                      /// 🟢 SELECTED DAY
                                      dayBackgroundColor:
                                          WidgetStateProperty.resolveWith((
                                            states,
                                          ) {
                                            if (states.contains(
                                              WidgetState.selected,
                                            )) {
                                              return AppColors.primary;
                                            }
                                            return null;
                                          }),

                                      dayForegroundColor:
                                          WidgetStateProperty.resolveWith((
                                            states,
                                          ) {
                                            if (states.contains(
                                              WidgetState.selected,
                                            )) {
                                              return Colors.white;
                                            }
                                            return AppColors.textPrimary;
                                          }),

                                      /// 🟡 TODAY
                                      todayBorder: BorderSide(
                                        color: AppColors.primary,
                                        width: 1.5,
                                      ),

                                      /// 📅 RANGE HIGHLIGHT
                                      rangeSelectionBackgroundColor: AppColors
                                          .primary
                                          .withValues(alpha: 0.15),

                                      rangeSelectionOverlayColor:
                                          WidgetStatePropertyAll(
                                            AppColors.primary.withValues(
                                              alpha: 0.1,
                                            ),
                                          ),

                                      /// 🧊 SHAPE
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),

                                      /// 🪶 ELEVATION FEEL
                                      elevation: 10,
                                    ),
                                  ),

                                  /// ✨ Add subtle shadow wrapper
                                  child: Center(
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 24,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.15,
                                            ),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: child!,
                                    ),
                                  ),
                                );
                              },
                            );
                            if (picked != null) {
                              setSheetState(
                                () => draft = draft.copyWith(dateRange: picked),
                              );
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: context.getWidth(12),
                              vertical: context.getHeight(20),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(
                                context.getWidth(10),
                              ),
                              border: Border.all(
                                color: draft.dateRange != null
                                    ? AppColors.primary.withValues(alpha: 0.5)
                                    : AppColors.divider,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.date_range_outlined,
                                  size: context.getWidth(16),
                                  color: draft.dateRange != null
                                      ? AppColors.primaryDark
                                      : AppColors.textMuted,
                                ),
                                SizedBox(width: context.getWidth(8)),
                                Expanded(
                                  child: Text(
                                    draft.dateRange != null
                                        ? '${draft.dateRange!.start.day} ${_mon(draft.dateRange!.start.month)} – ${draft.dateRange!.end.day} ${_mon(draft.dateRange!.end.month)}'
                                        : 'Select date range',
                                    style: TextStyle(
                                      fontSize: context.getFontSize(
                                        AppDimens.fontS,
                                      ),
                                      color: draft.dateRange != null
                                          ? AppColors.textPrimary
                                          : AppColors.textMuted,
                                      fontWeight: draft.dateRange != null
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: context.getWidth(18),
                                  color: draft.dateRange != null
                                      ? AppColors.primaryDark
                                      : AppColors.textMuted,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: context.getHeight(20)),

                        // ── Status ────────────────────────────────────
                        _filterSectionTitle('Status'),
                        SizedBox(height: context.getHeight(8)),

                        GestureDetector(
                          onTap: () async {
                            final tempSelected = List<SurveyStatus>.from(
                              draft.statuses ?? [],
                            );

                            final result =
                                await showModalBottomSheet<List<SurveyStatus>>(
                                  context: context,
                                  backgroundColor: AppColors.surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(
                                        context.getWidth(16),
                                      ),
                                    ),
                                  ),
                                  builder: (context) {
                                    return StatefulBuilder(
                                      builder: (context, setModalState) {
                                        return Padding(
                                          padding: EdgeInsets.all(
                                            context.getWidth(16),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ...SurveyStatus.values.map((
                                                status,
                                              ) {
                                                final isSelected = tempSelected
                                                    .contains(status);

                                                return CheckboxListTile(
                                                  value: isSelected,
                                                  activeColor:
                                                      AppColors.primary,
                                                  title: Text(
                                                    status ==
                                                            SurveyStatus.pending
                                                        ? 'Pending'
                                                        : status ==
                                                              SurveyStatus
                                                                  .approved
                                                        ? 'Approved'
                                                        : 'Rejected',
                                                    style: TextStyle(
                                                      fontSize: context
                                                          .getFontSize(
                                                            AppDimens.fontS,
                                                          ),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          AppColors.textPrimary,
                                                    ),
                                                  ),
                                                  onChanged: (val) {
                                                    setModalState(() {
                                                      if (val == true) {
                                                        tempSelected.add(
                                                          status,
                                                        );
                                                      } else {
                                                        tempSelected.remove(
                                                          status,
                                                        );
                                                      }
                                                    });
                                                  },
                                                );
                                              }),

                                              SizedBox(
                                                height: context.getHeight(10),
                                              ),

                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      context,
                                                      tempSelected,
                                                    );
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        AppColors.primary,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            context.getWidth(
                                                              AppDimens.radiusS,
                                                            ),
                                                          ),
                                                    ),
                                                  ),
                                                  child: const Text("Apply"),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );

                            if (result != null) {
                              setSheetState(() {
                                draft = draft.copyWith(statuses: result);
                              });
                            }
                          },

                          // 👇 SAME LOOK AS YOUR DROPDOWN
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: context.getWidth(12),
                              vertical: context.getHeight(20),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(
                                context.getWidth(10),
                              ),
                              border: Border.all(
                                color:
                                    (draft.statuses != null &&
                                        draft.statuses!.isNotEmpty)
                                    ? AppColors.primary.withValues(alpha: 0.5)
                                    : AppColors.divider,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    (draft.statuses == null ||
                                            draft.statuses!.isEmpty)
                                        ? 'Select status'
                                        : draft.statuses!
                                              .map(
                                                (s) => s == SurveyStatus.pending
                                                    ? 'Pending'
                                                    : s == SurveyStatus.approved
                                                    ? 'Approved'
                                                    : 'Rejected',
                                              )
                                              .join(', '),
                                    style: TextStyle(
                                      fontSize: context.getFontSize(
                                        AppDimens.fontS,
                                      ),
                                      color:
                                          (draft.statuses != null &&
                                              draft.statuses!.isNotEmpty)
                                          ? AppColors.textPrimary
                                          : AppColors.textMuted,
                                      fontWeight:
                                          (draft.statuses != null &&
                                              draft.statuses!.isNotEmpty)
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color:
                                      (draft.statuses != null &&
                                          draft.statuses!.isNotEmpty)
                                      ? AppColors.primaryDark
                                      : AppColors.textMuted,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: context.getHeight(20)),

                        SizedBox(height: context.getHeight(20)),

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
                    context.getHeight(20),
                  ),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.divider)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: context.getHeight(48),
                    child: ElevatedButton(
                      onPressed: () async {
                        final navigator = Navigator.of(ctx);
                        await _updateFilters(draft);
                        navigator.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            context.getWidth(AppDimens.radiusS),
                          ),
                        ),
                      ),
                      child: Text(
                        'Apply Filters',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: context.getFontSize(AppDimens.fontM),
                        ),
                      ),
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

  // Dummy location hierarchy
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

  List<Map<String, dynamic>> _seasonRanges(DateTime currentDate) {
    return [
      {
        'season': 'Summer',
        'start': DateTime(currentDate.year, 4, 1),
        'end': DateTime(currentDate.year, 5, 31),
      },
      {
        'season': 'Kharif',
        'start': DateTime(currentDate.year, 6, 1),
        'end': DateTime(currentDate.year, 10, 31),
      },
      {
        'season': 'Rabi',
        'start': currentDate.month > 3
            ? DateTime(currentDate.year, 11, 1)
            : DateTime(currentDate.year - 1, 11, 1),
        'end': currentDate.month > 3
            ? DateTime(currentDate.year + 1, 3, 31, 23, 59, 59)
            : DateTime(currentDate.year, 3, 31, 23, 59, 59),
      },
    ];
  }

  bool _isSurveyInSeason(DateTime surveyDate, String selectedSeason) {
    final seasonRange = _seasonRangeFor(selectedSeason);
    if (seasonRange == null) {
      return false;
    }

    final start = seasonRange['start'] as DateTime;
    final end = seasonRange['end'] as DateTime;
    return !surveyDate.isBefore(start) && !surveyDate.isAfter(end);
  }

  Map<String, dynamic>? _seasonRangeFor(String seasonName) {
    for (final season in _seasonRanges(DateTime.now())) {
      if (season['season'] == seasonName) {
        return season;
      }
    }
    return null;
  }

  DateTimeRange? _clampDateRangeToSeason(
    DateTimeRange? dateRange,
    String? seasonName,
  ) {
    if (dateRange == null || seasonName == null) {
      return dateRange;
    }

    final seasonRange = _seasonRangeFor(seasonName);
    if (seasonRange == null) {
      return dateRange;
    }

    final seasonStart = seasonRange['start'] as DateTime;
    final seasonEnd = seasonRange['end'] as DateTime;

    final clampedStart = dateRange.start.isBefore(seasonStart)
        ? seasonStart
        : dateRange.start;
    final clampedEnd = dateRange.end.isAfter(seasonEnd)
        ? seasonEnd
        : dateRange.end;

    if (clampedStart.isAfter(clampedEnd)) {
      return DateTimeRange(start: seasonStart, end: seasonEnd);
    }

    return DateTimeRange(start: clampedStart, end: clampedEnd);
  }

}
