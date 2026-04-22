import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:segundoparcial/config/theme/app_theme.dart';
import 'package:segundoparcial/config/const/api_constants.dart';
import 'domain/notifier/auth_notifier.dart';
import 'domain/notifier/products_notifier.dart';
import 'package:segundoparcial/presentation/screens/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: ApiConstants.supabaseUrl,
    anonKey: ApiConstants.anonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ProductsNotifier.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'Productos App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme(selectedColor: 4).getTheme(),
          initialRoute: '/',
          routes: {
            '/': (context) => const _AuthGate(),
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/productos': (context) => const InfiniteScroll(),
            '/formulario': (context) => const Formulario(),
          },
        );
      },
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AuthNotifier.instance.isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
