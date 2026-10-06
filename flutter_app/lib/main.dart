// package: importa dependencias; las otras rutas son archivos propios.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/products/presentation/pages/products_page.dart';

void main() {
  // ProviderScope administra los providers de la aplicación.
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  // const permite crear este widget como constante.
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Catálogo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: const Color(0xff176b64)),
      home: const ProductsPage(),
    );
  }
}
