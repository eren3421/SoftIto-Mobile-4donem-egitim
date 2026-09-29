void main(){
  print("beyaz liste ve küme analizi");

  final Set<String> istanbulVeriMerkeziIpleri={
    "10.0.1.10",
    "10.0.1.11",
    "10.0.1.12",
    "10.0.1.13",
    "10.0.1.14",
    "10.0.1.11", // çift kayıt set burayı anında tek hale getirir
  };
  print("istanbul ipleri: $istanbulVeriMerkeziIpleri");

  final Set<String> frankfurtVeriMerkeziTipleri={
    "10.0.1.13",
    "10.0.1.30",
    "10.0.1.45",
  };
  print("Frankfurt ipleri: $frankfurtVeriMerkeziTipleri");

  final ortakKopruIpleri =istanbulVeriMerkeziIpleri.intersection(frankfurtVeriMerkeziTipleri);
  print("ortak ağ ipleri(kesişim): $ortakKopruIpleri");

  final tumGlobalIpler=istanbulVeriMerkeziIpleri.union(frankfurtVeriMerkeziTipleri);
  print("Toplam global ipler(birleşme): $tumGlobalIpler");

  final sadeceIstanbul=istanbulVeriMerkeziIpleri.difference(frankfurtVeriMerkeziTipleri);
  print("sadece istanbul: $sadeceIstanbul");

  
}