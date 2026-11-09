import 'package:flutter/foundation.dart';
import '../models/islem.dart';
@immutable
abstract class CuzdanState{
    const CuzdanState();
}
class CuzdanYukleniyorState extends CuzdanState{
    const CuzdanYukleniyorState();
}
class CuzdanYuklendiState extends CuzdanState{
    final double bakiye;
    final List<Islem>islemler;
    const CuzdanYuklendiState({required this.bakiye,required this.islemler});
}
class CuzdanHataState extends CuzdanState{
    final String mesaj;
    const CuzdanHataState(this.mesaj);
}