Const
1 ne işe yarar: İçine girilen değerleri derleme zamanında tek bir kere yazılarak değişmez olarak üretir
2 Neden kullanılır: widget const olarak tanımlanırsa setState olduğunda flutter bu widget ı yeniden üretmez CPU ve pil tasarrrufu sağlar.

Final
ne işe yarar: Çalışma başladığında değeri bir kez atanan ve sonrasında referansı asla değiştirilmeyen değişkenler
** const ve final farkı ** 
const derlenirken bilinmek zorunda final ise çalışma alanında belirlenebilir: final saat= DateTime.now()-- Models sınıflarında alanlar her zaman final olmalı
**
late 
1) ne işe yarar: değişken anda değil ilk kullanıldığında veya init state anında başlatılacağı zaman kullanılır.

required
1 ne işe yarar: isimlendirilmiş parametrelerde o parametrenini zorunlu olduğunu belirtir.
@override
1: ne işe yarar alt sınıfın üst sınıftan devraldığı metodu ezdiğini belirtir
Eğer üst sınıf metodunu adını yanlış yazarsanız override sayesinde anında hata olarak yakalanır                                


Null-aware operatörleri ? ve ??
?. -- place?.title eğer place null ise null döner.
??. -- if null: final id=state.userId ?? 10; -> sol taraf null ise sağdaki (hardcoded olan değer) otomatik olarak atanır
!( null ) bu kod derleyiciye bana güven o anda kesinlikde null değil değeri gelir ise uygulama anında çöker(ÇOK DİKKATLİ KULLANILMALI)
SPREAD OEPRATÖRÜ:
1) ne işe yarar: bir listenin elemanlarının tek tek çıkartıp bulunduğu üst listenin içine ekler. Column ve ListView içinde dinamik kart dizini kullanmak için en temiz yöntemdir.
... listeaDİ.MAP(p)=> _buildCard(p)
initState()
Ne zaman çalışır: Widget ağaca fiziksel olarak iş başladığında yalnızca 1 kere çalışır.
Ne yapar: Scroll Controller başlatmaları ve ilk API istekleri burda kurulur.
Kural:İçinde doğrudan BuildContext ile Navigator çağrılmaz çünkü widget ağaca tam oturmamıştır.

didChangeDependencies()
ne zaman çalışır: initState()'ten hemen sonra ve widget dinelndiği bir örnek: Theme.of(context)) değiştirlidiğnde otoatik tetiklenir.
Ne yapar: BuildContext güvenli bir şekilde erişerek tema veya ekran bouyutu bağımlılıkları ile ilgili ilk yöntemler burada yapılır.


build(bUİLDcONTEXT context)
Ne zaman çalışır: Syafa ilk açıldığında setState() çağrıldığında veya üst widgettan yeni bir inşa ağaç boyama geldiğinde saniyesinde defalarca çalışır
Kural:build() metodu tamamane saf olmalıdır Asla içinde setState api isteği ya da controller başlatma yapılmamalırdır sadece UI döndrülmelidir.

dispose():
ne zaman çalışır: widget hafızadan atılmadan hemen önce son bir kez çalışır.
Ne yapılır _controller.dispose() stream dinleyicilerin iptalleri burada yapılır. super.dispose() ve mutlaka son satırında çalıştırılması gerekir.

setState((){})
1) arka planda ne yapar state bağlı olduğu statefulElement nesnesine "ben değiştim,build et" sinayli yollar.
2) nerde kullanılr sayfa geneline çizdirmez sadece onu dşnleyen küçük ValueListenerBuilder sinyal gönderilir

ValueNotifier<T>
1 arka planda ne iş yapar. ChangeNotifier sınıfından türer. Belleğinde tek bir nesene referansı tutar(T_value)
2) Tetikleme değer atandığında (set value(T value) eğer yeni değer eski değere eşit değilse) (_value=newValue), kayıtlı olan fonksiyonu çağrılır addEventListener((){})
InheritedWidget
1 ne yapar: Widget ağacında alttaki childların aradaki onlarca widgeti baypas ederek üst widgetin verisine(state 'ine) doğrudan erişmesi sağlayan soyut bir widgettir.

Material 3 Tasarım Dili Renk algoritması ve temalar
primary: Ana marka rengi
onPrimary: Ana rengin üstüne yazılacak yazı rengi
primaryContainer:Ana rengin yumuşak pasterl arkaplan tonunun üstüne yazılacak yazı
surface:sayfa arka plan yuvalı
onSurface: Sayfa üstündekş ana metin rengi
outLineVariant:İnce sınır ve ayrım çizgileri
ThemaMode.system
color: Colors.black.withOpacity(0.8) kesinlikle 1 ila 255 arasındaki sayıları arasında tam sayı olarak girilmelidir ** bu kullanım güncelde istenmiyor

color:Colors.black.withValues(alpha: 186/255)
Arayüz:Düzen ve Liste Bileşenleri
Expanded ve Flexiable
Expand kalan boş alanın tamamını kaplar
Flexible: Kalan bol alanı paylaştırır
Flex: yanyana iki expanded varsa birine felx2 diğerine flex 1 verir bu sayede ekran boyutuna göre otomatik olarak ayarlar.

Stack ve positioned
Ne yapar: Widgetları z ekseninde üstüste bindirir
Positioned:Yalnızca bir stack içinde çalışır
top:10 right:10 vererek bir resmin sağ üst köşesine bildirim rozeti eklememizi sağlar.

ListView.builder
Klasik ListView(children:...) içimdeki örnek vermek gerekirse 10.000 elemanın tamamını daha sayfa açılmadan belleğe yükler ve doğal olarak telefon donar.
ListView.builder ise geri dönüşümlü görünüm alanı mantığını kullanrak ekranda sadece o an eğer 5 kart görünecek ise sadece 5 kartı ram belleğe yükler. kULLANICI AŞAĞIYA KAYDIKÇA YUKARIDA KALANLAR BELLEKTEN DÜŞÜRÜLÜP ALTTA KALANLAR BELLEĞE TAZE OLARAK YENİ ÜRETİLİR
SHRİNKWRAP: true
bir listview başka bir dikey kaydırıcının singlechildscrollview içine konursa Vertical viewport hatası verir
shrinkwrap true yapılarak çözülür ancak ListView sonsuz  scroll özelliğini kaybeder 3 5 eleman varsa bunu kullan
Inkwell ve Gesture Detector
GestureDetector: tıklsms çift tıklama sürükleme olaylarını yakalar ama görsel hiçbir tepki vermez.
Inkwell: tıklandığı an parmağın altından dışa doğru yayılan bir su dalgası efekti verir.
Önemli kuralı: Inkwell'in arkasında mutlaka bir material widget olmak zorundadır aksi taktşrde su dalgası arkadaş tuvalı göremediği için hiçbir şekilde görünmez

Form mimarisi
 GloblaKey<FormState> 
 Widget içindeki form düğümüne doğrudan dışarıdan erişilemiyor bu yüzden widget in en üstüne koyduğuuz globalKey değişkeni sayesinde formun Validate durumunu ve içindeki değerleri dışardan okuyoruz.
 _formKey.currentState?.validate() çağrıldığında o formun altındaki tüm TextFromFiled validator bloklarını sırayla çalıştırır
 validator: (String ? value)
 fonksiyonda bir hata bulursa geriye String olarak hata metni gönderir Bu metin otomatik olarak kırmızı renkte ve inputun altında belirir. Eğer veri geçerliyse null döner Flutter için bu alanda hata yok demektir. Null gelmesi
 Animasyon Motoru
 Animated Container: genişlik tükseklik apdding margin border renk ve gölge
 AnimatedOpacity: görünürlüğü 0 ile 1 arasında yumuşakça soldurur
 AnimatedScale: Widgetleri merkezinden doğru dışarıya büyütüp küçültür
 AnimatedAlignment: widget kutunun içinde sağdan sola yukardan aşağıya karşı konumunu değiştirir.
 Curves
 Curves.linear: sabit hızlanır
 Curves.easeInout: yavaş başlar ortada hızlanır yavaşça durur

 Curves.bounceOut: hedefe çarptığında top gibi 2 3 kez seker
 Cureves.elasticOut: Lastik gibi ileri geri titreyerek yerine oturur.
 Gorouter shellrouter dışında kalan yerler
 ShellRouter sabit butonların olduğu yer
context.got('/profil') Route yölendirmesidir rota tablosunda hiyerarşi takip eder ve temizleyebilir
cpntext.push('/profil/5') stack yönlendirmedir Kullanıcı nereden gelirse gelsin mevcut sayfanın tepesine yeni bir katman ekler ve dönüş sayfası için bir geri ok butonu ekler
context.pop() sayfanın en üstteki yığınını kapatır.
state.pathParameters["id"] Gorouter içinde tanımladığımız /:id yapılarına erişmek için kullanılır
/profil?user=eren
state.uri.queryParameters["user"]: Opsiyonel filtreleme ya da arama zamanlarında kullanılır
Cihaz içi yerel depolama mimarileri
SharedPreferences: Küçük kullanıcı ayarları düşük güvenlik orta hızda okur yavaş yazar
FlutterSecureStorage: Şifre token vb saklama yüksek güvenlik yavaş okuma orta yazma orta
Hive/Isar:
Yüksek performanslı nesne depolama orta güvenlik aşırı hızlı