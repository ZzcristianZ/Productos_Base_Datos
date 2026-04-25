import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthNotifier extends ChangeNotifier {
  AuthNotifier._() {
    _session = Supabase.instance.client.auth.currentSession;
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _session = data.session;
      notifyListeners();
    });
  }

  static final AuthNotifier instance = AuthNotifier._();

  Session? _session;
  bool get isLoggedIn => _session != null;
  String? get userEmail => _session?.user.email;

  // ── Getters de user_metadata ──────────────────────────────────────────────
  User? get _user => Supabase.instance.client.auth.currentUser;

  String get email     => _user?.email ?? '';
  String get nombre    => _user?.userMetadata?['nombre']           as String? ??
                          _user?.userMetadata?['full_name']         as String? ?? '';
  String get apellido  => _user?.userMetadata?['apellido']          as String? ?? '';
  String get telefono  => _user?.userMetadata?['telefono']          as String? ?? '';
  String get fechaNacimiento => _user?.userMetadata?['fecha_nacimiento'] as String? ?? '';
  String get avatarUrl => _user?.userMetadata?['avatar_url']        as String? ?? '';

  Future<void> signIn(String email, String password) async {
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthApiException catch (e) {
      throw Exception(_mapAuthError(e));
    } catch (_) {
      throw Exception(
        'No se pudo conectar. Verifica tu internet e intenta de nuevo.',
      );
    }
  }

  /// Registra el usuario y guarda sus datos personales en user_metadata.
  /// Retorna true si quedó con sesión activa (email confirmation desactivado).
  Future<bool> signUp({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required String telefono,
    required String fechaNacimiento,
  }) async {
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'nombre':            nombre,
          'apellido':          apellido,
          'telefono':          telefono,
          'fecha_nacimiento':  fechaNacimiento,
        },
      );

      final user = response.user;
      if (user == null) {
        throw Exception('No se pudo crear la cuenta. Intenta de nuevo.');
      }

      if (user.identities != null && user.identities!.isEmpty) {
        throw Exception(
          'Este correo ya está registrado. Intenta iniciar sesión.',
        );
      }

      return response.session != null;
    } on AuthApiException catch (e) {
      throw Exception(_mapAuthError(e));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(
        'No se pudo conectar. Verifica tu internet e intenta de nuevo.',
      );
    }
  }

  Future<void> resendConfirmationEmail(String email) async {
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } on AuthApiException catch (e) {
      throw Exception(_mapAuthError(e));
    } catch (_) {
      throw Exception(
        'No se pudo reenviar el correo. Verifica tu internet e intenta de nuevo.',
      );
    }
  }

  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {
      notifyListeners();
    }
  }

  String _mapAuthError(AuthApiException e) {
    final msg  = e.message.toLowerCase();
    final code = e.statusCode ?? '';

    if (code == '429' || msg.contains('rate limit') || msg.contains('too many')) {
      return 'Demasiados intentos. Espera unos minutos antes de volver a intentarlo.';
    }
    if (msg.contains('email not confirmed') || msg.contains('not confirmed')) {
      return 'EMAIL_NOT_CONFIRMED';
    }
    if (msg.contains('invalid login') ||
        msg.contains('invalid credentials') ||
        msg.contains('invalid email or password')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (msg.contains('user not found')) {
      return 'No existe una cuenta con este correo.';
    }
    if (msg.contains('user already registered') || msg.contains('already registered')) {
      return 'Este correo ya está registrado. Intenta iniciar sesión.';
    }
    if (msg.contains('weak') && msg.contains('password')) {
      return 'La contraseña es muy débil. Usa al menos 6 caracteres.';
    }
    if (msg.contains('signup') && msg.contains('disabled')) {
      return 'El registro está deshabilitado temporalmente.';
    }
    if (msg.contains('network') || msg.contains('connection') || msg.contains('failed host')) {
      return 'Error de conexión. Verifica tu internet.';
    }

    return 'Error: ${e.message}';
  }
}