void main() {
  final Set<String> temelServisler = {
    "web-sayfasi",
    "kullanici-girisi",
    "alisveris-sepeti",
    "alisveris-sepeti",
  };

  final bool isProduction = true;

  final List<String> tumServisler = [
    ...temelServisler, 
    if (isProduction) "vault-secret-manager", 
  ];

  print("Çalışan Servisler: $tumServisler");
}