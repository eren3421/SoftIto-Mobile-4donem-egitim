import '../model/urun.dart';
import 'dart:convert';
abstract class IUrunServisi{
    Future<List<UrunModel>> urunleriGetir();
}