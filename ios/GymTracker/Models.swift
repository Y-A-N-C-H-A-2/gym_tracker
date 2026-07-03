import Foundation

struct Exercise: Hashable {
    let name: String
    let sets: Int
    let reps: String
    let rest: Int // seconds

    var watchURL: URL {
        let query = "how to do \(name) exercise proper form"
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        return URL(string: "https://www.youtube.com/results?search_query=\(encoded)")!
    }
}

struct WorkoutDay {
    let title: String
    let focus: String
    let short: String
    let exercises: [Exercise]
}

/// One logged set: what the user typed plus the check-off state.
struct SetEntry: Codable, Equatable {
    var weight: String = ""
    var reps: String = ""
    var done: Bool = false
}

enum Program {
    static let days: [WorkoutDay] = [
        WorkoutDay(title: "Lower & Core", focus: "Quads · Strength · Core", short: "LOWER", exercises: [
            Exercise(name: "Dumbbell Step Up",         sets: 3, reps: "10–12 ea. leg", rest: 120),
            Exercise(name: "Barbell Back Squat",       sets: 3, reps: "10–12",         rest: 150),
            Exercise(name: "Leg Press / Hack Squat",   sets: 3, reps: "10–12",         rest: 150),
            Exercise(name: "DB Goblet Squat",          sets: 3, reps: "10–12",         rest: 120),
            Exercise(name: "Leg Extension",            sets: 3, reps: "15",            rest: 75),
            Exercise(name: "Leg Press Calf Raise",     sets: 3, reps: "15",            rest: 60),
            Exercise(name: "Weighted Crunch",          sets: 3, reps: "15",            rest: 60),
            Exercise(name: "Shoulder Taps",            sets: 3, reps: "10 ea. side",   rest: 60),
        ]),
        WorkoutDay(title: "Upper Body", focus: "Back · Chest · Shoulders · Arms", short: "UPPER", exercises: [
            Exercise(name: "Pull Up / Lat Pulldown",   sets: 3, reps: "10–12",         rest: 120),
            Exercise(name: "Seated Cable Row",         sets: 3, reps: "10–12",         rest: 120),
            Exercise(name: "Incline DB Bench Press",   sets: 3, reps: "10–12",         rest: 120),
            Exercise(name: "Tricep Dip",               sets: 3, reps: "10–12",         rest: 120),
            Exercise(name: "DB Front Raise",           sets: 3, reps: "10–12",         rest: 60),
            Exercise(name: "DB Tricep Extension",      sets: 3, reps: "12–15",         rest: 75),
            Exercise(name: "Concentration Curl",       sets: 3, reps: "12–15 ea. arm", rest: 60),
            Exercise(name: "Hanging Leg Raise",        sets: 3, reps: "12–15",         rest: 60),
        ]),
        WorkoutDay(title: "Lower & Glutes", focus: "Glutes · Hamstrings · Posterior Chain", short: "GLUTES", exercises: [
            Exercise(name: "Hip Thrust",               sets: 3, reps: "10–12",         rest: 150),
            Exercise(name: "Hip Abduction Machine",    sets: 3, reps: "10–12",         rest: 75),
            Exercise(name: "Romanian Deadlift",        sets: 3, reps: "10–12",         rest: 150),
            Exercise(name: "Walking Lunge",            sets: 3, reps: "10–12 ea.",     rest: 120),
            Exercise(name: "Lying Leg Curls",          sets: 3, reps: "12–15",         rest: 75),
            Exercise(name: "Seated Calf Raise",        sets: 3, reps: "15",            rest: 60),
            Exercise(name: "Glute Bridge Pallof Press", sets: 3, reps: "12",           rest: 60),
            Exercise(name: "Side Plank",               sets: 3, reps: "40–60s ea.",    rest: 60),
        ]),
        WorkoutDay(title: "Upper Body", focus: "Chest · Shoulders · Arms · Back", short: "UPPER", exercises: [
            Exercise(name: "Incline DB Flys",          sets: 3, reps: "10–12",         rest: 90),
            Exercise(name: "Dumbbell Pullover",        sets: 3, reps: "10–12",         rest: 90),
            Exercise(name: "Arnold Press",             sets: 3, reps: "10–12",         rest: 120),
            Exercise(name: "DB Lateral Raise",         sets: 3, reps: "10–12",         rest: 60),
            Exercise(name: "Skull Crushers",           sets: 3, reps: "15",            rest: 75),
            Exercise(name: "Rope Tricep Extension",    sets: 3, reps: "12–15",         rest: 75),
            Exercise(name: "Cable Curl",               sets: 3, reps: "10–12",         rest: 75),
            Exercise(name: "Wood Chop",                sets: 3, reps: "15 ea.",        rest: 60),
        ]),
    ]
}

func formatRest(_ seconds: Int) -> String {
    if seconds >= 60 {
        let m = seconds / 60, s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
    return "\(seconds)s"
}

func formatClock(_ seconds: Int) -> String {
    String(format: "%d:%02d", seconds / 60, seconds % 60)
}
