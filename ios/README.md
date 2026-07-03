# Gym Tracker — iOS App (SwiftUI)

A fully native iOS version of the gym tracker. Same design and features as the web app, plus native extras:

- **Local notifications** — the rest-timer alarm reaches you even if your phone is locked or you switched apps
- **Haptics** — a tap when you check off a set, ticks on the 3-2-1 countdown, a strong buzz when rest is up
- **Wall-clock timer** — backgrounding the app doesn't drift the countdown
- **Keep Screen On** uses the native idle-timer, no browser Wake Lock quirks
- Portrait-locked, dark-mode-only, iPhone-only — built for one hand at the squat rack

## Requirements

- Xcode 16 or newer (the project uses folder-synchronized groups)
- iOS 17.0+ target

## Run it on your iPhone

1. Open `ios/GymTracker.xcodeproj` in Xcode.
2. Select the **GymTracker** target → **Signing & Capabilities** tab:
   - Choose your **Team** (your Apple ID).
   - Change the **Bundle Identifier** to something unique to you, e.g. `com.<yourname>.gymtracker`.
3. Plug in your iPhone (or pick a Simulator), select it as the run destination, and press **⌘R**.
4. First run on a real device: on the phone go to *Settings → General → VPN & Device Management* and trust your developer certificate.

## Ship it via TestFlight / App Store

1. Enroll in the [Apple Developer Program](https://developer.apple.com/programs/) ($99/year).
2. In [App Store Connect](https://appstoreconnect.apple.com), create a new app record with the same bundle identifier.
3. In Xcode: select **Any iOS Device (arm64)** as destination → **Product → Archive**.
4. In the Organizer window: **Distribute App → App Store Connect → Upload**.
5. In App Store Connect → your app → **TestFlight** tab: add yourself as an internal tester. You'll get an email invite; install via the TestFlight app on your phone.
6. For a public App Store release, fill in the app metadata + screenshots and submit for review from the **App Store** tab.

## Project layout

| File | Purpose |
|---|---|
| `GymTracker/GymTrackerApp.swift` | App entry point |
| `GymTracker/Models.swift` | Program data (4 days × 8 exercises), set-entry model |
| `GymTracker/WorkoutStore.swift` | Logged sets + settings, persisted to `UserDefaults` |
| `GymTracker/RestTimerManager.swift` | Countdown, notifications, sounds, haptics |
| `GymTracker/ContentView.swift` | Header, day tabs, progress bar, settings chips |
| `GymTracker/ExerciseCardView.swift` | Exercise cards and set rows |
| `GymTracker/RestTimerBar.swift` | The floating rest-timer bar |
| `GymTracker/Theme.swift` | Colors + condensed font helper |

To change the workout program, edit the `Program.days` array in `Models.swift`.
