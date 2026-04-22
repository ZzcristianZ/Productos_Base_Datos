import 'package:flutter/material.dart';
import 'package:segundoparcial/domain/notifier/auth_notifier.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      resizeToAvoidBottomInset: true, 
      appBar: AppBar(
        title: const Text('Segundo Parcial'),
        centerTitle: true,
        backgroundColor: colorScheme.surfaceContainerLow,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await AuthNotifier.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight * 0.75, 
            ),
            child: IntrinsicHeight( 
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: EdgeInsets.all(screenHeight * 0.025),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.school_rounded,
                            size: screenHeight * 0.06,
                            color: colorScheme.onPrimaryContainer,
                          ),
                          SizedBox(height: screenHeight * 0.012),
                          Text(
                            'Segundo Parcial',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenHeight * 0.032, 
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.007),
                          Text(
                            'Ingreso de Productos a base de datos',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenHeight * 0.017,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.035),

                    _studentCard(
                      colorScheme,
                      screenHeight: screenHeight,
                      name: 'Cristian Areniz Coronel',
                      code: '192337',
                    ),
                    SizedBox(height: screenHeight * 0.018),
                    _studentCard(
                      colorScheme,
                      screenHeight: screenHeight,
                      name: 'Andrés Guevara Contreras',
                      code: '192413',
                    ),

                    SizedBox(height: screenHeight * 0.045),

                    // --- Botón ---
                    ElevatedButton.icon(
                      icon: const Icon(Icons.inventory_2, size: 20),
                      label: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.018, 
                        ),
                        child: Text(
                          'Ver Productos',
                          style: TextStyle(fontSize: screenHeight * 0.02),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/productos'),
                    ),

                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _studentCard(
    ColorScheme colors, {
    required double screenHeight,
    required String name,
    required String code,
  }) {
    return Card(
      elevation: 0,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 18,
          vertical: screenHeight * 0.018,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: screenHeight * 0.032,
              backgroundColor: colors.secondaryContainer,
              child: Icon(
                Icons.person,
                color: colors.onSecondaryContainer,
                size: screenHeight * 0.036,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: screenHeight * 0.021,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    'Código: $code',
                    style: TextStyle(
                      fontSize: screenHeight * 0.016,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}