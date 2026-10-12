/*Future<void> fetchDashboardData() async{
  try{
    final result=await Future.wait([fetchUserProfile(),fetchAccountBalance(),fetchNotification()],eagerError: true);
    print("Tüm veriler geldi");
  }catch(e){
    print("İsteklerden biri başarısız oldu $e");
  }
}*/
import 'dart:async';
void main(){
  final controller=StreamController<int>();
  final subscription = controller.stream.listen((data)=>print("yeni veri $data"),onError:(err)=>print("Hata oluştu $err"),onDone:()=> print("Yayın tamamlandu"),);
  controller.sink.add(10);
  controller.sink.add(20);
  controller.sink.add(30);
  final broadcastStream=controller.stream.asBroadcastStream();
  broadcastStream.listen((d)=>print("UI EKRANI $d"));
  broadcastStream.listen((d)=>print("Analitik Ekran $d"));
  controller.close();
}