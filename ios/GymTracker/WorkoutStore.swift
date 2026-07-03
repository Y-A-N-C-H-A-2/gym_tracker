import Foundation
import Observation
import UIKit

@MainActor
@Observable
final class WorkoutStore {
    private static let logKey = "gymtracker.log.v1"
    private static let dayKey = "gymtracker.activeDay.v1"
    private static let settingsKey = "gymtracker.settings.v1"

    struct Settings: Codable, Equatable {
        var useLb = false
        var autoRest = true
        var bigNumbers = false
        var keepAwake = false
    }

    var activeDay: Int {
        didSet { UserDefaults.standard.set(activeDay, forKey: Self.dayKey) }
    }

    var log: [String: SetEntry] {
        didSet {
            if let data = try? JSONEncoder().encode(log) {
                UserDefaults.standard.set(data, forKey: Self.logKey)
            }
        }
    }

    var settings: Settings {
        didSet {
            if let data = try? JSONEncoder().encode(settings) {
                UserDefaults.standard.set(data, forKey: Self.settingsKey)
            }
            UIApplication.shared.isIdleTimerDisabled = settings.keepAwake
        }
    }

    var unitLabel: String { settings.useLb ? "LB" : "KG" }

    init() {
        let defaults = UserDefaults.standard
        activeDay = min(max(defaults.integer(forKey: Self.dayKey), 0), Program.days.count - 1)
        if let data = defaults.data(forKey: Self.logKey),
           let decoded = try? JSONDecoder().decode([String: SetEntry].self, from: data) {
            log = decoded
        } else {
            log = [:]
        }
        if let data = defaults.data(forKey: Self.settingsKey),
           let decoded = try? JSONDecoder().decode(Settings.self, from: data) {
            settings = decoded
        } else {
            settings = Settings()
        }
        UIApplication.shared.isIdleTimerDisabled = settings.keepAwake
    }

    // MARK: - Log access

    static func key(day: Int, exercise: Int, set: Int) -> String {
        "\(day)-\(exercise)-\(set)"
    }

    func entry(day: Int, exercise: Int, set: Int) -> SetEntry {
        log[Self.key(day: day, exercise: exercise, set: set)] ?? SetEntry()
    }

    func update(day: Int, exercise: Int, set: Int, _ change: (inout SetEntry) -> Void) {
        let key = Self.key(day: day, exercise: exercise, set: set)
        var entry = log[key] ?? SetEntry()
        change(&entry)
        log[key] = entry
    }

    /// Flips a set's done state and returns the new value.
    @discardableResult
    func toggleSet(day: Int, exercise: Int, set: Int) -> Bool {
        var newValue = false
        update(day: day, exercise: exercise, set: set) { entry in
            entry.done.toggle()
            newValue = entry.done
        }
        return newValue
    }

    func doneCount(day: Int, exercise: Int) -> Int {
        let ex = Program.days[day].exercises[exercise]
        return (0..<ex.sets).filter { entry(day: day, exercise: exercise, set: $0).done }.count
    }

    func exerciseDone(day: Int, exercise: Int) -> Bool {
        doneCount(day: day, exercise: exercise) == Program.days[day].exercises[exercise].sets
    }

    func dayProgress(day: Int) -> (done: Int, total: Int) {
        var done = 0, total = 0
        for (ei, ex) in Program.days[day].exercises.enumerated() {
            total += ex.sets
            done += doneCount(day: day, exercise: ei)
        }
        return (done, total)
    }

    func resetDay(_ day: Int) {
        log = log.filter { !$0.key.hasPrefix("\(day)-") }
    }
}
