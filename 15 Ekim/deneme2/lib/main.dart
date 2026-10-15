import 'package:flutter/material.dart';

import 'screen/layout_screen.dart';
import 'screen/market_list_screen.dart';
import 'screen/transfer_form_screen.dart';

void main() {
  runApp(const DtmMasterApp());
}

class DtmMasterApp extends StatelessWidget {
  const DtmMasterApp({
    super.key,
  }); // super verdiğimiz Stateless'e key i gönderir.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "DTM Flutter Sınıfı",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
      ),
      home: const LiveCanvasScreen(),
    );
  }
}

class LiveCanvasScreen extends StatefulWidget {
  const LiveCanvasScreen({super.key});

  @override
  State<LiveCanvasScreen> createState() => _LiveCanvasScreenState();
}

class _LiveCanvasScreenState extends State<LiveCanvasScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FaFC),
      appBar: AppBar(
        title: const Text(
          "DTM Canlı Arayüz",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () {},
          ),
        ],
      ), // AppBar
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: const [
            LayoutStylingScreen(),
            MarketsGridListScreen(),
            TransferFormScreen(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart),
            label: 'Piyasalar',
          ),
          NavigationDestination(
            icon: Icon(Icons.send_outlined),
            selectedIcon: Icon(Icons.send),
            label: 'Transfer',
          ),
        ],
      ),
    );
  }
}