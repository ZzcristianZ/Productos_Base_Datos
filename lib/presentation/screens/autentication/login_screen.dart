import 'package:flutter/material.dart';
import 'package:segundoparcial/domain/notifier/auth_notifier.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool obscurePassword = true;

  // Se activa cuando el error es "email no confirmado"
  bool _showResendOption = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      isLoading = true;
      _showResendOption = false;
    });

    try {
      await AuthNotifier.instance.signIn(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;

      final errorMsg = e.toString().replaceAll('Exception: ', '');
      final isNotConfirmed = errorMsg == 'EMAIL_NOT_CONFIRMED';

      setState(() => _showResendOption = isNotConfirmed);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isNotConfirmed
                ? '📧 Debes confirmar tu correo antes de iniciar sesión.'
                : '❌ $errorMsg',
          ),
          backgroundColor: isNotConfirmed ? Colors.orange : Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _resendConfirmation() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe tu correo primero'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      await AuthNotifier.instance.resendConfirmationEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '✅ Correo de confirmación reenviado. Revisa tu bandeja.',
          ),
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
      if (mounted) setState(() => isLoading = false);
    }
  }

  ButtonStyle get _buttonStyle => ElevatedButton.styleFrom(
    minimumSize: const Size(double.infinity, 50),
    padding: const EdgeInsets.symmetric(horizontal: 20),
  );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
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
                    const SizedBox(height: 40),
                    const Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Ingresa tus credenciales para continuar',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),

                    // ── Correo ──────────────────────────────────────────────
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) {
                        if (_showResendOption) {
                          setState(() => _showResendOption = false);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Correo',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El correo es obligatorio';
                        }
                        if (!value.contains('@')) return 'Correo inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // ── Contraseña ──────────────────────────────────────────
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setState(
                            () => obscurePassword = !obscurePassword,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La contraseña es obligatoria';
                        }
                        if (value.length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    // ── Botón ingresar ──────────────────────────────────────
                    ElevatedButton(
                      style: _buttonStyle,
                      onPressed: isLoading ? null : onLogin,
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text('Ingresar'),
                    ),

                    // ── Banner "confirma tu correo" ─────────────────────────
                    if (_showResendOption) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.mark_email_unread_outlined,
                                  color: colorScheme.onSecondaryContainer,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Correo no confirmado',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Revisa tu bandeja de entrada (y la carpeta de spam). '
                              'Si no lo encuentras, reenvíalo.',
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.send_outlined, size: 18),
                                label: const Text(
                                  'Reenviar correo de confirmación',
                                ),
                                onPressed: isLoading
                                    ? null
                                    : _resendConfirmation,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.pushReplacementNamed(
                                context,
                                '/register',
                              ),
                        child: const Text('¿No tienes cuenta? Regístrate'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
