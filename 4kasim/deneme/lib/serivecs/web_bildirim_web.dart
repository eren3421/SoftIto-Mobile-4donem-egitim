import 'dart:js_interop';

@JS('softitoWebBildirimIzinIste')
external void _jsWebBildirimIzinIste();

@JS('softitoWebBildirimGoster')
external void _jsWebBildirimGoster(JSString baslik, JSString icerik);

void webBildirimIzinIste() {
  try {
    _jsWebBildirimIzinIste();
  } catch (_) {}
}

void webBildirimGoster(String baslik, String icerik) {
  try {
    _jsWebBildirimGoster(baslik.toJS, icerik.toJS);
  } catch (_) {}
}

