class WebNotificationHelper {
  static bool isSupported() => false;
  static String getPermission() => 'unsupported';
  static Future<bool> requestPermission() async => false;
  static bool show(String title, String body, {String? icon}) => false;
  static void playChime() {}
}
