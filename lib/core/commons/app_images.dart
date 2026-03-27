/// Central registry for every image / icon / lottie path in the app.
/// Usage:  Image.asset(AppImages.logoMark)
class AppImages {
  AppImages._();

  // ── Base paths ─────────────────────────────────────
  static const String _png    = 'assets/images';
  static const String _svg    = 'assets/svg';
  static const String _lottie = 'assets/lottie';

  // ── Logos & branding ───────────────────────────────
  static const String logoMark       = '$_png/logo_mark.png';
  static const String logoFull       = '$_png/logo_full.png';

  // ── Placeholders ───────────────────────────────────
  static const String avatarDefault  = '$_png/avatar_placeholder.png';
  static const String mapPlaceholder = '$_png/map_placeholder.png';
  static const String emptyState     = '$_png/empty_state.png';

  // ── Survey ─────────────────────────────────────────
  static const String surveyBanner   = '$_png/survey_banner.png';
  static const String farmPlot       = '$_png/farm_plot.png';

  // ── SVG icons (use flutter_svg package) ────────────
  static const String iconTaluka     = '$_svg/ic_taluka.svg';
  static const String iconVillage    = '$_svg/ic_village.svg';
  static const String iconPlot       = '$_svg/ic_plot.svg';

  // ── Lottie animations ──────────────────────────────
  static const String loadingDots    = '$_lottie/loading_dots.json';
  static const String successCheck   = '$_lottie/success_check.json';
  static const String emptyBox       = '$_lottie/empty_box.json';
}