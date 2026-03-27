import 'package:dcs_supervisor/screens/state_selector_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/commons/app_colors.dart';
import '../core/commons/app_dimensions.dart';
import '../core/commons/app_toast.dart';
import '../core/providers.dart';
import 'survey_list_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LoginScreen  —  3-step flow: Mobile Number → Password → OTP
// Matches the green/white design language of the rest of the app.
// ─────────────────────────────────────────────────────────────────────────────

enum _LoginStep { mobilePassword, otp }



class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  _LoginStep _step = _LoginStep.mobilePassword;

  // Controllers
  final _mobileCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
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

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  String? _userToken;

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
    _mobileCtrl.dispose();
    _passCtrl.dispose();
    for (final c in _otpCtrls) {
      c.dispose();
    }
    for (final f in _otpFocus) {
      f.dispose();
    }
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitCredentials() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

      try {
        final apiManager = ref.read(apiManagerProvider);
        final result = await apiManager.verifyCredentials(
          _mobileCtrl.text.trim(),
          _passCtrl.text,
        );

        if (!result.isSuccess) {
          AppToast.error(result.error ?? 'Invalid credentials');
          setState(() {
            _errorMsg = result.error ?? 'Invalid credentials';
            _isLoading = false;
          });
          return;
        }

        _userToken = apiManager.extractSessionToken(result.data);
        debugPrint(
          '[Login] verifyCredentials success for ${_mobileCtrl.text.trim()}: ${result.data}',
        );
        debugPrint(
          '[Login] extracted credential token: ${_userToken != null && _userToken!.isNotEmpty}',
        );

        setState(() {
          _step = _LoginStep.otp;
          _isLoading = false;
        });

      _fadeCtrl
        ..reset()
        ..forward();

      Future.delayed(
        const Duration(milliseconds: 100),
        () => _otpFocus[0].requestFocus(),
      );
      } catch (e) {
        AppToast.error(e.toString());
        setState(() {
          _errorMsg = e.toString();
          _isLoading = false;
        });
      }
  }

  Future<void> _submitOtp() async {
    final otp = _otpCtrls.map((c) => c.text).join();
    if (otp.length < 6) {
      AppToast.error('Please enter all 6 digits.');
      setState(() => _errorMsg = 'Please enter all 6 digits.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

      try {
        final apiManager = ref.read(apiManagerProvider);
        final result = await apiManager.mobileLogin(
          token: _userToken,
          otp: otp,
          password: _passCtrl.text,
        mobile: _mobileCtrl.text.trim(),
      );

        if (!result.isSuccess) {
          AppToast.error(result.error ?? 'OTP verification failed');
          setState(() {
            _errorMsg = result.error ?? 'OTP verification failed';
            _isLoading = false;
          });
          return;
        }

        final data = result.data;
        final isVerified = apiManager.isOtpVerified(data);
        debugPrint('[Login] mobileLogin response: $data');
        debugPrint('[Login] OTP verified: $isVerified');

        if (!isVerified) {
          AppToast.error(apiManager.extractMessage(data) ?? 'Invalid OTP');
          setState(() {
            _errorMsg = apiManager.extractMessage(data) ?? 'Invalid OTP';
              _isLoading = false;
            for (final c in _otpCtrls) {
              c.clear();
          }
        });
        _otpFocus[0].requestFocus();
        return;
        }

        debugPrint(
          '[Login] Login completed for ${_mobileCtrl.text.trim()} in state $_selectedState',
        );
        AppToast.success('Login successful');
        final user = apiManager.parseUser(data);
        if (user == null) {
          AppToast.error('Failed to read user data. Please try again.');
          setState(() {
            _isLoading = false;
          });
          return;
        }
        apiManager.api.setAuthToken(user.userToken);

        await ref.read(authControllerProvider.notifier).login(user);
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
      } catch (e) {
        AppToast.error(e.toString());
        setState(() {
          _errorMsg = e.toString();
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
      _step = _LoginStep.mobilePassword;
      _errorMsg = null;
      for (final c in _otpCtrls) {
        c.clear();
      }
    });
    _fadeCtrl
      ..reset()
      ..forward();
  }


  // BUILD ──────────────────────────────────────────────────────────────
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
            child: _step == _LoginStep.mobilePassword
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

          _fieldLabel('Mobile number'),
          SizedBox(height: context.getHeight(6)),
          _buildTextField(
            controller: _mobileCtrl,
            hint: 'Enter 10-digit mobile number',
            icon: Icons.phone_iphone_rounded,
            keyboardType: TextInputType.phone,
            enabled: isStateSelected,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (v) {
              final value = v?.trim() ?? '';
              if (value.isEmpty) return 'Mobile number is required';
              if (value.length != 10) return 'Enter a valid 10-digit mobile number';
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

  Widget _buildOtpForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(
          title: 'Verify your\nidentity',
          subtitle:
              'A 6-digit OTP has been sent to\n${_mobileCtrl.text.trim()}',
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
                    'Change login details',
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
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      enabled: enabled,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: context.getFontSize(AppDimens.fontM),
        color: enabled ? AppColors.textPrimary : AppColors.textMuted,
        fontWeight: FontWeight.w500,
      ),
      validator: validator,
      decoration: InputDecoration(
        counterText: '',
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
}



