import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Drives the rest countdown. Time is computed from a wall-clock end date so
/// the timer stays correct when the app is backgrounded; a local notification
/// fires at the end so the alarm reaches the user even with the screen locked.
class RestTimerManager extends ChangeNotifier {
  static const _notificationId = 7001;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _pluginReady = false;
  bool _permissionAsked = false;

  String exerciseName = '';
  int totalSeconds = 0;
  int remaining = 0;
  bool isRunning = false;
  bool isActive = false;

  DateTime? _endAt;
  Timer? _ticker;

  bool get isFinished => isActive && remaining <= 0;
  double get progress => totalSeconds > 0
      ? (remaining / totalSeconds).clamp(0.0, 1.0).toDouble()
      : 0.0;
  String get label => isFinished ? 'DONE — NEXT SET' : 'REST';

  Future<void> init() async {
    tzdata.initializeTimeZones();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    try {
      await _plugin.initialize(settings: settings);
      _pluginReady = true;
    } catch (_) {
      // Notifications unavailable (e.g. tests); the in-app timer still works.
    }
  }

  Future<void> _requestPermissionIfNeeded() async {
    if (!_pluginReady || _permissionAsked) return;
    _permissionAsked = true;
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, sound: true);
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (_) {}
  }

  void start(String name, int seconds) {
    _requestPermissionIfNeeded();
    exerciseName = name;
    totalSeconds = seconds;
    remaining = seconds;
    isActive = true;
    _resume();
  }

  void addFifteen() {
    if (!isActive) return;
    totalSeconds += 15;
    remaining += 15;
    if (isRunning) {
      _endAt = DateTime.now().add(Duration(seconds: remaining));
      _scheduleNotification();
    } else {
      _resume();
    }
    notifyListeners();
  }

  void togglePause() {
    if (!isActive) return;
    if (isRunning) {
      _pause();
    } else if (remaining > 0) {
      _resume();
    }
    notifyListeners();
  }

  void stop() {
    _pause();
    isActive = false;
    notifyListeners();
  }

  /// Re-sync the countdown after the app returns to the foreground.
  void refreshFromClock() {
    if (!isRunning || _endAt == null) return;
    final secondsLeft =
        (_endAt!.difference(DateTime.now()).inMilliseconds / 1000).ceil();
    if (secondsLeft <= 0) {
      // The local notification already alerted the user while backgrounded.
      _finish(playAlarm: false);
    } else {
      remaining = secondsLeft;
    }
    notifyListeners();
  }

  void _pause() {
    isRunning = false;
    _ticker?.cancel();
    _ticker = null;
    _endAt = null;
    _cancelNotification();
  }

  void _resume() {
    if (remaining <= 0) return;
    isRunning = true;
    _endAt = DateTime.now().add(Duration(seconds: remaining));
    _scheduleNotification();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) => _tick());
    notifyListeners();
  }

  void _tick() {
    if (!isRunning || _endAt == null) return;
    final msLeft = _endAt!.difference(DateTime.now()).inMilliseconds;
    final secondsLeft = msLeft <= 0 ? 0 : (msLeft / 1000).ceil();
    if (secondsLeft != remaining) {
      remaining = secondsLeft;
      if (secondsLeft >= 1 && secondsLeft <= 3) {
        HapticFeedback.lightImpact();
        SystemSound.play(SystemSoundType.click);
      }
      notifyListeners();
    }
    if (secondsLeft <= 0) {
      _finish(playAlarm: true);
    }
  }

  void _finish({required bool playAlarm}) {
    isRunning = false;
    _ticker?.cancel();
    _ticker = null;
    _endAt = null;
    remaining = 0;
    if (playAlarm) {
      // The scheduled notification fires right now and carries the sound;
      // add strong haptics for good measure.
      HapticFeedback.heavyImpact();
      HapticFeedback.vibrate();
    } else {
      _cancelNotification();
    }
    notifyListeners();
  }

  void _scheduleNotification() {
    if (!_pluginReady || remaining <= 0) return;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'rest_timer',
        'Rest timer',
        channelDescription: 'Alarm when the rest period is over',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        category: AndroidNotificationCategory.alarm,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );
    _plugin
        .zonedSchedule(
          id: _notificationId,
          title: 'Rest over — next set!',
          body: exerciseName,
          scheduledDate:
              tz.TZDateTime.now(tz.UTC).add(Duration(seconds: remaining)),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        )
        .catchError((_) {});
  }

  void _cancelNotification() {
    if (!_pluginReady) return;
    _plugin.cancel(id: _notificationId).catchError((_) {});
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
