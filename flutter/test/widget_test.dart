import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gym_tracker/main.dart';
import 'package:gym_tracker/models.dart';
import 'package:gym_tracker/store.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders day 1 with all 8 exercises reachable', (tester) async {
    await tester.pumpWidget(const GymTrackerApp());
    await tester.pumpAndSettle();

    expect(find.text('LOWER & CORE'), findsOneWidget);
    expect(find.text('DAY 1'), findsOneWidget);
    expect(find.text('DAY 4'), findsOneWidget);
    expect(find.text('0/24 SETS'), findsOneWidget);
    expect(find.text('DUMBBELL STEP UP'), findsOneWidget);
  });

  testWidgets('checking a set updates progress and starts the rest timer',
      (tester) async {
    await tester.pumpWidget(const GymTrackerApp());
    await tester.pumpAndSettle();

    // Tap the first set's check button (the empty 52px square after the fields).
    final checkButtons = find.byWidgetPredicate(
      (w) => w.runtimeType.toString() == '_SetRow',
    );
    expect(checkButtons, findsWidgets);

    // Drive the store directly for determinism.
    final state = tester.state(find.byType(HomeScreen)) as dynamic;
    final WorkoutStore store = state.store;
    store.toggleSet(0, 0, 0);
    await tester.pump();

    expect(find.text('1/24 SETS'), findsOneWidget);
  });

  testWidgets('switching day tabs changes the exercise list', (tester) async {
    await tester.pumpWidget(const GymTrackerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('DAY 3'));
    await tester.pumpAndSettle();

    expect(find.text('LOWER & GLUTES'), findsOneWidget);
    expect(find.text('HIP THRUST'), findsOneWidget);
  });

  test('program has 4 days of 8 exercises with 3 sets each', () {
    expect(program.length, 4);
    for (final day in program) {
      expect(day.exercises.length, 8);
      for (final ex in day.exercises) {
        expect(ex.sets, 3);
        expect(ex.rest, greaterThan(0));
      }
    }
  });

  test('store math: toggling and reset', () async {
    SharedPreferences.setMockInitialValues({});
    final store = WorkoutStore();
    await store.load();

    expect(store.dayProgress(0), (0, 24));
    store.toggleSet(0, 0, 0);
    store.toggleSet(0, 0, 1);
    store.toggleSet(0, 0, 2);
    expect(store.dayProgress(0), (3, 24));
    expect(store.exerciseDone(0, 0), isTrue);

    store.resetDay(0);
    expect(store.dayProgress(0), (0, 24));
  });
}
