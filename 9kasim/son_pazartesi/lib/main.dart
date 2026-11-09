import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/cuzdan_bloc.dart';
import 'bloc/cuzdan_event.dart';
import 'screens/cuzdan_ekrani.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MiniCuzdan());
}

class MiniCuzdan extends StatelessWidget {
  const MiniCuzdan({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CuzdanBloc()..add(const CuzdanYukleEvent()),
      child: MaterialApp(
        title: 'Mini Cuzdan',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 244, 4, 168),
          ),
          useMaterial3: true,
          fontFamily: 'Playwrite',
        ),
        home: const CuzdanEkrani(),
      ),
    );
  }
}

