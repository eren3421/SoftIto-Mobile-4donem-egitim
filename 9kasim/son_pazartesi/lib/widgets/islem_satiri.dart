import 'package:flutter/material.dart';
import '../models/islem.dart';
class IslemSatiri extends StatelessWidget{
    final Islem islem;
    const IslemSatiri({super.key,required this.islem});
    @override
    Widget build(BuildContext context){
        final gelirMi=islem.tip==IslemTipi.gelir;
        return Card( 
            elevation:0,
            margin: const EdgeInsets.symmetric(vertical:6),   
            shape:RoundedRectangleBorder(
                borderRadius:BorderRadius.circular(14.0),
                side:BorderSide(color:Colors.grey.shade200),
            ),
            child:ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal:16.0,vertical:4.0),
                leading:CircleAvatar(
                    backgroundColor:gelirMi ? Colors.green.shade50:Colors.red.shade50,
                    child:Icon(
                        gelirMi ? Icons.south_west_rounded:Icons.north_east_rounded,
                        color:gelirMi?Colors.green.shade700:Colors.red.shade700,
                        size:20,
                    ),
                ),
                title: Text(
          islem.baslik,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),

        subtitle: Text(
          '${islem.tarih.day.toString().padLeft(2, '0')}.${islem.tarih.month.toString().padLeft(2, '0')}.${islem.tarih.year} • ${islem.tarih.hour.toString().padLeft(2, '0')}:${islem.tarih.minute.toString().padLeft(2, '0')}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: Text(
          '${gelirMi ? '+' : '-'}₺${islem.miktar.toStringAsFixed(2)}',
          style: TextStyle(
            color: gelirMi ? Colors.green.shade700 : Colors.red.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
            ),
        );
    }
}