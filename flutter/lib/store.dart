import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'models.dart';

class WorkoutStore extends ChangeNotifier {
  static const _logKey = 'gymtracker.log.v1';
  static const _dayKey = 'gymtracker.activeDay.v1';
  static const _settingsKey = 'gymtracker.settings.v1';

  SharedPreferences? _prefs;

  int activeDay = 0;
  Map<String, SetEntry> log = {};

  bool useLb = false;
  bool autoRest = true;
  bool bigNumbers = false;
  bool keepAwake = false;

  String get unitLabel => useLb ? 'LB' : 'KG';

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    activeDay = (_prefs!.getInt(_dayKey) ?? 0).clamp(0, program.length - 1);

    final rawLog = _prefs!.getString(_logKey);
    if (rawLog != null) {
      try {
        final decoded = jsonDecode(rawLog) as Map<String, dynamic>;
        log = decoded.map((k, v) =>
            MapEntry(k, SetEntry.fromJson(v as Map<String, dynamic>)));
      } catch (_) {
        log = {};
      }
    }

    final rawSettings = _prefs!.getString(_settingsKey);
    if (rawSettings != null) {
      try {
        final s = jsonDecode(rawSettings) as Map<String, dynamic>;
        useLb = s['useLb'] as bool? ?? false;
        autoRest = s['autoRest'] as bool? ?? true;
        bigNumbers = s['bigNumbers'] as bool? ?? false;
        keepAwake = s['keepAwake'] as bool? ?? false;
      } catch (_) {}
    }
    _applyWakelock();
    notifyListeners();
  }

  void _persistLog() {
    _prefs?.setString(
        _logKey, jsonEncode(log.map((k, v) => MapEntry(k, v.toJson()))));
  }

  void _persistSettings() {
    _prefs?.setString(
        _settingsKey,
        jsonEncode({
          'useLb': useLb,
          'autoRest': autoRest,
          'bigNumbers': bigNumbers,
          'keepAwake': keepAwake,
        }));
  }

  Future<void> _applyWakelock() async {
    try {
      if (keepAwake) {
        await WakelockPlus.enable();
      } else {
        await WakelockPlus.disable();
      }
    } catch (_) {
      // Plugin unavailable (e.g. tests); keep-awake is best-effort.
    }
  }

  // MARK: log access

  static String key(int day, int exercise, int set) => '$day-$exercise-$set';

  SetEntry entry(int day, int exercise, int set) =>
      log[key(day, exercise, set)] ?? SetEntry();

  void setWeight(int day, int exercise, int set, String value) {
    final e = log.putIfAbsent(key(day, exercise, set), SetEntry.new);
    e.weight = value;
    _persistLog();
    // No notifyListeners: the TextField already shows the value; rebuilding
    // mid-typing would reset the cursor.
  }

  void setReps(int day, int exercise, int set, String value) {
    final e = log.putIfAbsent(key(day, exercise, set), SetEntry.new);
    e.reps = value;
    _persistLog();
  }

  /// Flips a set's done state and returns the new value.
  bool toggleSet(int day, int exercise, int set) {
    final e = log.putIfAbsent(key(day, exercise, set), SetEntry.new);
    e.done = !e.done;
    _persistLog();
    notifyListeners();
    return e.done;
  }

  int doneCount(int day, int exercise) {
    final ex = program[day].exercises[exercise];
    var n = 0;
    for (var si = 0; si < ex.sets; si++) {
      if (entry(day, exercise, si).done) n++;
    }
    return n;
  }

  bool exerciseDone(int day, int exercise) =>
      doneCount(day, exercise) == program[day].exercises[exercise].sets;

  (int done, int total) dayProgress(int day) {
    var done = 0, total = 0;
    for (var ei = 0; ei < program[day].exercises.length; ei++) {
      total += program[day].exercises[ei].sets;
      done += doneCount(day, ei);
    }
    return (done, total);
  }

  void setActiveDay(int day) {
    activeDay = day;
    _prefs?.setInt(_dayKey, day);
    notifyListeners();
  }

  void resetDay(int day) {
    log.removeWhere((k, _) => k.startsWith('$day-'));
    _persistLog();
    notifyListeners();
  }

  void toggleUnits() {
    useLb = !useLb;
    _persistSettings();
    notifyListeners();
  }

  void toggleAutoRest() {
    autoRest = !autoRest;
    _persistSettings();
    notifyListeners();
  }

  void toggleBigNumbers() {
    bigNumbers = !bigNumbers;
    _persistSettings();
    notifyListeners();
  }

  void toggleKeepAwake() {
    keepAwake = !keepAwake;
    _persistSettings();
    _applyWakelock();
    notifyListeners();
  }
}
