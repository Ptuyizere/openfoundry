import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openfoundry/core/constants/enums.dart';
import 'package:openfoundry/data/models/app_user.dart';
import 'package:openfoundry/data/repositories/auth_repository.dart';
import 'package:openfoundry/data/repositories/user_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, needsProfile, error }

class AuthState extends Equatable {
  const AuthState._({
    required this.status,
    this.user,
    this.message,
  });

  const AuthState.initial() : this._(status: AuthStatus.initial);
  const AuthState.loading() : this._(status: AuthStatus.loading);
  const AuthState.unauthenticated() : this._(status: AuthStatus.unauthenticated);
  const AuthState.needsProfile() : this._(status: AuthStatus.needsProfile);
  const AuthState.authenticated(AppUser user)
      : this._(status: AuthStatus.authenticated, user: user);
  const AuthState.error(String message)
      : this._(status: AuthStatus.error, message: message);

  final AuthStatus status;
  final AppUser? user;
  final String? message;

  @override
  List<Object?> get props => [status, user, message];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this.authRepository,
    required this.userRepository,
  }) : super(const AuthState.initial());

  final AuthRepository authRepository;
  final UserRepository userRepository;

  User? _firebaseUser;
  AppUser? _appUser;

  AppUser? get currentUser => _appUser;
  bool get isAuthenticated => _firebaseUser != null;

  void checkSession() {
    authRepository.authChanges.listen((user) async {
      if (user == null) {
        _firebaseUser = null;
        _appUser = null;
        emit(const AuthState.unauthenticated());
      } else {
        _firebaseUser = user;
        await _loadAppUser(user.uid);
      }
    });
  }

  Future<void> _loadAppUser(String uid) async {
    emit(const AuthState.loading());
    try {
      final user = await userRepository.read(uid);
      if (user != null) {
        _appUser = user;
        emit(AuthState.authenticated(user));
        _watchUser(uid);
      } else {
        emit(const AuthState.needsProfile());
      }
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  void _watchUser(String uid) {
    userRepository.watch(uid).listen((user) {
      if (user != null) {
        _appUser = user;
        if (state.status == AuthStatus.authenticated) {
          emit(AuthState.authenticated(user));
        }
      }
    });
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
  }) async {
    emit(const AuthState.loading());
    try {
      final user = await authRepository.signUp(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role,
      );
      final appUser = AppUser(
        id: user.uid,
        name: name,
        email: email.trim(),
        phone: phone,
        role: role,
        createdAt: DateTime.now(),
      );
      await userRepository.create(appUser);
      _firebaseUser = user;
      _appUser = appUser;
      emit(AuthState.authenticated(appUser));
      _watchUser(user.uid);
    } on FirebaseAuthException catch (e) {
      emit(AuthState.error(e.message ?? e.code));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(const AuthState.loading());
    try {
      final user = await authRepository.signIn(
        email: email,
        password: password,
      );
      _firebaseUser = user;
      await _loadAppUser(user.uid);
    } on FirebaseAuthException catch (e) {
      emit(AuthState.error(e.message ?? e.code));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> signOut() async {
    await authRepository.signOut();
    _firebaseUser = null;
    _appUser = null;
    emit(const AuthState.unauthenticated());
  }

  Future<void> refresh() async {
    final uid = _firebaseUser?.uid;
    if (uid != null) {
      await _loadAppUser(uid);
    }
  }
}


