import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serbest/model/ogrenci_model.dart';
class FirestoreYonetimEkrani extends StatefulWidget{
  const FirestoreYonetimEkrani( { super.key});
  @override
    // TODO: implement toStringDeep
    State<FirestoreYonetimEkrani> createState() => _FireStoreYonetimEkraniState();
  
}
class _FireStoreYonetimEkraniState extends State<FirestoreYonetimEkrani>{
    final FireStoreOgrenciServisi _servis=FireStoreOgrenciServisi();
    final TextEditingController _adSoyadKontrolcusu=TextEditingController();
    final TextEditingController _projeKontrolcusu=TextEditingController();
    final TextEditingController _notKotrolcusu=TextEditingController();
    @override
    void dispose(){
      _adSoyadKontrolcusu.dispose();
      _projeKontrolcusu.dispose();
      _notKotrolcusu.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context){
      return Scaffold(
        appBar:AppBar(
          title: const Text("Canlı FireStore ekranı"),
          backgroundColor: Colors.amber.shade600,
        ),
        body:Column( 
          children:[
            Padding(padding: const EdgeInsets.all(12.0),
            child: Padding(padding: const EdgeInsets.all(12.0), 
                  child:Column( 
                    children:[
                      TextField( 
                        controller: _adSoyadKontrolcusu,
                        decoration: const InputDecoration(
                          labelText:"Öğrenci Ad Soyadı",
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height:8),
                       SizedBox(  // expanded ile proje kontrolcüsü eklencek
                        width:10,
                        child: TextField( 
                          controller: _notKotrolcusu,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(  
                            labelText: "Not (0-100)",
                            prefixIcon: Icon(Icons.grade),
                          ),
                        )
                       )
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon( 
                    style:ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.brown,
                      minimumSize: const Size.fromHeight(44),
                    ),
                    onPressed:  _yeniOgrenciKaydet,
                    icon:const Icon(Icons.cloud_upload),
                    label: const Text("Buluta kaydet"),
                  )
            ),
            ),
          ],
        )
        const Divider(thickness: 2),
        Expanded( 
          child:StreamBuilder<QuerySnapshot>(  
            stream:FirebaseFirestore.instance.collection('ogrenciler').orderBy('notu',descending: true).snapshots(),
            builder:(BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot){
              if(snapshot.hasError){
                return Center(child: Text("Bulut hatası ${snapshot.error}"));
              }
              if(snapshot.connectionState==ConnectionState.waiting){
                return const Center(child: CircularProgressIndicator());
              }
              if(snapshot.hasData||snapshot.data!.docs.isEmpty){
                  child: Text("Henüz bulutta kayıtlı öğrenci yoktur.");
              }
              final List<DocumentSnapshot> dokumanlar=snapshot.data!.docs;
              return ListView.builder(itemCount: dokumanlar.length,itemBuilder: (context,index){
                final doc=dokumanlar[index];
                final ogrenci=OgrenciModel.fromFireStore(doc);
                return Dismissible(key: Key(ogrenci.id),direction:DismissDirection.endToStart,background: Container( alignment: Alignment.centerRight,padding:const EdgeInsets.only(right:20),color:Colors.red,
                child: const Icon(Icons.delete_forever,color:Colors.white),
                onDismissed:(direction){
                  _servis.ogrenciSil(ogrenci.id);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${ogrenci.adSoyad} buluttan sildi')),);
                },child:ListTile(leading:CircleAvatar(backgroundColor: ogrenci.notu>=80 ? Colors.green:(ogrenci.notu>=50 ? Colors.orange:Colors.red),child:Text('${ogrenci.notu}',style:const TextStyle(color:Colors.white,fontWeight: FontWeight.bold),),),title:Text(ogrenci.adSoyad,style:const TextStyle(fontWeight: FontWeight.bold),),subtitle:Text("Proje ${ogrenci.projeAdi}"),trailing: IconButton(onPressed:()=> _notGuncelleDialog(ogrenci),icon:const Icon( Icons.edit,color:Colors.amberAccent,),),),),),
              },);
            },
          ),
        ),
      );
    }
    void _yeniOgrenciKaydet(){
      final adSoyad= _adSoyadKontrolcusu.text.trim();
      final proje=_projeKontrolcusu.text.trim();
      final not=int.tryParse(_notKotrolcusu.text.trim())??0;
      if (adSoyad.isEmpty|| proje.isEmpty){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen ad soyad ve proje adı gir")),);return;
      }
      _servis.ogrenciEkle(adSoyad: adSoyad, projeAdi: proje, notu: not);
      _adSoyadKontrolcusu.clear();
      _projeKontrolcusu.clear();
      _notKotrolcusu.clear();
    }
}
// expanded içinde projeadı inputu açılcak
//_notGuncelleDialog fonksiyonu yazılcak
// sayfalar parse edilcek ve sistem çalıştırılacak