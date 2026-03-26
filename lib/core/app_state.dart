// ─────────────────────────────────────────────────────────────────────────────
// AppState — lightweight singleton that holds:
//   • auth state (logged-in user)
//   • persistent filter state so filters survive navigation
// ─────────────────────────────────────────────────────────────────────────────

class LoggedInUser {
  final String email;
  final String name;
  const LoggedInUser({required this.email, required this.name});
}

class FilterState {
  String talukaFilter; // '' means no filter
  String villageFilter; // '' means no filter
  String statusFilter; // 'ALL' | 'PENDING' | 'APPROVED' | 'REJECTED'

  FilterState({
    this.talukaFilter = '',
    this.villageFilter = '',
    this.statusFilter = 'ALL',
  });

  bool get hasActiveFilter =>
      talukaFilter.isNotEmpty ||
      villageFilter.isNotEmpty ||
      statusFilter != 'ALL';

  void reset() {
    talukaFilter = '';
    villageFilter = '';
    statusFilter = 'ALL';
  }
}

class AppState {
  AppState._();
  static final AppState instance = AppState._();

  LoggedInUser? currentUser;
  String? selectedState;
  final FilterState filters = FilterState();

  bool get isLoggedIn => currentUser != null;

  void login(String email, {required String state}) {
    // Derive a display name from the email
    final name = email
        .split('@')
        .first
        .split('.')
        .map((p) => p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1))
        .join(' ');
    currentUser = LoggedInUser(email: email, name: name);
    selectedState = state;
  }

  void logout() {
    currentUser = null;
    selectedState = null;
    filters.reset();
  }
}
