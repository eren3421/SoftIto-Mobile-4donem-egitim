import 'package:flutter/material.dart'; // Flutter'ın Material Design görsel bileşenlerini (widget) projeye dahil eder.

void main() { // Uygulamanın başlangıç noktası olan ana (main) fonksiyondur.
  runApp(const MyApp()); // Verilen widget'ı (MyApp) tam ekran çalıştırarak Flutter uygulamasını başlatır.
} // main fonksiyonunun bitişi.

class MyApp extends StatelessWidget { // Durumu değişmeyen (stateless) ana uygulama sınıfını tanımlar.
  const MyApp({super.key}); // Sınıfın  kurucu metodudur, widget kimliğini (key) üst sınıfa iletir.

  @override //  (StatelessWidget) build metodunu yeniden yazdığımızı belirtir.
  Widget build(BuildContext context) { // Kullanıcı arayüzünü oluşturan ve geriye bir Widget döndüren metottur.
    return MaterialApp( // Uygulamanın genel yapısını, temasını ve rotalarını yöneten kök widget'ı döndürür.
      title: 'Flutter Demo', // Uygulamanın görev yöneticisinde (arka planda) görünen adını belirler.
      theme: ThemeData( // Uygulamanın genel görünüm ve renk temasını yapılandırır.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple), // Koyu mor rengi baz alarak uyumlu bir renk paleti üretir.
      ), // ThemeData widget'ının bitişi.
      home: const MyHomePage(title: 'Flutter Demo Home Page'), // Uygulama açıldığında ilk gösterilecek ana ekranı belirler.
    ); // MaterialApp widget'ının bitişi.
  } // build metodunun bitişi.
} // MyApp sınıfının bitişi.

class MyHomePage extends StatefulWidget { // İçeriği/durumu dinamik olarak değişebilen (stateful) sayfa sınıfını tanımlar.
  const MyHomePage({super.key, required this.title}); // Kurucu metot; dışarıdan 'title' parametresini zorunlu (required) olarak alır.
  final String title; // Dışarıdan gelen başlık metnini tutan ve sonradan değiştirilemeyen (final) değişken.

  @override // Üst sınıftaki createState metodunu ezdiğimizi belirtir.
  State<MyHomePage> createState() => _MyHomePageState(); // Bu widget'ın durumunu (state) yönetecek olan sınıfı oluşturur ve bağlar.
} // MyHomePage sınıfının bitişi.

class _MyHomePageState extends State<MyHomePage> { // MyHomePage'in dinamik verilerini ve arayüzünü yöneten durum sınıfı ('_' işareti bu sınıfın sadece bu dosyaya özel/private olduğunu gösterir).
  int _counter = 0; // Butona basılma sayısını tutan, başlangıç değeri 0 olan özel (private) tam sayı değişkeni.

  void _incrementCounter() { // Sayacı artırmak için kullanılan özel fonksiyon.
    setState(() { // İçindeki değer değiştiğinde Flutter'a ekranı yeniden çizmesini (güncellemesini) söyleyen metot.
      _counter++; // _counter değişkeninin değerini 1 artırır.
    }); // setState metodunun bitişi.
  } // _incrementCounter fonksiyonunun bitişi.

  @override // State sınıfındaki build metodunu ezdiğimizi belirtir.
  Widget build(BuildContext context) { // Sayfanın güncel durumuna göre arayüzü çizen metot (her setState çağrısında tekrar çalışır).
    return Scaffold( // Temel sayfa düzenini (üst çubuk, gövde, yüzen buton vb.) sağlayan iskelet widget.
      appBar: AppBar( // Sayfanın en üstünde yer alan başlık çubuğunu (AppBar) tanımlar.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary, // Üst çubuğun arka plan rengini uygulama temasının ters birincil rengine ayarlar.
        title: Text(widget.title), // Üst sınıf (MyHomePage) içindeki 'title' değişkenini metin olarak ekrana yazar.
      ), // AppBar widget'ının bitişi.
      body: Center( // Sayfanın ana gövdesini oluşturur ve içindeki bileşenleri ekranın tam ortasına hizalar.
        child: Column( // İçindeki elemanları yukarıdan aşağıya (dikey) alt alta dizmek için kullanılan widget.
          mainAxisAlignment: .center, // Sütun içindeki elemanları dikey eksende ekranın ortasına hizalar.
          children: [ // Sütun (Column) içerisine eklenecek alt widget'ların listesini başlatır.
            const Text('You have pushed the button this many times:'), // Ekrana sabit bir açıklama metni yazar.
            Text( // Değişken olan sayaç değerini ekrana yazdırmak için kullanılan metin widget'ı.
              '$_counter', // _counter değişkeninin o anki sayısal değerini metin (String) formatına çevirerek gösterir.
              style: Theme.of(context).textTheme.headlineMedium, // Metnin yazı tipini ve boyutunu temanın orta boy başlık stiline ayarlar.
            ), // Sayaç Text widget'ının bitişi.
          ], // Column içindeki children listesinin bitişi.
        ), // Column widget'ının bitişi.
      ), // Center widget'ının bitişi.
      floatingActionButton: FloatingActionButton( // Ekranın sağ alt köşesinde duran yuvarlak eylem butonunu tanımlar.
        onPressed: _incrementCounter, // Butona tıklandığında _incrementCounter fonksiyonunu çalıştırır.
        tooltip: 'Increment', // Butona uzun basıldığında veya fareyle üzerine gelindiğinde çıkan bilgi kutucuğu metni.
        child: const Icon(Icons.add), // Butonun içinde artı (+) simgesi (ikonu) gösterir.
      ), // FloatingActionButton widget'ının bitişi.
    ); // Scaffold widget'ının bitişi.
  } // build metodunun bitişi.
} // _MyHomePageState sınıfının bitişi.