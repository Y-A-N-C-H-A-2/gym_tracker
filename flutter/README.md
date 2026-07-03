# Gym Tracker — Flutter App (iOS + Android)

One codebase, both platforms. Same design and features as the web app and the native SwiftUI version, including the native extras:

- **Local notifications** — the rest-timer alarm fires even with the phone locked or the app backgrounded (exact-alarm delivery on Android, time-sensitive interruption level on iOS)
- **Haptics** — a tap when you check off a set, light ticks on the 3-2-1 countdown, a heavy buzz when rest is up
- **Wall-clock timer** — backgrounding the app doesn't drift the countdown
- **Keep Screen On** via wakelock
- **Real Barlow / Barlow Condensed fonts** (google_fonts)
- Portrait-locked, dark-only

## Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.32+ (stable channel)
- For iOS builds: a Mac with Xcode 16+ and CocoaPods
- For Android builds: Android Studio or the Android SDK command-line tools

## Run it

```bash
cd flutter
flutter pub get
flutter run          # runs on whatever device/simulator is connected
```

- **iPhone:** plug it in, `flutter run`, and accept the signing prompt in Xcode the first time (open `ios/Runner.xcworkspace`, pick your Team under Signing & Capabilities, and set a unique bundle identifier).
- **Android phone:** enable USB debugging, plug it in, `flutter run`. That's it — no account needed.

## Ship it

**Android (easiest to share):**
```bash
flutter build apk --release
```
The APK lands in `build/app/outputs/flutter-apk/app-release.apk` — you can install it directly on any Android phone or upload an app bundle (`flutter build appbundle`) to Google Play ($25 one-time fee).

**iOS (TestFlight / App Store):**
```bash
flutter build ipa
```
Then upload the archive from Xcode's Organizer (or with `xcrun altool`) to App Store Connect. Requires the Apple Developer Program ($99/year). Full steps mirror `../ios/README.md`.

## Project layout

| File | Purpose |
|---|---|
| `lib/main.dart` | App entry, home screen, header, day tabs, settings chips |
| `lib/models.dart` | Program data (4 days × 8 exercises), set-entry model |
| `lib/store.dart` | Logged sets + settings, persisted with `shared_preferences` |
| `lib/rest_timer.dart` | Countdown, scheduled notifications, haptics |
| `lib/widgets/exercise_card.dart` | Exercise cards and set rows |
| `lib/widgets/timer_bar.dart` | The floating rest-timer bar |
| `lib/theme.dart` | Palette + Barlow Condensed text styles |
| `test/widget_test.dart` | Widget + store unit tests (`flutter test`) |

To change the workout program, edit the `program` list in `lib/models.dart`.

## Verified

`flutter analyze` — no issues; `flutter test` — 5/5 passing. (Device builds need to run on your machine: Android needs the Android SDK, iOS needs a Mac.)
