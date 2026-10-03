import 'package:flutter/foundation.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/models/app_user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;
  AppUser? _user;

  AuthProvider(this._repo) {
    _user = _repo.currentUser;
  }

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;

  Future<String?> login(String email, String password) async {
    try {
      _user = await _repo.login(email, password);
      notifyListeners();
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String role,
    required String gender,
  }) async {
    try {
      _user = await _repo.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        role: role,
        gender: gender,
      );
      notifyListeners();
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    _user = null;
    notifyListeners();
  }

    bool get onboardingDone => _repo.onboardingDone;
  Future<void> completeOnboarding() => _repo.setOnboardingDone();

  Future<String?> updateProfile({
    required String fullName,
    required String phone,
    String? university,
    String? city,
    String? avatar,
  }) async {
    try {
      _user = await _repo.updateProfile(
        fullName: fullName,
        phone: phone,
        university: university,
        city: city,
        avatar: avatar,
      );
      notifyListeners();
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> changePassword(
      String oldPassword, String newPassword) async {
    try {
      await _repo.changePassword(oldPassword, newPassword);
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }
}