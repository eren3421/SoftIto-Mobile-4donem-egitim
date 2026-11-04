import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
class StorageServisi{
    final FirebaseStorage _storage= FirebaseStorage.instance;
    UploadTask yuklemeBaslat({ 
        required File dosya,
        required String hedefDizin,
        required String dosyaAdi,
    }){
        final Reference ref= _storage.ref().child('$hedefDizin/$dosyaAdi');
        final metaData=SettableMetadata( 
            contentType:'image/jpg',
            customMetadata: {'yukleyen':'Faik fahrş tek kişi'},
        );
        return ref.putFile(dosya,metadata);
    }
    task.snapshot.listen(( TaskSnapshot snapshot){
        final double yuzde=snapshot.bytesTransferred / snapshot.totalBytes;
        print('yükleniyor % ${(yuzde*100).toStringFixed(1)}');
    })
}