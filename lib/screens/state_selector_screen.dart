import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/commons/app_colors.dart';
import '../core/commons/app_dimensions.dart';
import '../core/providers.dart';

class StateSelectionScreen extends ConsumerStatefulWidget {
  const StateSelectionScreen({super.key});

  @override
  ConsumerState<StateSelectionScreen> createState() => _StateSelectionScreenState();
}

class _StateSelectionScreenState extends ConsumerState<StateSelectionScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  List<String> _states = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchStates();
  }

  Future<void> _fetchStates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ref.refresh(stateListProvider.future);
      if (!mounted) {
        return;
      }

      setState(() {
        _states = response;
        _isLoading = false;
        _errorMessage =
            response.isEmpty ? 'No states were returned by the server.' : null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<String> get _filteredStates {
    final query = _searchCtrl.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _states;
    }
    return _states.where((state) => state.toLowerCase().contains(query)).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredStates = _filteredStates;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, filteredStates.length),
            Expanded(
              child: Transform.translate(
                offset: Offset(0, -context.getHeight(18)),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.getWidth(AppDimens.spaceM),
                  ),
                  child: Column(
                    children: [
                      _buildSearchCard(context),
                      SizedBox(height: context.getHeight(14)),
                      Expanded(
                        child: _isLoading
                            ? _buildLoadingState(context)
                            : _errorMessage != null
                                ? _buildErrorState(context)
                                : filteredStates.isEmpty
                                    ? _buildEmptyState(context)
                                    : _buildStateList(context, filteredStates),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primaryDark),
          SizedBox(height: context.getHeight(16)),
          Text(
            'Fetching states...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: context.getFontSize(AppDimens.fontS),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(context.getWidth(24)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(context.getWidth(24)),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: context.getWidth(58),
              height: context.getWidth(58),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEDED),
                borderRadius: BorderRadius.circular(context.getWidth(18)),
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                color: Colors.red.shade400,
                size: context.getWidth(26),
              ),
            ),
            SizedBox(height: context.getHeight(14)),
            Text(
              'Could not load states',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: context.getFontSize(AppDimens.fontL),
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: context.getHeight(6)),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.getFontSize(AppDimens.fontS),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            SizedBox(height: context.getHeight(16)),
            TextButton.icon(
              onPressed: _fetchStates,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primaryDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int resultCount) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        context.getWidth(AppDimens.spaceM),
        context.getHeight(8),
        context.getWidth(AppDimens.spaceM),
        context.getHeight(30),
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF123C2D), Color(0xFF1F7A52)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(context.getWidth(28)),
          bottomRight: Radius.circular(context.getWidth(28)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _headerIconButton(
                context: context,
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.pop(context),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.getWidth(12),
                  vertical: context.getHeight(7),
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(context.getWidth(999)),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: context.getWidth(14),
                    ),
                    SizedBox(width: context.getWidth(6)),
                    Text(
                      '$resultCount states',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.getFontSize(AppDimens.fontXS + 1),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.getHeight(22)),
          Text(
            'Choose your working state',
            style: TextStyle(
              color: Colors.white,
              fontSize: context.getFontSize(AppDimens.fontXL),
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          SizedBox(height: context.getHeight(8)),
          Text(
            'Search quickly or scroll the list below to continue into the portal.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: context.getFontSize(AppDimens.fontS),
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.getWidth(14)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.getWidth(22)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: context.getWidth(42),
                height: context.getWidth(42),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(context.getWidth(14)),
                ),
                child: Icon(
                  Icons.travel_explore_rounded,
                  color: AppColors.primaryDark,
                  size: context.getWidth(20),
                ),
              ),
              SizedBox(width: context.getWidth(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'State directory',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: context.getFontSize(AppDimens.fontM),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: context.getHeight(2)),
                    Text(
                      'Tap a card to select and return instantly.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: context.getFontSize(AppDimens.fontS),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.getHeight(14)),
          TextField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search state or union territory',
              hintStyle: TextStyle(
                color: AppColors.textHint,
                fontSize: context.getFontSize(AppDimens.fontS),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.primaryDark,
                size: context.getWidth(20),
              ),
              suffixIcon: _searchCtrl.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() {});
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                        size: context.getWidth(18),
                      ),
                    ),
              filled: true,
              fillColor: AppColors.surfaceMuted,
              contentPadding: EdgeInsets.symmetric(
                horizontal: context.getWidth(14),
                vertical: context.getHeight(14),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.getWidth(16)),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.getWidth(16)),
                borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  width: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateList(BuildContext context, List<String> states) {
    return ListView.separated(
      padding: EdgeInsets.only(bottom: context.getHeight(20)),
      itemCount: states.length,
      separatorBuilder: (_, _) => SizedBox(height: context.getHeight(10)),
      itemBuilder: (context, index) {
        final state = states[index];

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(context.getWidth(20)),
            onTap: () => Navigator.pop(context, state),
            child: Ink(
              padding: EdgeInsets.all(context.getWidth(14)),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(context.getWidth(20)),
                border: Border.all(color: AppColors.divider),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: context.getWidth(48),
                    height: context.getWidth(48),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF5F7FA), Color(0xFFEDEFF5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(context.getWidth(16)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _stateCode(state),
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: context.getFontSize(AppDimens.fontS),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  SizedBox(width: context.getWidth(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: context.getFontSize(AppDimens.fontM),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: context.getHeight(4)),
                        Text(
                          'Tap to continue with $state',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: context.getFontSize(AppDimens.fontS),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: context.getWidth(10)),
                  Container(
                    width: context.getWidth(38),
                    height: context.getWidth(38),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(context.getWidth(12)),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.textSecondary,
                      size: context.getWidth(18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(context.getWidth(24)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(context.getWidth(24)),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: context.getWidth(58),
              height: context.getWidth(58),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(context.getWidth(18)),
              ),
              child: Icon(
                Icons.search_off_rounded,
                color: AppColors.primaryDark,
                size: context.getWidth(26),
              ),
            ),
            SizedBox(height: context.getHeight(14)),
            Text(
              'No states found',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: context.getFontSize(AppDimens.fontL),
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: context.getHeight(6)),
            Text(
              'Try a different keyword to find the state you want.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.getFontSize(AppDimens.fontS),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerIconButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(context.getWidth(14)),
        onTap: onTap,
        child: Ink(
          width: context.getWidth(44),
          height: context.getWidth(44),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(context.getWidth(14)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: context.getWidth(AppDimens.iconM),
          ),
        ),
      ),
    );
  }

  String _stateCode(String state) {
    return state
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0])
        .join()
        .toUpperCase();
  }
}
