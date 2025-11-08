import 'package:flutter/foundation.dart';
import 'package:dogo_ai_assistant/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsViewModel extends ChangeNotifier {
  static const _notificationsEnabledKey = 'notificationsEnabled';
  static const _reminder1hKey = 'reminder_1h';
  static const _reminder30mKey = 'reminder_30m';
  static const _reminder10mKey = 'reminder_10m';
  static const _reminder5mKey = 'reminder_5m';
  static const _selectedAddressKey = 'selectedAddress';

  bool notificationsEnabled = true;
  bool reminder1h = true; // 1 hour before
  bool reminder30m = true; // 30 minutes before
  bool reminder10m = true; // 10 minutes before
  bool reminder5m = true; // 5 minutes before

  String? selectedAddress;

  SettingsViewModel();

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
    reminder1h = prefs.getBool(_reminder1hKey) ?? true;
    reminder30m = prefs.getBool(_reminder30mKey) ?? true;
    reminder10m = prefs.getBool(_reminder10mKey) ?? true;
    reminder5m = prefs.getBool(_reminder5mKey) ?? true;
    selectedAddress = prefs.getString(_selectedAddressKey);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    notificationsEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
    if (!enabled) {
      // cancel scheduled reminders when notifications are disabled
      await NotificationService.instance.cancelAll();
    }
  }

  Future<void> setReminder1h(bool v) async {
    reminder1h = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminder1hKey, v);
  }

  Future<void> setReminder30m(bool v) async {
    reminder30m = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminder30mKey, v);
  }

  Future<void> setReminder10m(bool v) async {
    reminder10m = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminder10mKey, v);
  }

  Future<void> setReminder5m(bool v) async {
    reminder5m = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminder5mKey, v);
  }

  /// Schedule reminders for a task identified by [taskId] with [title]
  /// and a [dueDate]. This will schedule notifications according to the
  /// enabled intervals. Notification IDs are derived from the taskId
  /// and the interval minutes to ensure uniqueness.
  Future<void> scheduleRemindersForTask({
    required String taskId,
    required String title,
    required DateTime dueDate,
  }) async {
    if (!notificationsEnabled) return;

    final now = DateTime.now();

    final intervals = <int, bool>{
      60: reminder1h,
      30: reminder30m,
      10: reminder10m,
      5: reminder5m,
    };

    for (final entry in intervals.entries) {
      final minutes = entry.key;
      final enabled = entry.value;
      if (!enabled) continue;

      final scheduled = dueDate.subtract(Duration(minutes: minutes));
      if (scheduled.isBefore(now)) continue; // skip past times

      final id = taskId.hashCode ^ minutes;
      await NotificationService.instance.scheduleNotification(
        id: id,
        title: 'Rappel: $title',
        body: 'Votre tâche "$title" est prévue dans $minutes minutes.',
        scheduledDate: scheduled,
      );
    }
  }

  Future<void> cancelRemindersForTask({required String taskId}) async {
    final intervals = [60, 30, 10, 5];
    for (final minutes in intervals) {
      final id = taskId.hashCode ^ minutes;
      await NotificationService.instance.cancelNotification(id);
    }
  }

  Future<void> setAddressFromMap(String address) async {
    selectedAddress = address;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedAddressKey, address);
  }

  /// Placeholder to integrate with a local notification plugin later.
  /// This method doesn't schedule notifications by itself; it's a hook
  /// where you can call `flutter_local_notifications` or similar.
  Future<void> scheduleRemindersPlaceholder() async {
    // TODO: integrate with flutter_local_notifications or awesome_notifications
    debugPrint(
        'Scheduling reminders (placeholder) - enabled=$notificationsEnabled');
  }
}
