import 'package:flutter/material.dart';
import 'package:segundoparcial/config/theme/app_theme.dart';
import 'package:segundoparcial/domain/products_notifier.dart';
import 'package:segundoparcial/presentation/screens/home/home_screen.dart';
import 'package:segundoparcial/presentation/screens/scrool/infinite_scrool.dart';
import 'package:segundoparcial/presentation/screens/formulario/formulario.dart';

void main() {
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
            '/':            (context) => const HomeScreen(),
            '/productos':   (context) => const InfiniteScroll(),
            '/formulario':  (context) => const Formulario(),
          },
        );
      },
    );
  }
}