name:flutter-feature-scaffold
description: Flutter projelerinde feautere bazlı kod yazmak için gerekli klasör yapısını oluşturur.
ValueNotifier state mimarisiini UI ayrımını ve birim test isteklerini standartlara uygun üretir.
# Fkutter feauture scaffold(modüler ekran iskeleti)
Bu yetenek projede yeni bir ekran ya da işlev açarken Clean UI ve reaktif state kurallarına tam uyulmasını garantiye alır.
##Temel Kurallar
1.**Asla tek dosyada toplama:**
UI (`_vier.dart`) State Controller
(`_controller.dart`) ve model
(`_model.dart`) dosyaları ayrı ayrı açılmalıdır.
2 **State Yönetimi**
Basit ve reaktif durumlar için ValueNotifier kullanmalıdır
Doğrudan devasa StatefulWidgets yazarak işi karmaşıklaştırma.
3 **Const Zorunluluğu**
Mümkün olan tüm widgetlarda const olmalıdır.

## Adım adım uygulama akışı
### adım1: Klasör yapısı oluşturma
Hedeflenen modül adlarını (örn:`water_tracker`), `lib/features/<feature_name>` altına yapıyı kur
```text
lib/features/<feature_name>
  ├─ controllers/<feature_name>_controller.dart
  ├─ views/<feature_name>_view.dart
  ├─ models/<feature_name>_model.dart
  └─ widgets/<feature_name>_card.dart
```
### Adım 2:Controller dosyasını yaz  
`controllers/<feature_name>_controller.dart`içinde mantığı `ValueNotifier` tanımlarını oluştur:
```dart
import 'package:flutter/foundation.dart';

class  WaterTrackerController{
    final ValueNotifier<int> currentWater=ValueNotifier<int>(0);
    final int dailyGoalWater=2000;
    void addWater(){
        currentWater.value +=250;
    }
    void resetWater(){
        currentWater.value=0;
    }
    void dispose(){
        currentWater.dispose();
    }
}

```
### Adım 3:Model Dosyasını Oluşturma
`models/<feature_name>_model.dart` dosyasını `copyWith`,`fromJson` `toJson` metotlarını içerecek şekilde `immuteable` olarak tanımla:
```dart
class UserProfile{
    final String name;
    final String email;
    final String profileImage;
    final int level;
    final int coins;
    const UserProfile({
        required this.name;
        required this.email;
        required this.profileImage;
        required this.level;
        required this.coins;
    });
    UserProfile copyWith({
        String? name,
        String? email,
        String? profileImage,
        int? level,
        int? coins,
    })
    {
        return UserProfile(
            name:name ?? this.name,
            email:email ?? this.email,
            profileImage:profileImage ?? this.profileImage,
            level:level ?? this.level,
            coins:coins ?? this.coins,
        );
    }
    factory UserProfile.fromJson(Map<String,dynamic>json){
        return UserProfile(
            name:json['name'] ?? '',
            email:json['email'] ?? '',
            profileImage:json['profile_image'] ?? '',
            level:json['level'] ?? 0,
            coins:json['coins'] ?? 0,
        );
    }
    Map<String,dynamic>toJson(){
        return {
            'name':name,
            'email':email,
            'profile_image':profileImage,
            'level':level,
            'coins':coins,
        };
    }
}
```

### Adım 4:View Dosyasını Yaz
 `view/<feature_name>_view.dart` dosyasında `StatelessWdidget` kullanarak UI katmanı oluştur:
 ```dart
 import 'package:flutter/material.dart';
 import'../controllers/<feature_name>_controller.dart';
 class <feature_name>View extends StatelessWidget{
    final <feature_name>Controller _controller= <feature_name>Controller();
    <feature_name>View({Key?key}):super(key:key);
    @override
    Widget build(BuildContext context){
        return Scaffold(
            appBar:AppBar(
                title: const Text('Flutter Feature Scaffold'),
            ),
            body:ValueListenableBuilder<int>(
                valueListenable:_controller.currentWater,
                builder:(context,waterLevel,_){
                    return Center(
                        child:Column(
                            mainAxisAlignment:MainAxisAlignment.center,
                            children:[
                                Text('Current Water: $currentWater ml',style:const
                                  TextStyle(fontSize:24),),
                                  const SizedBox (height:20),
                                  ElevatedButton(onPressed: _controller.addWater,child: const Text('Add 250 ml'),),
                                  const SizedBox (height:20),
                                  ElevatedButton(onPressed: _controller.resetWater,child: const Text('Reset'),),
                            ],
                        ),
                    ),
                },
            ),
        );
    }
}
```
## Adım 5 Widget Dosyasını Oluşturma
`widgets/<feature_name>_card.dart` dosyasında `StatelessWidget` kullanarak UI katmanı oluştur:
```dart
import 'package:flutter/material.dart';
class <feature_name> Card extends StatelessWidget{
    final String title;
    final String subtitle;
    final String image;
    final int level;
    final int coins;
    const <feature_name>Card({
        Key? key,
        required this.title,
        required this.subtitle,
        required this.image,
        required this.level,
        required this.coins,
    }):super(key:key);
    @override
    Widget build(BuildContext context){
        return Card(
            child:Column(
                children:[
                    Imaage.network(image),
                    Text(title),
                    Text(subtitle),
                    Text('Level:$level'),
                    Text('Coins:$coins'),
                ],
            ),
        );
}
}
```

### Adım 6: Clean Architecture Kurallarına Uyum
- **Seperation of Concerns**: Her dosyanın belirli bir sorumluluğu olduğundan emin ol.
- **Reusability**: Widgetları ve controller'ı dieğr ekranlarda da kullanılabilecek şekilde tasarla.
- **Testability**: Her katman için ayrı testler yazabileceğinden emin ol
## Kullanım Örnekleri
### Örnek 1: Basit bir ekran oluşturma
```dart
import 'package:flutter/material.dart';
import '../view/water_tracker_view.dart';
class HomePage extends StatelessWidget{
    const HomePage({Key? key}): super(key:key);
    @override
    Widget build(BuildContext contex){
        return WaterTrackerView();
    }
}
```
## Örnek 2: Modüler Widget Yapısı
```dart
import 'package:flutter/material.dart';
import '../widgets/water_tracker_card.dart';

class HomePage extends StatelessWidget{
    const HomePage({Key? key}): super(key:key);
    @override
    Widget build(BuildContext context){
        return const WaterTrackerCard(
            title:'Water Tracker',
            subtitle:'Track your water intake',
            image:'https://example.com/water_tracker.jpg',
            level:1,
            coins:0,
        );
    }
}
```
## Ekstra İpuçları
- **Dependency Injection** Controller'ları widget'lara inject etnej için GetIt veya Provider kullanabilirsin.


- **Navigation** Navigasyonu sağlamak için Navigator 2.0 vera go_router kullanabilirsin.
- **Testing** Her katman için ayrı testler yazarak uygulamanın stabilitesini sağlayabilsin.
### SSS
### Soru: Hangi durumlarda bu yeteneği kullanmalıyım?
**Cevap:** Yeni bir ekran veya işlev modülü oluştururken bu yeteneği kullanmalısın
### Soru: Bu yetenek hangi durumlarda kullanmamalıyım
**Cevap** Mevcut bir ekranı güncellerken veya küçük bir hata düzeltmesi yaparken bu yeteneği kullanmamalısın