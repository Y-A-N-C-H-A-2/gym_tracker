import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models.dart';
import 'rest_timer.dart';
import 'store.dart';
import 'theme.dart';
import 'widgets/exercise_card.dart';
import 'widgets/timer_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const GymTrackerApp());
}

class GymTrackerApp extends StatelessWidget {
  const GymTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Palette.bg,
        colorScheme: const ColorScheme.dark(
          primary: Palette.volt,
          surface: Palette.bg,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final store = WorkoutStore();
  final timer = RestTimerManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    store.load();
    timer.init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    store.dispose();
    timer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) timer.refreshFromClock();
  }

  Future<void> _confirmResetDay() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Palette.surface,
        title: Text('Reset day?', style: condensed(22)),
        content: Text(
          'Clear all logged sets for this day?',
          style: body(14, color: Palette.textDim),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('CANCEL', style: condensed(14, color: Palette.textDim)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('RESET', style: condensed(14, color: Palette.restText)),
          ),
        ],
      ),
    );
    if (confirmed == true) store.resetDay(store.activeDay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: Listenable.merge([store, timer]),
          builder: (context, _) {
            final day = program[store.activeDay];
            return Column(
              children: [
                _Header(store: store, onReset: _confirmResetDay),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 14,
                      bottom: timer.isActive ? 120 : 30,
                    ),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: day.exercises.length + 1,
                    itemBuilder: (context, i) {
                      if (i == day.exercises.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            'Everything you log is saved automatically.',
                            textAlign: TextAlign.center,
                            style: body(12, color: Palette.footNote),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 13),
                        child: ExerciseCard(
                          store: store,
                          timer: timer,
                          day: store.activeDay,
                          index: i,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomSheet: ListenableBuilder(
        listenable: timer,
        builder: (context, _) => timer.isActive
            ? TimerBar(timer: timer)
            : const SizedBox.shrink(),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.store, required this.onReset});

  final WorkoutStore store;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final day = program[store.activeDay];
    final (done, total) = store.dayProgress(store.activeDay);
    final fraction = total > 0 ? done / total : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: const BoxDecoration(
        color: Palette.bg,
        border: Border(bottom: BorderSide(color: Palette.borderHeader)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '8-WEEK ADVANCED · WOMEN',
                style: condensed(12, color: Palette.volt, letterSpacing: 1.9),
              ),
              _OutlineButton(label: 'RESET DAY', onTap: onReset),
            ],
          ),
          const SizedBox(height: 8),
          Text(day.title.toUpperCase(),
              style: condensed(34, weight: FontWeight.w800, height: 1.0)),
          const SizedBox(height: 5),
          Text(day.focus, style: body(13, color: Palette.textDim)),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < program.length; i++) ...[
                if (i > 0) const SizedBox(width: 7),
                Expanded(child: _DayTab(store: store, index: i)),
              ],
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 8,
                    backgroundColor: Palette.progressTrack,
                    valueColor: const AlwaysStoppedAnimation(Palette.volt),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('$done/$total SETS',
                  style: condensed(13, color: Palette.volt)),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              _Chip(
                  label: '${store.unitLabel} ⇄',
                  on: true,
                  onTap: store.toggleUnits),
              const SizedBox(width: 6),
              _Chip(
                label: 'AUTO-REST ${store.autoRest ? "ON" : "OFF"}',
                on: store.autoRest,
                onTap: store.toggleAutoRest,
              ),
              const SizedBox(width: 6),
              _Chip(
                label: 'BIG ${store.bigNumbers ? "ON" : "OFF"}',
                on: store.bigNumbers,
                onTap: store.toggleBigNumbers,
              ),
              const SizedBox(width: 6),
              _Chip(
                label: 'SCREEN ${store.keepAwake ? "ON" : "OFF"}',
                on: store.keepAwake,
                onTap: store.toggleKeepAwake,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayTab extends StatelessWidget {
  const _DayTab({required this.store, required this.index});

  final WorkoutStore store;
  final int index;

  @override
  Widget build(BuildContext context) {
    final active = index == store.activeDay;
    return GestureDetector(
      onTap: () => store.setActiveDay(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: active ? Palette.volt : Palette.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? Palette.volt : Palette.border),
        ),
        child: Column(
          children: [
            Text(
              'DAY ${index + 1}',
              style: condensed(
                15,
                weight: FontWeight.w800,
                color: active ? Palette.darkOnVolt : Colors.white,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              program[index].short,
              style: condensed(
                9,
                weight: FontWeight.w600,
                letterSpacing: 0.6,
                color: active
                    ? Palette.darkOnVolt.withValues(alpha: 0.62)
                    : Palette.textFaint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.on, required this.onTap});

  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: on ? Palette.volt.withValues(alpha: 0.12) : Palette.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: on ? Palette.volt.withValues(alpha: 0.4) : Palette.border,
          ),
        ),
        child: Text(
          label,
          style: condensed(
            11,
            letterSpacing: 0.9,
            color: on ? Palette.volt : Palette.textDim,
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF2E3137)),
        ),
        child: Text(
          label,
          style: condensed(11, color: Palette.textDim, letterSpacing: 1.1),
        ),
      ),
    );
  }
}
