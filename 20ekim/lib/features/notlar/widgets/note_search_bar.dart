import 'package:flutter/material.dart';

/// Notlar ve raporlar arasında metin araması yapan arama kutusu.
class NoteSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const NoteSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Notlarda, raporlarda veya fikirlerde ara...',
          prefixIcon: const Icon(Icons.search, size: 20),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
