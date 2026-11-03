abstract class AutRepository{ // Farklı tür repositorylerin implement etmesi gereken fonksiyonları tutan soyut sınıf implement eden tüm sınıflar metodlar soyutsa kendilerine göre verilen metodları uygulamalı. Kendisini implement eden farklı sınıfların referanslarını tutarak bir soyutlama kazandırır.
    Future<String> login(String email, String password); // parametre olarak string tipinde email ve string türünde şifre alan ve string dönen asenkron login fonksiyonu
    Future<void> logout(); // asenkron olarak çalışıp geriye değer dönmeyen çıkış fonksiyonu
    bool get isAuth; // yetkili olup olmadığını tutan bool tipinde değişken
}
class FireBaseAuthRepository implements AutRepository{ // authrepository abstract sınıfını implement eden firebaseauthrepository sınıfının açılışı
    @override
    Future<String> login(String email,String password)async{ // abstract class taki login fonksiyonunu kendine göre implement eder.
        return "firebase_token_xyz_123"; // firebase_token_xyz_123 değerini döner.
    }
    @override
    Future<void> logout() async{
        // abstract class authrepository sınıfındaki logout fonksiyonunu kendine göre implement eder.
    }
    bool get isAuth=> true; // is auth değeri true olarak döner
}
class MockAuthRepository implements AutRepository{ // authrepository abstract sınıfını implement eden mockAuthRepository sınıfının açılış
    @override
    Future<String> login(String email, String password)async{ // abstract class taki login fonksiyonunu kendine göre implement eder.
        await Future.delayed(Duration(seconds: 1)); // bir saniye bekletir.
        return "mock_token_abc_789"; // fmock_token_abc_789 değerini döner.
    }
    @override
    Future<void> logout() async {
        // abstract class authrepository sınıfındaki logout fonksiyonunu kendine göre implement eder.
    }
    bool get isAuth=> true; //is auth değeri true olarak döner
}
mixin Logger{ // ileride farklı sınıflara with ile bağlanarak içindeki fonksiyonu kullandırır koda çoklu kalıtım ilişkisi katmadan esneklik sağlar.
    void log(String msg)=>print("LOG:$msg"); // ekrana msg olarak gelen parametreyş log olarak bastırır.

}
mixin Analytics{ // ileride farklı sınıflara with ile bağlanarak içindeki fonksiyonu kullandırır çoklu kalıtım ilişkisi katmadan esneklik sağlar.
    void log(String msg)=>print("ANALİZ:$msg"); // ekrana msg olarak gelen parametreyş Analiz olarak bastırır.

}
class PaymentService with Logger,Analytics{ // analytics ve logger mixin yapılarını with ile kullanır ancak analytics mixini daha sonra bağlandığı için logger yerine o çalışır
    void pay(){ // void türünde pay fonksiyonu
        log("Ödeme Yapıldı"); // analytics mixininden gelen fonksiyonu "Ödeme yapıldı" parametresini ile çalıştırır.
    }
}
abstract class BaseWidget{ // abstract class olarak baseWidget tanımlanır bu sınıf doğrudan çalıştırılamaz ancak kendisini implement eden sınıfların referansını tutarak soyutlama katmanı sağlar.

}
mixin LifeLogger on BaseWidget{ // LifeLogger adlı mixin sadece BaseWidget sınıfından, sınıftan türeyen veya sınıfı implement eden sınıfların kullanamsını sağlar
    void logInit()=>print("Widget başlatıldı"); // logInıt adlı fonksyion ekrana bastırır.
}
extension StringValidator on String{ // String veri tiplerinde çalışacak ve onlara attribute olarak eklenecek fonksiyonları yazmamızı sağlar StringValidator adlı extension tipinde sınıf
    bool get isValidEmail{ // isValid adında string veritplerinde kullanılabilcek isValidEmail olarak üstünde çalıştırır.
        final emailRegex=RegExp(r'^+^'); // e posta doğrulama deseni verilen string uyması gereken desendir
        return emailRegex.hasMatch(this); // stringin yani e postanın bu desene uyup uymadığına bakar.
    }
    String toCapitilize(){ // stringlerin ilk harfini büyük harfe çevirir.
        if(isEmpty){ // boş olup olmadığını kontrol eder
            return this; // boşsa kendisini döner.
        }
        return this[0].toUpperCase()+substring(1); // string birinci harfini büyük yapıp ilk harften sonrasını birleştirir.
    }
}
void main(){ // programın çalıştığı ana fonksiyon
    String email="eren123@gmail.com"; // string tipinde email değişkeni
    if(email.isValidEmail){ // emailin geçerli olup olmadığını kontrol eder
        print("Geçerli Eposta değil"); // email.isValidEmail doğru ise bu satır çalışır ekrana yazı bastırır.
    }
    else{ // if içindeki koşul doğru değilse else bloğunu içini çalıştırır.
        print("Geçersiz Eposta"); // ekrana yazı bastırır.
    }
}
abstract class Identifiable{ // Identifiable adında soyut sınıf oluşturuldu.
    String get id; // string tipinde id özelliğini çağıran özellik
}
class GenericCache<T extends Identifiable>{ // Identifiable sınıfı veya o sınftan türeyen nesneleri önbelleğe almak için kullanılan generic GenericCache sınıfı
    final Map<String,T> _storage={}; // key string value değeri T şablon tipinden olan _storage adında bir Map oluşturulur.
    void save(T item){ // T tipindeki itemi kaydetme fonksiyonu
        _storage[item.id]=item; // kaydedilecek item in id sini storage a key olarak kullanır value olarak itemi kaydeder.
        print("ID${item.id} önbelleğe alındı"); // ekrana kaydedilen id nin numarasını ile önbelleğe alındı diye yazar.
    }
    T? getById(String id)=> _storage[id]; // id numarası verilen T tipindeki nesneyi döndürür '?' sayesinde id yoksa null döner. 
}
import 'dart:async'; // dart içindeki future microtask gibi asenkron kodlama yapmamızı sağlayan kütüphanedir.
void main(){
    print("1.Senkron"); // senkron olarak callstackte çalışır önceliği en yüksek olandır ve ekrana yazı bastırır
    scheduleMicrotask((){ // senkron kodlar bittikten sonra scheduleMicrotask kodları çalışır yani 3. sırada bu var
        print("2.Task oluşturuldu"); // ekrana yazı bastırır.
    });
    Future((){ // en son çalışır ve hiyerarşi de senkron ve microtasklerden sonra gelir
        print("3. Standart Event Kuyruğu"); // ekrana yazı bastırır.
    });
    Future.microtask((){ // scheduleMicrotask tan sonra futuremicrotask çalışır aralarında hiyerarşik olarak fark yoktur ilk hangisi gelirse o çalışır ayrıca schedule aksine try catch ile hata yönetimi yapılabilir geriye değer dönebilir ve await ile bekletilebilir. içindeki kod asenkron olarak çalışabilir zaten altta scheduleMicrotask kullanır.
        print("4.Future microtask"); //ekrana yazı bastırır
    });
    print("5. senkron kod tamamkandı"); // senkron olarak callstackte çalışır 1. senkrondan sonra önceliği en yüksek olandır ve ekrana yazı bastırır
}