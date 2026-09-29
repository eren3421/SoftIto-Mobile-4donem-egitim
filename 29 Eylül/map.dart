void main() {
  print("Map Metrikleri");

  final Map<String, Map<String, dynamic>> mikroservisRehberi = {
    "auth-api": {
      "port": 8001,
      "saglik": "healthy",
      "resstartSayisi": 0,
      "bellekKullanimiMB": 384.5,
      "otonomOlcekleme": true,
    },
    "payment-gateway": {
      "port": 8003,
      "saglik": "degraded",
      "resstartSayisi": 4,
      "bellekKullanimiMB": 1280.0,
      "otonomOlcekleme": false,
    },
  };
  // Yeni servis ekleme (putIfAbsent ile çakışmasız ekleme)
  mikroservisRehberi.putIfAbsent(
    "reporting-worker",
    () => {
      "port": 9091,
      "saglik": "Healthy",
      "restartSayisi": 1,
      "bellekKullanimiMB": 512.0,
      "otonomOlcekleme": true,
    },
  );
  if (mikroservisRehberi.containsKey("payment-gateway")) {
    mikroservisRehberi["payment-gateway"]!["restartSayisi"] =
        (mikroservisRehberi["payment-gateway"]!["restartSayisi"] as int) + 1;
  }
  print("Güncel Servis Durum Raporu");
  print("--------------------------------");
  for (var entry in mikroservisRehberi.entries) {
    final String servis = entry.key;
    final Map<String, dynamic> ozet = entry.value;
    final String saglik = ozet["saglik"];
    final String durumRozet = saglik == "Healthy" ? "OK" : "Alert";
    print(
      "$durumRozet ${servis.padRight(18)} | Port: ${ozet['port']} | Ram: ${ozet['bellekKullanimiMB']}MB | Restart: ${ozet['restartSayisi']}",
    );
  }
}
