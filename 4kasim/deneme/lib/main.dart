import 'package:flutter/material.dart';
import 'screens/storage_ve_fcm_ekrani.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  runApp(const SoftitioFcmUygulamasi());
}

class SoftitioFcmUygulamasi extends StatelessWidget {
  const SoftitioFcmUygulamasi({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Softito FCM Demo Uygulaması",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(0, 0, 0, 0),
          brightness: Brightness.light,
        ),
      ),
      home: const StorageveFcmEkrani(),
    );
  }
}
