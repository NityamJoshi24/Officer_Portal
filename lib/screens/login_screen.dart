import 'package:dcs_supervisor/screens/state_selector_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_colors.dart';
import '../core/app_dimensions.dart';
import '../core/app_state.dart';
import 'survey_list_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LoginScreen  —  3-step flow: Email → Password → OTP
// Matches the green/white design language of the rest of the app.
// ─────────────────────────────────────────────────────────────────────────────

enum _LoginStep { emailPassword, otp }

const List<String> _indianStates = [
  'Andhra Pradesh',
  'Arunachal Pradesh',
  'Assam',
  'Bihar',
  'Chhattisgarh',
  'Goa',
  'Gujarat',
  'Haryana',
  'Himachal Pradesh',
  'Jharkhand',
  'Karnataka',
  'Kerala',
  'Madhya Pradesh',
  'Maharashtra',
  'Manipur',
  'Meghalaya',
  'Mizoram',
  'Nagaland',
  'Odisha',
  'Punjab',
  'Rajasthan',
  'Sikkim',
  'Tamil Nadu',
  'Telangana',
  'Tripura',
  'Uttar Pradesh',
  'Uttarakhand',
  'West Bengal',
];

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  _LoginStep _step = _LoginStep.emailPassword;

  // Controllers
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _stateSearchCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrls = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());

  final _formKey = GlobalKey<FormState>();
  bool _obscurePass = true;
  bool _isLoading = false;
  String? _errorMsg;
  String? _selectedState;

  // Demo credentials
  static const _validEmail = 'supervisor@portal.com';
  static const _validPassword = 'Admin@123';
  static const _validOtp = '123456';

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _stateSearchCtrl.dispose();
    for (final c in _otpCtrls) {
      c.dispose();
    }
    for (final f in _otpFocus) {
      f.dispose();
    }
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Step 1: validate email + password ──────────────────────────────────
  Future<void> _submitCredentials() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    await Future.delayed(const Duration(milliseconds: 900));

    if (_emailCtrl.text.trim() == _validEmail &&
        _passCtrl.text == _validPassword) {
      setState(() {
        _step = _LoginStep.otp;
        _isLoading = false;
      });
      _fadeCtrl
        ..reset()
        ..forward();
      // Auto-focus first OTP box
      Future.delayed(
        const Duration(milliseconds: 100),
        () => _otpFocus[0].requestFocus(),
      );
    } else {
      setState(() {
        _errorMsg =
            'Invalid email or password. Try supervisor@portal.com / Admin@123';
        _isLoading = false;
      });
    }
  }

  // ── Step 2: validate OTP ──────────────────────────────────────────────
  Future<void> _submitOtp() async {
    final otp = _otpCtrls.map((c) => c.text).join();
    if (otp.length < 6) {
      setState(() => _errorMsg = 'Please enter all 6 digits.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    await Future.delayed(const Duration(milliseconds: 900));

    if (otp == _validOtp) {
      AppState.instance.login(_emailCtrl.text.trim(), state: _selectedState!);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const SurveyListScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } else {
      setState(() {
        _errorMsg = 'Incorrect OTP. Hint: use 123456';
        _isLoading = false;
        for (final c in _otpCtrls) {
          c.clear();
        }
      });
      _otpFocus[0].requestFocus();
    }
  }

  void _goBackToCredentials() {
    setState(() {
      _step = _LoginStep.emailPassword;
      _errorMsg = null;
      for (final c in _otpCtrls) {
        c.clear();
      }
    });
    _fadeCtrl
      ..reset()
      ..forward();
  }

  List<String> get _filteredStates {
    final query = _stateSearchCtrl.text.trim().toLowerCase();
    if (query.isEmpty) return _indianStates;
    return _indianStates
        .where((state) => state.toLowerCase().contains(query))
        .toList();
  }

  // ── BUILD ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: context.getWidth(24),
            vertical: context.getHeight(32),
          ),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: _step == _LoginStep.emailPassword
                ? _buildCredentialsForm()
                : _buildOtpForm(),
          ),
        ),
      ),
    );
  }

  // ── Logo + header ──────────────────────────────────────────────────────
  Widget _buildHeader({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo mark
        Container(
          width: context.getWidth(52),
          height: context.getWidth(52),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(context.getWidth(14)),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.dashboard_customize_rounded,
            color: AppColors.primaryDark,
            size: context.getWidth(28),
          ),
        ),
        SizedBox(height: context.getHeight(20)),
        Text(
          'SUPERVISOR PORTAL',
          style: TextStyle(
            fontSize: context.getFontSize(AppDimens.fontXS),
            color: AppColors.textMuted,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: context.getHeight(4)),
        Text(
          title,
          style: TextStyle(
            fontSize: context.getFontSize(AppDimens.fontXXL),
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.15,
          ),
        ),
        SizedBox(height: context.getHeight(8)),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: context.getFontSize(AppDimens.fontM),
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ── Credentials form ───────────────────────────────────────────────────
  Widget _buildCredentialsForm() {
    final isStateSelected = _selectedState != null;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(
            title: 'Welcome back',
            subtitle: 'Sign in to your supervisor account to continue.',
          ),
          SizedBox(height: context.getHeight(36)),

          _buildStateSelectorButton(),
          SizedBox(height: context.getHeight(24)),

          // Email
          _fieldLabel('Email address'),
          SizedBox(height: context.getHeight(6)),
          _buildTextField(
            controller: _emailCtrl,
            hint: 'supervisor@portal.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            enabled: isStateSelected,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          SizedBox(height: context.getHeight(16)),

          // Password
          _fieldLabel('Password'),
          SizedBox(height: context.getHeight(6)),
          _buildTextField(
            controller: _passCtrl,
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscure: _obscurePass,
            enabled: isStateSelected,
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscurePass = !_obscurePass),
              child: Icon(
                _obscurePass
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textMuted,
                size: context.getWidth(AppDimens.iconM),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          SizedBox(height: context.getHeight(8)),

          // Forgot password link
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              isStateSelected
                  ? 'Forgot password?'
                  : 'Select a state first to continue',
              style: TextStyle(
                fontSize: context.getFontSize(AppDimens.fontS),
                color: isStateSelected
                    ? AppColors.primaryDark
                    : AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: context.getHeight(24)),

          // Error
          if (_errorMsg != null) _buildErrorBanner(_errorMsg!),

          // Submit button
          _buildPrimaryButton(
            label: 'Continue',
            onTap: _isLoading || !isStateSelected ? null : _submitCredentials,
            loading: _isLoading,
          ),
          SizedBox(height: context.getHeight(32)),

          // Demo credentials hint
          _buildDemoHint('Demo credentials: supervisor@portal.com / Admin@123'),
        ],
      ),
    );
  }

  // ── State Selector form ───────────────────────────────────────────────────────────

  Widget _buildStateSelectorButton() {
    return GestureDetector(
      onTap: () async {
        final selected = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const StateSelectionScreen(),
          ),
        );

        if (selected != null) {
          setState(() {
            _selectedState = selected;
          });
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(context.getWidth(14)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(
              context.getWidth(AppDimens.radiusM)),
          border: Border.all(
            color: _selectedState == null
                ? AppColors.chipBorder
                : AppColors.primary,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on_outlined,
                color: AppColors.textMuted),
            SizedBox(width: context.getWidth(10)),
            Expanded(
              child: Text(
                _selectedState ?? 'Select State',
                style: TextStyle(
                  fontSize: context.getFontSize(AppDimens.fontM),
                  color: _selectedState == null
                      ? AppColors.textMuted
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: context.getWidth(14),
                color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildStateSelector() {
    final filteredStates = _filteredStates;
    final hasSearchQuery = _stateSearchCtrl.text.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.getWidth(16)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          context.getWidth(AppDimens.radiusM),
        ),
        border: Border.all(
          color: _selectedState == null
              ? AppColors.chipBorder
              : AppColors.primary.withValues(alpha: 0.35),
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select State',
                      style: TextStyle(
                        fontSize: context.getFontSize(AppDimens.fontL),
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: context.getHeight(4)),
                    Text(
                      _selectedState == null
                          ? 'Choose a state of India before entering login details.'
                          : 'Selected state: $_selectedState',
                      style: TextStyle(
                        fontSize: context.getFontSize(AppDimens.fontS),
                        color: _selectedState == null
                            ? AppColors.textSecondary
                            : AppColors.primaryDark,
                        fontWeight: _selectedState == null
                            ? FontWeight.w500
                            : FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedState != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.getWidth(10),
                    vertical: context.getHeight(6),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(context.getWidth(999)),
                  ),
                  child: Text(
                    'Ready',
                    style: TextStyle(
                      fontSize: context.getFontSize(AppDimens.fontXS + 1),
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: context.getHeight(14)),
          _buildTextField(
            controller: _stateSearchCtrl,
            hint: 'Search state',
            icon: Icons.search_rounded,
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: context.getHeight(12)),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: hasSearchQuery
                ? filteredStates.isEmpty
                    ? Padding(
                        key: const ValueKey('state-empty'),
                        padding: EdgeInsets.symmetric(
                          horizontal: context.getWidth(2),
                          vertical: context.getHeight(4),
                        ),
                        child: Text(
                          'No matching state found.',
                          style: TextStyle(
                            fontSize: context.getFontSize(AppDimens.fontS),
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : Wrap(
                        key: const ValueKey('state-suggestions'),
                        spacing: context.getWidth(8),
                        runSpacing: context.getHeight(8),
                        children: filteredStates.map((state) {
                          final isSelected = state == _selectedState;
                          return InkWell(
                            borderRadius: BorderRadius.circular(
                              context.getWidth(999),
                            ),
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                _selectedState = state;
                                _errorMsg = null;
                                _stateSearchCtrl.text = state;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: context.getWidth(12),
                                vertical: context.getHeight(10),
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryLight
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(
                                  context.getWidth(999),
                                ),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary.withValues(alpha: 0.4)
                                      : AppColors.divider,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    state,
                                    style: TextStyle(
                                      fontSize: context.getFontSize(
                                        AppDimens.fontS,
                                      ),
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? AppColors.primaryDark
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    SizedBox(width: context.getWidth(6)),
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.primary,
                                      size: context.getWidth(16),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      )
                : Text(
                    key: const ValueKey('state-hint'),
                    'Start typing to search and select a state.',
                    style: TextStyle(
                      fontSize: context.getFontSize(AppDimens.fontS),
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(
          title: 'Verify your\nidentity',
          subtitle: 'A 6-digit OTP has been sent to\n${_emailCtrl.text.trim()}',
        ),
        SizedBox(height: context.getHeight(36)),

        // OTP boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) => _buildOtpBox(i)),
        ),
        SizedBox(height: context.getHeight(24)),

        // Error
        if (_errorMsg != null) _buildErrorBanner(_errorMsg!),

        // Verify button
        _buildPrimaryButton(
          label: 'Verify OTP',
          onTap: _isLoading ? null : _submitOtp,
          loading: _isLoading,
        ),
        SizedBox(height: context.getHeight(20)),

        // Resend + back
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: _goBackToCredentials,
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back_rounded,
                    size: context.getWidth(14),
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: context.getWidth(4)),
                  Text(
                    'Change email',
                    style: TextStyle(
                      fontSize: context.getFontSize(AppDimens.fontS),
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Resend OTP',
              style: TextStyle(
                fontSize: context.getFontSize(AppDimens.fontS),
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: context.getHeight(32)),
        _buildDemoHint('Demo OTP: 123456'),
      ],
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: context.getWidth(44),
      height: context.getHeight(52),
      child: TextFormField(
        controller: _otpCtrls[index],
        focusNode: _otpFocus[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontSize: context.getFontSize(AppDimens.fontXL),
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              context.getWidth(AppDimens.radiusS),
            ),
            borderSide: const BorderSide(
              color: AppColors.chipBorder,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              context.getWidth(AppDimens.radiusS),
            ),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        onChanged: (val) {
          if (val.isNotEmpty && index < 5) {
            _otpFocus[index + 1].requestFocus();
          } else if (val.isEmpty && index > 0) {
            _otpFocus[index - 1].requestFocus();
          }
          if (index == 5 && val.isNotEmpty) {
            FocusScope.of(context).unfocus();
          }
        },
      ),
    );
  }

  // ── Shared widgets ─────────────────────────────────────────────────────
  Widget _fieldLabel(String text) => Text(
    text,
    style: TextStyle(
      fontSize: context.getFontSize(AppDimens.fontS),
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    bool enabled = true,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      enabled: enabled,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: context.getFontSize(AppDimens.fontM),
        color: enabled ? AppColors.textPrimary : AppColors.textMuted,
        fontWeight: FontWeight.w500,
      ),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.textHint,
          fontSize: context.getFontSize(AppDimens.fontM),
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(
            left: context.getWidth(12),
            right: context.getWidth(8),
          ),
          child: Icon(
            icon,
            color: AppColors.textMuted,
            size: context.getWidth(AppDimens.iconM),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: EdgeInsets.only(right: context.getWidth(12)),
                child: suffixIcon,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(),
        filled: true,
        fillColor: enabled
            ? AppColors.surface
            : AppColors.surface.withValues(alpha: 0.55),
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.getWidth(14),
          vertical: context.getHeight(14),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            context.getWidth(AppDimens.radiusS),
          ),
          borderSide: const BorderSide(color: AppColors.chipBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            context.getWidth(AppDimens.radiusS),
          ),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            context.getWidth(AppDimens.radiusS),
          ),
          borderSide: const BorderSide(color: AppColors.rejected, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            context.getWidth(AppDimens.radiusS),
          ),
          borderSide: const BorderSide(color: AppColors.rejected, width: 2),
        ),
        errorStyle: TextStyle(
          fontSize: context.getFontSize(AppDimens.fontXS),
          color: AppColors.rejected,
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback? onTap,
    bool loading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: context.getHeight(AppDimens.buttonH),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              context.getWidth(AppDimens.radiusS),
            ),
          ),
        ),
        child: loading
            ? SizedBox(
                width: context.getWidth(22),
                height: context.getWidth(22),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.getFontSize(AppDimens.fontM),
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildErrorBanner(String msg) {
    return Container(
      margin: EdgeInsets.only(bottom: context.getHeight(16)),
      padding: EdgeInsets.symmetric(
        horizontal: context.getWidth(12),
        vertical: context.getHeight(10),
      ),
      decoration: BoxDecoration(
        color: AppColors.rejectedBg,
        borderRadius: BorderRadius.circular(
          context.getWidth(AppDimens.radiusS),
        ),
        border: Border.all(color: AppColors.rejected.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: context.getWidth(16),
            color: AppColors.rejected,
          ),
          SizedBox(width: context.getWidth(8)),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(
                fontSize: context.getFontSize(AppDimens.fontXS + 1),
                color: AppColors.rejected,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoHint(String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.getWidth(14),
        vertical: context.getHeight(12),
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(
          context.getWidth(AppDimens.radiusS),
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: context.getWidth(14),
            color: AppColors.primaryDark,
          ),
          SizedBox(width: context.getWidth(8)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: context.getFontSize(AppDimens.fontXS + 1),
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
