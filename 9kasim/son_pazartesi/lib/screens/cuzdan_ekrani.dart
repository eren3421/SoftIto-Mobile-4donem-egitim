// [SATIR 1] Temel Flutter ve BLoC kütüphanelerini dahil ediyoruz.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cuzdan_bloc.dart';
import '../bloc/cuzdan_event.dart';
import '../bloc/cuzdan_state.dart';
import '../widgets/bakiye_karti.dart';
import '../widgets/islem_satiri.dart';

class CuzdanEkrani extends StatelessWidget {
  const CuzdanEkrani({super.key});

  void _islemEkleModaliniAc(BuildContext context, bool gelirMi) {
    final baslikController = TextEditingController();
    final miktarController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 24.0,
            bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24.0,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gelirMi ? 'Para Yükle' : 'Harcama Yap',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: baslikController,
                  decoration: InputDecoration(
                    labelText: 'Açıklama (Örn: Maaş, Market)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty)
                      ? 'Açıklama giriniz'
                      : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: miktarController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Tutar (₺)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) {
                    if (val == null ||
                        double.tryParse(val) == null ||
                        double.parse(val) <= 0) {
                      return 'Geçerli bir pozitif tutar giriniz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gelirMi
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final baslik = baslikController.text.trim();
                        final miktar = double.parse(miktarController.text);

                        if (gelirMi) {
                          context.read<CuzdanBloc>().add(
                            ParaYukleEvent(baslik: baslik, miktar: miktar),
                          );
                        } else {
                          context.read<CuzdanBloc>().add(
                            ParaHarcaEvent(baslik: baslik, miktar: miktar),
                          );
                        }
                        Navigator.pop(modalContext);
                      }
                    },
                    child: Text(gelirMi ? 'Bakiyeye Ekle' : 'Harcamayı Kaydet'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Kodvance BLoC Cüzdan'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<CuzdanBloc>().add(const CuzdanYukleEvent()),
          ),
        ],
      ),

      body: BlocConsumer<CuzdanBloc, CuzdanState>(
        listener: (context, state) {
          if (state is CuzdanHataState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mesaj),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CuzdanYukleniyorState) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CuzdanYuklendiState) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<CuzdanBloc>().add(const CuzdanYukleEvent());
              },
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  BakiyeKarti(bakiye: state.bakiye),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            foregroundColor: Colors.green.shade700,
                            side: BorderSide(color: Colors.green.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Para Yükle'),
                          onPressed: () => _islemEkleModaliniAc(context, true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            foregroundColor: Colors.red.shade700,
                            side: BorderSide(color: Colors.red.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.remove_circle_outline),
                          label: const Text('Harcama Yap'),
                          onPressed: () => _islemEkleModaliniAc(context, false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'İşlem Geçmişi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${state.islemler.length} Hareket',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (state.islemler.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: Text('Henüz bir işlem hareketi yok.'),
                      ),
                    )
                  else
                    ...state.islemler.map((islem) => IslemSatiri(islem: islem)),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
