import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/kisiler_controller.dart';
import '../models/kisi_model.dart';

/// Girişimci ve paydaşlar için video toplantı odası ekranı.
class VideoMeetingView extends StatefulWidget {
  final KisiModel? kisi;
  final KisilerController controller;

  const VideoMeetingView({
    super.key,
    this.kisi,
    required this.controller,
  });

  @override
  State<VideoMeetingView> createState() => _VideoMeetingViewState();
}

class _VideoMeetingViewState extends State<VideoMeetingView> {
  bool _isMicOn = true;
  bool _isCamOn = true;
  final _summaryController = TextEditingController();
  final _decisionsController = TextEditingController();

  @override
  void dispose() {
    _summaryController.dispose();
    _decisionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.kisi != null
        ? '${widget.kisi!.name} ile Görüşme'
        : 'Genel Ekip Video Toplantısı';

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(title, style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.note_add_outlined),
            tooltip: 'Toplantı Tutanağı Tut',
            onPressed: _showMeetingNoteDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildVideoGrid()),
          _buildControlBar(),
        ],
      ),
    );
  }

  Widget _buildVideoGrid() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(child: _participantTile(name: widget.kisi?.name ?? 'Paydaş / Katılımcı', isCamActive: true)),
          const SizedBox(height: 12),
          Expanded(child: _participantTile(name: 'Ben (Kurucu)', isCamActive: _isCamOn)),
        ],
      ),
    );
  }

  Widget _participantTile({required String name, required bool isCamActive}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Stack(
        children: [
          Center(
            child: isCamActive
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(radius: 36, backgroundColor: AppColors.primaryLeather, child: Text(name[0], style: const TextStyle(fontSize: 24, color: Colors.white))),
                      const SizedBox(height: 8),
                      Text(name, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  )
                : const Icon(Icons.videocam_off, size: 48, color: Colors.white38),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
              child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: AppColors.darkSurface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton.filledTonal(
            icon: Icon(_isMicOn ? Icons.mic : Icons.mic_off),
            onPressed: () => setState(() => _isMicOn = !_isMicOn),
          ),
          IconButton.filledTonal(
            icon: Icon(_isCamOn ? Icons.videocam : Icons.videocam_off),
            onPressed: () => setState(() => _isCamOn = !_isCamOn),
          ),
          IconButton.filled(
            style: IconButton.styleFrom(backgroundColor: AppColors.expenseRed),
            icon: const Icon(Icons.call_end, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showMeetingNoteDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Toplantı Tutanak & Not Kaydı'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _summaryController, maxLines: 3, decoration: const InputDecoration(labelText: 'Görüşme Özeti')),
              const SizedBox(height: 10),
              TextField(controller: _decisionsController, decoration: const InputDecoration(labelText: 'Alınan Kararlar')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Kapat')),
          FilledButton(
            onPressed: () {
              final summary = _summaryController.text.trim();
              if (summary.isNotEmpty) {
                widget.controller.addMeetingRecord(
                  title: '${widget.kisi?.name ?? 'Ekip'} Video Toplantısı',
                  participants: widget.kisi?.name ?? 'Ekip',
                  date: DateTime.now(),
                  durationMinutes: 25,
                  summaryNotes: summary,
                  decisions: _decisionsController.text.trim(),
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text('Depola & Kaydet'),
          ),
        ],
      ),
    );
  }
}
