import 'package:flutter/material.dart';
import '../controllers/kisiler_controller.dart';
import '../models/kisi_model.dart';
import '../widgets/kisi_card.dart';
import '../widgets/appointment_card.dart';
import '../widgets/meeting_record_card.dart';
import '../widgets/add_kisi_dialog.dart';
import '../widgets/add_randevu_dialog.dart';
import 'chat_view.dart';
import 'video_meeting_view.dart';

/// Kişiler, takvimli randevular ve video toplantı tutanakları ana ekranı.
class KisilerView extends StatelessWidget {
  final KisilerController controller;

  const KisilerView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 8),
          _buildSubTabSelector(),
          const SizedBox(height: 8),
          Expanded(child: _buildSelectedTabContent(context)),
        ],
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  Widget _buildSubTabSelector() {
    return ValueListenableBuilder<int>(
      valueListenable: controller.selectedSubTab,
      builder: (context, activeIndex, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('Kişiler'), icon: Icon(Icons.people_alt_outlined, size: 16)),
            ButtonSegment(value: 1, label: Text('Randevular'), icon: Icon(Icons.calendar_month_outlined, size: 16)),
            ButtonSegment(value: 2, label: Text('Tutanaklar'), icon: Icon(Icons.video_library_outlined, size: 16)),
          ],
          selected: {activeIndex},
          onSelectionChanged: (set) => controller.setSubTab(set.first),
        ),
      ),
    );
  }

  Widget _buildSelectedTabContent(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: controller.selectedSubTab,
      builder: (context, activeIndex, _) {
        if (activeIndex == 1) return _buildAppointmentsList(context);
        if (activeIndex == 2) return _buildMeetingRecordsList();
        return _buildContactsList(context);
      },
    );
  }

  Widget _buildContactsList(BuildContext context) {
    return ValueListenableBuilder<List<KisiModel>>(
      valueListenable: controller.kisiler,
      builder: (context, list, _) {
        if (list.isEmpty) return const Center(child: Text('Kayıtlı kişi bulunmuyor.'));
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final kisi = list[index];
            return KisiCard(
              kisi: kisi,
              onChat: () => Navigator.push<void>(context, MaterialPageRoute(builder: (_) => ChatView(kisi: kisi, controller: controller))),
              onVideoMeeting: () => Navigator.push<void>(context, MaterialPageRoute(builder: (_) => VideoMeetingView(kisi: kisi, controller: controller))),
              onAddAppointment: () => _showAddRandevu(context, defaultKisiId: kisi.id),
              onDelete: () => controller.deleteKisi(kisi.id),
            );
          },
        );
      },
    );
  }

  Widget _buildAppointmentsList(BuildContext context) {
    return ValueListenableBuilder<List<RandevuModel>>(
      valueListenable: controller.randevular,
      builder: (context, list, _) {
        if (list.isEmpty) return const Center(child: Text('Planlanmış randevu bulunmuyor.'));
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            return AppointmentCard(randevu: item, onCancel: () => controller.cancelRandevu(item.id));
          },
        );
      },
    );
  }

  Widget _buildMeetingRecordsList() {
    return ValueListenableBuilder<List<MeetingRecordModel>>(
      valueListenable: controller.meetingRecords,
      builder: (context, list, _) {
        if (list.isEmpty) return const Center(child: Text('Depolanmış toplantı kaydı yok.'));
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final record = list[index];
            return MeetingRecordCard(record: record, onDelete: () => controller.deleteMeetingRecord(record.id));
          },
        );
      },
    );
  }

  Widget _buildFab(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: controller.selectedSubTab,
      builder: (context, tab, _) {
        if (tab == 1) {
          return FloatingActionButton.extended(
            onPressed: () => _showAddRandevu(context),
            icon: const Icon(Icons.add_alarm),
            label: const Text('Randevu Ekle'),
          );
        }
        if (tab == 2) {
          return FloatingActionButton.extended(
            onPressed: () => Navigator.push<void>(context, MaterialPageRoute(builder: (_) => VideoMeetingView(controller: controller))),
            icon: const Icon(Icons.video_call),
            label: const Text('Toplantı Başlat'),
          );
        }
        return FloatingActionButton.extended(
          onPressed: () => _showAddKisi(context),
          icon: const Icon(Icons.person_add),
          label: const Text('Kişi Ekle'),
        );
      },
    );
  }

  void _showAddKisi(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AddKisiDialog(onAdd: controller.addKisi),
    );
  }

  void _showAddRandevu(BuildContext context, {String? defaultKisiId}) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AddRandevuDialog(
        kisiler: controller.kisiler.value,
        defaultKisiId: defaultKisiId,
        onAdd: controller.addRandevu,
      ),
    );
  }
}
