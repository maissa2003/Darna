import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/box_names.dart';
import '../../../core/utils/password_hasher.dart';
import '../models/app_user.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class AuthRepository {
  Box<AppUser> get _users => Hive.box<AppUser>(BoxNames.users);
  Box get _session => Hive.box(BoxNames.session);

  AppUser? get currentUser {
    final id = _session.get('current_user_id') as String?;
    return id == null ? null : _users.get(id);
  }

  Future<AppUser> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String role,
    required String gender,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (_users.values.any((u) => u.email == normalizedEmail)) {
      throw AuthException('Cet email est déjà utilisé.');
    }
    final user = AppUser(
      id: const Uuid().v4(),
      fullName: fullName.trim(),
      email: normalizedEmail,
      phone: phone.trim(),
      passwordHash: PasswordHasher.hash(password),
      role: role,
      gender: gender,
      createdAt: DateTime.now(),
    );
    await _users.put(user.id, user);
    await _session.put('current_user_id', user.id);
    return user;
  }

  Future<AppUser> login(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    final matches = _users.values.where((u) => u.email == normalizedEmail);
    if (matches.isEmpty || !PasswordHasher.verify(password, matches.first.passwordHash)) {
      throw AuthException('Email ou mot de passe incorrect.');
    }
    final user = matches.first;
    await _session.put('current_user_id', user.id);
    return user;
  }

  Future<void> logout() => _session.delete('current_user_id');
}