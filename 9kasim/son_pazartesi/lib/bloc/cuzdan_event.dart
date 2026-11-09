import 'package:flutter/foundation.dart';
@immutable
abstract class CuzdanEvent {
    const CuzdanEvent();
}
class CuzdanYukleEvent extends CuzdanEvent{
    const CuzdanYukleEvent();
}
class ParaYukleEvent extends CuzdanEvent{
    final String baslik;
    final double miktar;
    const ParaYukleEvent({required this.baslik, required this.miktar});
}
class ParaHarcaEvent extends CuzdanEvent{
    final String baslik;
    final double miktar;
    const ParaHarcaEvent({required this.baslik, required this.miktar});
}