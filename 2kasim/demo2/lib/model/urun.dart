class UrunModel{
    final int id;
    final String baslik;
    final double fiyat;
    final String kategori;
    final String resimUrl;
    const UrunModel({required this.id,required this.baslik, required this.fiyat, required this.kategori, required this.resimUrl,});
    factory UrunModel.fromJson(Map<String,dynamic> json){
        return UrunModel( 
            id: json ['id'] as int? ?? 0,
            baslik: json ['title'] as String? ?? "İsimsiz ürün",
            fiyat: (json ['price'] as num?)?.toDouble() ?? 0.0,
            kategori: json ['category'] as String? ?? "Genel",
            resimUrl: json ['image'] as String? ?? "https://via.placeholder.com/150",
        );
    }
    
}