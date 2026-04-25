import 'package:flutter/material.dart';
import 'package:segundoparcial/domain/notifier/auth_notifier.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl    = TextEditingController();
  final _apellidoCtrl  = TextEditingController();
  final _telefonoCtrl  = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  final _confirmCtrl   = TextEditingController();

  bool _isLoading        = false;
  bool _obscurePassword  = true;
  bool _obscureConfirm   = true;
  DateTime? _fechaNacimiento;

  // Estado post-registro cuando se necesita confirmar email
  bool   _waitingForConfirmation = false;
  String _registeredEmail        = '';

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaNacimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Selecciona tu fecha de nacimiento'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final autoLoggedIn = await AuthNotifier.instance.signUp(
        email:            _emailCtrl.text.trim(),
        password:         _passwordCtrl.text.trim(),
        nombre:           _nombreCtrl.text.trim(),
        apellido:         _apellidoCtrl.text.trim(),
        telefono:         _telefonoCtrl.text.trim(),
        fechaNacimiento:  _fechaNacimiento!.toIso8601String().split('T').first,
      );

      if (!mounted) return;

      if (autoLoggedIn) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          _registeredEmail       = _emailCtrl.text.trim();
          _waitingForConfirmation = true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendConfirmation() async {
    setState(() => _isLoading = true);
    try {
      await AuthNotifier.instance.resendConfirmationEmail(_registeredEmail);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Correo reenviado. Revisa tu bandeja de entrada.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  ButtonStyle get _buttonStyle => ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        padding: const EdgeInsets.symmetric(horizontal: 20),
      );

  @override
  Widget build(BuildContext context) {
    return _waitingForConfirmation
        ? _buildConfirmationWaiting(context)
        : _buildForm(context);
  }

  // ── Pantalla: esperando confirmación de email ─────────────────────────────
  Widget _buildConfirmationWaiting(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirma tu correo'),
        leading: BackButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mark_email_unread_rounded,
                  size: 80, color: colorScheme.primary),
              const SizedBox(height: 24),
              const Text('¡Cuenta creada!',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text('Te enviamos un correo de confirmación a:',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text(_registeredEmail,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                      fontSize: 15),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Text(
                'Haz clic en el enlace del correo y luego inicia sesión. '
                'Revisa también la carpeta de spam.',
                style: TextStyle(
                    color: colorScheme.onSurfaceVariant, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              OutlinedButton.icon(
                icon: const Icon(Icons.send_outlined),
                label: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Reenviar correo de confirmación'),
                onPressed: _isLoading ? null : _resendConfirmation,
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: _buttonStyle,
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
                child: const Text('Ya confirmé, ir a Iniciar Sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Formulario de registro ────────────────────────────────────────────────
  Widget _buildForm(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        leading: BackButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Icon(Icons.person_add_rounded,
                        size: 56, color: colorScheme.primary),
                    const SizedBox(height: 16),
                    const Text('Crear cuenta',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Completa tus datos para registrarte',
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 28),

                    // ── Nombre ───────────────────────────────────────────
                    _field(_nombreCtrl, 'Nombre', Icons.badge_outlined),

                    // ── Apellido ─────────────────────────────────────────
                    _field(_apellidoCtrl, 'Apellido', Icons.badge_outlined),

                    // ── Teléfono ─────────────────────────────────────────
                    _field(
                      _telefonoCtrl,
                      'Teléfono',
                      Icons.phone_outlined,
                      type: TextInputType.phone,
                    ),

                    // ── Fecha de nacimiento ──────────────────────────────
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Card(
                        child: ListTile(
                          leading: Icon(Icons.cake_outlined,
                              color: colorScheme.primary),
                          title: Text(
                            _fechaNacimiento == null
                                ? 'Fecha de nacimiento'
                                : _fechaNacimiento!
                                    .toIso8601String()
                                    .split('T')
                                    .first,
                            style: TextStyle(
                              color: _fechaNacimiento == null
                                  ? colorScheme.onSurfaceVariant
                                  : colorScheme.onSurface,
                            ),
                          ),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime(2000),
                              firstDate: DateTime(1920),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() => _fechaNacimiento = picked);
                            }
                          },
                        ),
                      ),
                    ),

                    // ── Correo ───────────────────────────────────────────
                    _field(
                      _emailCtrl,
                      'Correo',
                      Icons.email_outlined,
                      type: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Requerido';
                        if (!v.contains('@') || !v.contains('.')) {
                          return 'Correo inválido';
                        }
                        return null;
                      },
                    ),

                    // ── Contraseña ───────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requerido';
                          if (v.length < 6) return 'Mínimo 6 caracteres';
                          return null;
                        },
                      ),
                    ),

                    // ── Confirmar contraseña ─────────────────────────────
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: TextFormField(
                        controller: _confirmCtrl,
                        obscureText: _obscureConfirm,
                        decoration: InputDecoration(
                          labelText: 'Confirmar contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirm
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requerido';
                          if (v != _passwordCtrl.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),
                    ),

                    // ── Botón ────────────────────────────────────────────
                    ElevatedButton(
                      style: _buttonStyle,
                      onPressed: _isLoading ? null : _onRegister,
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text('Crear cuenta',
                              style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pushReplacementNamed(
                                context, '/login'),
                        child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: ctrl,
          keyboardType: type,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
          ),
          validator: validator ??
              (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
        ),
      );
}