import 'package:flutter/material.dart';
import 'screens/urun_listesi_ekrani.dart';
void main() {
  runApp(const MiniMagazaUygulamasi());
}

class MiniMagazaUygulamasi extends StatelessWidget {
  const MiniMagazaUygulamasi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Mini Mağaza",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
      ),
      // home parametresi MaterialApp'in içine alındı:
      home: const UrunListesiEkrani(
      ),
    ); // MaterialApp burada kapanmalı
  }
}