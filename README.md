# Gym Tracker 🏋️‍♀️

A phone-first workout tracker for the **8-Week Advanced Muscle-Building Program (Women)** — 4 training days, 32 exercises.

Three versions live in this repo:

- **Flutter app (iOS + Android)** — in [`flutter/`](flutter/); **one codebase for both platforms**, with rest-timer notifications, haptics, and wakelock. See [`flutter/README.md`](flutter/README.md). *Recommended if you want the app on Android and iPhone.*
- **Web app (PWA)** — `index.html` at the root; no build step, works offline, installable from the browser on any phone
- **Native iOS app (SwiftUI)** — in [`ios/`](ios/); iPhone-only alternative to the Flutter app. See [`ios/README.md`](ios/README.md).

## Features

- **4 day tabs** — Lower & Core · Upper Body · Lower & Glutes · Upper Body
- **Tap-to-log sets** — enter weight + reps, tap the circle to check a set off; the card turns volt-green with a ✓ when all 3 sets are done
- **Rest timer** — auto-starts when you check a set (uses each exercise's programmed rest time), with PAUSE / +15s / skip, 3-2-1 countdown ticks, and a beep + vibration when time's up
- **Live progress bar** — sets completed for the day, right in the sticky header
- **▶ WATCH** — opens a YouTube form-check search for any exercise
- **Settings chips** — kg ⇄ lb label, auto-rest on/off, big-numbers mode for gym visibility, keep-screen-on (Wake Lock)
- **Saves automatically** — everything persists in `localStorage`; close mid-workout and pick up where you left off
- **Works offline** — installable PWA with a service worker, so it keeps working with no signal in the gym

## Use it on your phone

1. Host the folder anywhere static (GitHub Pages works great) and open the URL on your phone.
2. **Add to Home Screen** (Share → *Add to Home Screen* on iOS, or the install prompt on Android).
3. It launches full-screen like a native app and works offline.

## Development

No tooling required. Everything lives in:

| File | Purpose |
|---|---|
| `index.html` | The whole app — data, UI, logic |
| `sw.js` | Offline caching (app shell + fonts) |
| `manifest.webmanifest` | PWA install metadata |
| `icons/` | App icons |

To change the program, edit the `DATA` array at the top of `index.html`.
