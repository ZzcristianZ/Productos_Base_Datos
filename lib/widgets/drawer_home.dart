import 'package:flutter/material.dart';
import 'package:segundoparcial/domain/notifier/auth_notifier.dart';

class DrawerHome extends StatelessWidget {
  const DrawerHome({super.key});

  @override
  Widget build(BuildContext context) {
    final auth         = AuthNotifier.instance;
    final colorScheme  = Theme.of(context).colorScheme;

    final nombre    = auth.nombre.isNotEmpty   ? auth.nombre   : 'Sin nombre';
    final apellido  = auth.apellido.isNotEmpty  ? auth.apellido : 'No disponible';
    final email     = auth.email.isNotEmpty     ? auth.email    : 'Sin correo';
    final telefono  = auth.telefono.isNotEmpty  ? auth.telefono : 'No disponible';
    final fechaNac  = auth.fechaNacimiento.isNotEmpty
        ? auth.fechaNacimiento
        : 'No disponible';
    final avatarUrl = auth.avatarUrl;

    // Iniciales para cuando no hay foto de perfil
    final iniciales = [
      if (auth.nombre.isNotEmpty)   auth.nombre[0].toUpperCase(),
      if (auth.apellido.isNotEmpty) auth.apellido[0].toUpperCase(),
    ].join();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),

            // ── Avatar ───────────────────────────────────────────────────
            CircleAvatar(
              radius: 50,
              backgroundColor: colorScheme.primaryContainer,
              backgroundImage:
                  avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
              child: avatarUrl.isEmpty
                  ? Text(
                      iniciales.isNotEmpty ? iniciales : '?',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 15),

            // ── Nombre completo ──────────────────────────────────────────
            Text(
              '$nombre $apellido'.trim(),
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // ── Email ────────────────────────────────────────────────────
            Text(
              email,
              style: TextStyle(
                  fontSize: 13, color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            const Divider(indent: 24, endIndent: 24),
            const SizedBox(height: 8),

            // ── Datos adicionales ────────────────────────────────────────
            _InfoRow(
              label: 'Apellido',
              value: apellido,
              icon: Icons.badge_outlined,
            ),
            _InfoRow(
              label: 'Fecha de nacimiento',
              value: fechaNac,
              icon: Icons.cake_outlined,
            ),
            _InfoRow(
              label: 'Teléfono',
              value: telefono,
              icon: Icons.phone_outlined,
            ),

            const Spacer(),
            const Divider(indent: 24, endIndent: 24),

            // ── Cerrar sesión ────────────────────────────────────────────
            ListTile(
              leading: Icon(Icons.logout, color: colorScheme.error),
              title: Text(
                'Cerrar sesión',
                style: TextStyle(color: colorScheme.error),
              ),
              onTap: () async {
                Navigator.pop(context);
                await AuthNotifier.instance.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String   label;
  final String   value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}