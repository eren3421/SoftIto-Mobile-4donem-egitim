/*abstract class AutRepository{
    Future<String> login(String email, String password);
    Future<void> logout();
    bool get isAuth;
}
class FireBaseAuthRepository implements AutRepository{
    @override
    Future<String> login(String email,String password)async{
        return "firebase_token_xyz_123";
    }
    @override
    Future<void> logout() async{

    }
    bool get isAuth=> true;
}
class MockAuthRepository implements AutRepository{
    @override
    Future<String> login(String email, String password)async{
        await Future.delayed(Duration(seconds: 1));
        return "mock_token_abc_789";
    }
    @override
    Future<void> logout() async {

    }
    bool get isAuth=> true;
}
mixin Logger{
    void log(String msg)=>print("LOG:$msg");

}
mixin Analytics{
    void log(String msg)=>print("ANALİZ:$msg");

}
class PaymentService with Logger,Analytics{
    void pay(){
        log("Ödeme Yapıldı");
    }
}
abstract class BaseWidget{

}
mixin LifeLogger on BaseWidget{
    void logInit()=>print("Widget başlatıldı");
}
extension StringValidator on String{
    bool get isValidEmail{
        final emailRegex=RegExp(r'^+^');
        return emailRegex.hasMatch(this);
    }
    String toCapitilize(){
        if(isEmpty){
            return this;
        }
        return this[0].toUpperCase()+substring(1);
    }
}
void main(){
    String email="eren123@gmail.com";
    if(email.isValidEmail){
        print("Geçerli Eposta değil");
    }
    else{
        print("Geçersiz Eposta");
    }
}
abstract class Identifiable{
    String get id;
}
class GenericCache<T extends Identifiable>{
    final Map<String,T> _storage={};
    void save(T item){
        _storage[item.id]=item;
        print("ID${item.id} önbelleğe alındı");
    }
    T? getById(String id)=> _storage[id];
}*/
import 'dart:async';
void main(){
    print("1.Senkron");
    scheduleMicrotask((){
        print("2.Task oluşturuldu");
    });
    Future((){
        print("3. Standart Event Kuyruğu");
    });
    Future.microtask((){
        print("4.Future microtask");
    });
    print("5. senkron kod tamamkandı");
}