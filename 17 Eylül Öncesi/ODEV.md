BAŞLA
1.SORU
// 1. Oturum Kontrolü
EĞER Oturum Kapalı İSE
    Giriş Yap
BİTİR

// 2. Ana Menü Döngüsü
DÖNGÜ Ana Menü Seçimi Yapıldığı Sürece

    EĞER Seçim = "Çıkış" İSE
        Döngüyü Sonlandır
    DEĞİLSE EĞER Seçim = "Bakiye Yükle" İSE
        Bakiye Yükle
    DEĞİLSE EĞER Seçim = "Alışveriş Yap" İSE

        // 3. Alışveriş Döngüsü
        DÖNGÜ Alışveriş Yapılırken
            Ürünü Sepete Ekle
            Siparişi Onayla

            EĞER Bakiye Yeterli İSE
                Sipariş Paketini Sunucuya Gönder
                Bakiyeden Düş
                "Sipariş Alındı" Uyarısı Ver
            DEĞİLSE
                "Yetersiz Bakiye" Uyarısı Ver
                Alışveriş Döngüsünü Sonlandır // Ana menüye döner
            BİTİR
        DÖNGÜ BİTİR

    BİTİR

DÖNGÜ BİTİR

BİTİR
2. SORU
{
  "kahve_adi": "Latte",
  "boyut": "Grande",
  "adet": 2,
  "toplam_tutar": 140.00
}
"mesaj": {"Sipariş eklendi","siparis_id":11} ürün eklenirse http 201
{"hata": "Oturum açmanız gerekiyor"} ürün eklenemezse http 401
{
  "bakiye": 185.50, ideal durum
  "para_birimi": "TRY"        http 200
}
{
  "hata": "Sunucuda beklenmeyen bir hata oluştu." hatalı çalışırsa http 500
}
GET idempotenttir çünkü her get isteği attığımızda sonuç aynı olur yani bakiyeyi her çektiğimizde aynı bakiye gelir fakat post idempotent değildir çünkü her sipariş attığımızda yeni bir sipariş oluşturur arka tarafta örneğin birinin id si 101 diğerinin id si 102 get sunucuda değişiklik olmadığı sürece her çağrıldığında aynı sonucu getirir fakat post sunucuda değişiklik yapar
3. SORU
SRP ihlal edilmiştir çünkü sipariş yöneticisi sınıfa birbiri ile alakasız metodlar eklenerek god class halini almıştır. Bunu düzeltmek için veritabanına kaydetmek için repositorySerivce inteface i sms için smsService interface i ödeme işlemi için ödemeService interfacei indirim hesaplama için indirimService interfaceleri yazılıp sonra interfaceler dependency injection yoluyla SiparisYonetici classına eklenmeli
İndirim hesaplamada kodu if-else ile değiştirmek OCP ihlalidir