import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/islem.dart';
import 'cuzdan_event.dart';
import 'cuzdan_state.dart';

class CuzdanBloc extends Bloc<CuzdanEvent, CuzdanState> {
  CuzdanBloc() : super(const CuzdanYukleniyorState()) {
    on<CuzdanYukleEvent>(_onCuzdanYukle);
    on<ParaYukleEvent>(_onParaYukle);
    on<ParaHarcaEvent>(_onParaHarca);
  }

  Future<void> _onCuzdanYukle(
    CuzdanYukleEvent event,
    Emitter<CuzdanState> emit,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final baslangicIslemleri = [
      Islem(
        id: "1",
        baslik: "Açılış Bonusu",
        miktar: 1000.0,
        tip: IslemTipi.gelir,
        tarih: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Islem(
        id: "2",
        baslik: "Öğle yemeği",
        miktar: 650.0,
        tip: IslemTipi.gider,
        tarih: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];
    emit(CuzdanYuklendiState(bakiye: 350.0, islemler: baslangicIslemleri));
  }

  void _onParaYukle(
    ParaYukleEvent event,
    Emitter<CuzdanState> emit,
  ) {
    if (state is CuzdanYuklendiState) {
      final mevcutState = state as CuzdanYuklendiState;
      final yeniIslem = Islem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        baslik: event.baslik,
        miktar: event.miktar,
        tip: IslemTipi.gelir,
        tarih: DateTime.now(),
      );
      final yeniListe = List<Islem>.from(mevcutState.islemler)
        ..insert(0, yeniIslem);
      final yeniBakiye = mevcutState.bakiye + event.miktar;
      emit(CuzdanYuklendiState(bakiye: yeniBakiye, islemler: yeniListe));
    }
  }

  void _onParaHarca(
    ParaHarcaEvent event,
    Emitter<CuzdanState> emit,
  ) {
    if (state is CuzdanYuklendiState) {
      final mevcutState = state as CuzdanYuklendiState;
      if (mevcutState.bakiye < event.miktar) {
        emit(const CuzdanHataState("Yetersiz Bakiye"));
        emit(mevcutState);
        return;
      }
      final yeniIslem = Islem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        baslik: event.baslik,
        miktar: event.miktar,
        tip: IslemTipi.gider,
        tarih: DateTime.now(),
      );
      final yeniListe = List<Islem>.from(mevcutState.islemler)
        ..insert(0, yeniIslem);
      final yeniBakiye = mevcutState.bakiye - event.miktar;
      emit(CuzdanYuklendiState(bakiye: yeniBakiye, islemler: yeniListe));
    }
  }
}
