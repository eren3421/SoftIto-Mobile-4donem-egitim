import 'dart:html' as html;
import 'dart:js' as js;

class WebNotificationHelper {
  static bool isSupported() {
    try {
      if (js.context.hasProperty('MentorNotifications')) {
        final res = js.context['MentorNotifications'].callMethod('isSupported');
        return res == true;
      }
      return html.Notification.supported;
    } catch (_) {
      return false;
    }
  }

  static String getPermission() {
    try {
      if (js.context.hasProperty('MentorNotifications')) {
        final res = js.context['MentorNotifications'].callMethod('getPermission');
        return res?.toString() ?? 'default';
      }
      return html.Notification.permission ?? 'default';
    } catch (_) {
      return 'default';
    }
  }

  static Future<bool> requestPermission() async {
    try {
      if (html.Notification.supported) {
        final result = await html.Notification.requestPermission();
        return result == 'granted';
      }
    } catch (e) {
      // ignore: avoid_print
      print('requestPermission error: $e');
    }
    return false;
  }

  static bool show(String title, String body, {String? icon}) {
    try {
      playChime();
      if (js.context.hasProperty('MentorNotifications')) {
        final res = js.context['MentorNotifications'].callMethod('show', [title, body, icon ?? 'favicon.png']);
        if (res == true) return true;
      }
      if (html.Notification.supported && html.Notification.permission == 'granted') {
        html.Notification(title, body: body, icon: icon ?? 'favicon.png');
        return true;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Web notification show error: $e');
    }
    return false;
  }

  static void playChime() {
    try {
      if (js.context.hasProperty('playNotificationChime')) {
        js.context.callMethod('playNotificationChime');
      }
    } catch (_) {}
  }
}
