import Foundation
import Observation
import UserNotifications
import AudioToolbox
import UIKit

/// Drives the rest countdown. Time is computed from a wall-clock end date so the
/// timer stays correct when the app is backgrounded; a local notification fires
/// at the end so the alarm reaches the user even with the screen locked.
@MainActor
@Observable
final class RestTimerManager {
    var exerciseName = ""
    var totalSeconds = 0
    var remaining = 0
    var isRunning = false
    var isActive = false

    private var endDate: Date?
    private var ticker: Timer?
    private let notificationID = "gymtracker.rest.done"

    var isFinished: Bool { isActive && remaining <= 0 }
    var progress: Double {
        totalSeconds > 0 ? max(0, min(1, Double(remaining) / Double(totalSeconds))) : 0
    }
    var label: String { isFinished ? "DONE — NEXT SET" : "REST" }

    func start(name: String, seconds: Int) {
        requestPermissionIfNeeded()
        exerciseName = name
        totalSeconds = seconds
        remaining = seconds
        isActive = true
        resume()
    }

    func addFifteen() {
        guard isActive else { return }
        totalSeconds += 15
        remaining += 15
        if isRunning {
            endDate = Date().addingTimeInterval(TimeInterval(remaining))
            scheduleNotification()
        } else {
            resume()
        }
    }

    func togglePause() {
        guard isActive else { return }
        if isRunning {
            pause()
        } else if remaining > 0 {
            resume()
        }
    }

    func stop() {
        pause()
        isActive = false
    }

    /// Re-sync the countdown after the app returns to the foreground.
    func refreshFromClock() {
        guard isRunning, let end = endDate else { return }
        let secondsLeft = Int(ceil(end.timeIntervalSinceNow))
        if secondsLeft <= 0 {
            // The local notification already alerted the user while backgrounded.
            finish(playAlarm: false)
        } else {
            remaining = secondsLeft
        }
    }

    // MARK: - Internals

    private func pause() {
        isRunning = false
        ticker?.invalidate()
        ticker = nil
        endDate = nil
        cancelNotification()
    }

    private func resume() {
        guard remaining > 0 else { return }
        isRunning = true
        endDate = Date().addingTimeInterval(TimeInterval(remaining))
        scheduleNotification()
        startTicker()
    }

    private func startTicker() {
        ticker?.invalidate()
        let timer = Timer(timeInterval: 0.25, repeats: true) { _ in
            Task { @MainActor [weak self] in self?.tick() }
        }
        RunLoop.main.add(timer, forMode: .common)
        ticker = timer
    }

    private func tick() {
        guard isRunning, let end = endDate else { return }
        let secondsLeft = max(0, Int(ceil(end.timeIntervalSinceNow)))
        if secondsLeft != remaining {
            remaining = secondsLeft
            if (1...3).contains(secondsLeft) {
                AudioServicesPlaySystemSound(1057) // short tick
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
        if secondsLeft <= 0 {
            finish(playAlarm: true)
        }
    }

    private func finish(playAlarm: Bool) {
        isRunning = false
        ticker?.invalidate()
        ticker = nil
        endDate = nil
        remaining = 0
        cancelNotification()
        if playAlarm {
            AudioServicesPlaySystemSound(1005)
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    private func requestPermissionIfNeeded() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    private func scheduleNotification() {
        cancelNotification()
        guard remaining > 0 else { return }
        let content = UNMutableNotificationContent()
        content.title = "Rest over — next set!"
        content.body = exerciseName
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(remaining), repeats: false)
        let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationID])
    }
}
