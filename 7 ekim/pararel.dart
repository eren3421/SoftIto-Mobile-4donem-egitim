Future<void> fetchDashboardData() async{ // panodaki datayı çekmek için kullanılan fetchDashboard adlı asenkron fonksiyonun başlangıcı
  try{ // işler düzgün giderse çalışacak kod bloğu
    final result=await Future.wait([fetchUserProfile(),fetchAccountBalance(),fetchNotification()],eagerError: true);  // result adlı değişken fetchUserprofile ve fetchAccountbalance ve fetchNotification adlı fonksiyonların hepsinin çalışmasını bekler eagerError true olması üç fonksiyondan birinde hata olunca tüm işlemleri durdurup hata fırlatır.
    print("Tüm veriler geldi"); // her şey çalıştığında bu ekrana Tüm veriler geldi bastırır.
  }catch(e){ // hata açma bloğu
    print("İsteklerden biri başarısız oldu $e"); // hata geldiğinde ekrana mesaj bastırır.
  }
}
import 'dart:async'; // dart ın async fonksiyonları tuttuğu kütüphane içinde StreamController ve Future gibi özelliklerini kullanmamızı sağlar. 
void main(){ // tüm programın çalıştığı main fonksiyonu
  final controller=StreamController<int>(); // int veri tipi için bir StreamController sınıfından controller oluşturur.
  final subscription = controller.stream.listen((data)=>print("yeni veri $data"),onError:(err)=>print("Hata oluştu $err"),onDone:()=> print("Yayın tamamlandu"),);
  // listen fonksiyonu sayesinde sink add ile gelen verileri dinler print ile her veri eklendiğinde ekrana sayı bastırır onError saysesinde hata olduğunda program çökmeden hata oldu diye ekrana bastırır ve çalıştırmaya devam eder. onDone ise ver akışı bittiğinde çalışan koddur.
  controller.sink.add(10); // stream yani akışa 10 sayısını ekler
  controller.sink.add(20); // stream yani akışa 20 sayısını ekler
  controller.sink.add(30); // stream yani akışa 30 sayısını ekler
  final broadcastStream=controller.stream.asBroadcastStream(); // controller stream in birden fazla aboneden listen edilmesini sağlar
  broadcastStream.listen((d)=>print("UI EKRANI $d")); // veri geldiğinde ekrana bastırır.
  broadcastStream.listen((d)=>print("Analitik Ekran $d")); // veri geldiğinde ekrana bastırır.
  controller.close(); // bellek sızıntısını önlemek için controller ı kapatıp bellekten temizler.
}