class Exercise {
  final String name;
  final int sets;
  final String reps;
  final int rest; // seconds

  const Exercise(this.name, this.sets, this.reps, this.rest);

  Uri get watchUrl => Uri.https('www.youtube.com', '/results', {
        'search_query': 'how to do $name exercise proper form',
      });
}

class WorkoutDay {
  final String title;
  final String focus;
  final String short;
  final List<Exercise> exercises;

  const WorkoutDay(this.title, this.focus, this.short, this.exercises);
}

class SetEntry {
  String weight;
  String reps;
  bool done;

  SetEntry({this.weight = '', this.reps = '', this.done = false});

  Map<String, dynamic> toJson() => {'weight': weight, 'reps': reps, 'done': done};

  factory SetEntry.fromJson(Map<String, dynamic> json) => SetEntry(
        weight: json['weight'] as String? ?? '',
        reps: json['reps'] as String? ?? '',
        done: json['done'] as bool? ?? false,
      );
}

const program = <WorkoutDay>[
  WorkoutDay('Lower & Core', 'Quads · Strength · Core', 'LOWER', [
    Exercise('Dumbbell Step Up', 3, '10–12 ea. leg', 120),
    Exercise('Barbell Back Squat', 3, '10–12', 150),
    Exercise('Leg Press / Hack Squat', 3, '10–12', 150),
    Exercise('DB Goblet Squat', 3, '10–12', 120),
    Exercise('Leg Extension', 3, '15', 75),
    Exercise('Leg Press Calf Raise', 3, '15', 60),
    Exercise('Weighted Crunch', 3, '15', 60),
    Exercise('Shoulder Taps', 3, '10 ea. side', 60),
  ]),
  WorkoutDay('Upper Body', 'Back · Chest · Shoulders · Arms', 'UPPER', [
    Exercise('Pull Up / Lat Pulldown', 3, '10–12', 120),
    Exercise('Seated Cable Row', 3, '10–12', 120),
    Exercise('Incline DB Bench Press', 3, '10–12', 120),
    Exercise('Tricep Dip', 3, '10–12', 120),
    Exercise('DB Front Raise', 3, '10–12', 60),
    Exercise('DB Tricep Extension', 3, '12–15', 75),
    Exercise('Concentration Curl', 3, '12–15 ea. arm', 60),
    Exercise('Hanging Leg Raise', 3, '12–15', 60),
  ]),
  WorkoutDay('Lower & Glutes', 'Glutes · Hamstrings · Posterior Chain', 'GLUTES', [
    Exercise('Hip Thrust', 3, '10–12', 150),
    Exercise('Hip Abduction Machine', 3, '10–12', 75),
    Exercise('Romanian Deadlift', 3, '10–12', 150),
    Exercise('Walking Lunge', 3, '10–12 ea.', 120),
    Exercise('Lying Leg Curls', 3, '12–15', 75),
    Exercise('Seated Calf Raise', 3, '15', 60),
    Exercise('Glute Bridge Pallof Press', 3, '12', 60),
    Exercise('Side Plank', 3, '40–60s ea.', 60),
  ]),
  WorkoutDay('Upper Body', 'Chest · Shoulders · Arms · Back', 'UPPER', [
    Exercise('Incline DB Flys', 3, '10–12', 90),
    Exercise('Dumbbell Pullover', 3, '10–12', 90),
    Exercise('Arnold Press', 3, '10–12', 120),
    Exercise('DB Lateral Raise', 3, '10–12', 60),
    Exercise('Skull Crushers', 3, '15', 75),
    Exercise('Rope Tricep Extension', 3, '12–15', 75),
    Exercise('Cable Curl', 3, '10–12', 75),
    Exercise('Wood Chop', 3, '15 ea.', 60),
  ]),
];

String formatRest(int seconds) {
  if (seconds >= 60) {
    final m = seconds ~/ 60, s = seconds % 60;
    return s > 0 ? '$m:${s.toString().padLeft(2, '0')}' : '$m:00';
  }
  return '${seconds}s';
}

String formatClock(int seconds) =>
    '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
