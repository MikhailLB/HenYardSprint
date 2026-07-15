# Hen Yard Sprint — Poultry Feed Calculator

Bright, juicy Disney-farm styled **Feed Calculator** built with **Flutter** (English UI).
Targets iOS (iPhone/iPad) and Android.

Bundle ID: `com.henyardsprint.henyardsprintgame`

## Features

- **Splash screen** — full-bleed artwork (vertical for portrait, horizontal for
  landscape), animated progress bar, **Loading** label with bouncing dots.
- **Feed Calculator** — juicy, animated UI:
  - flock size, bird type (Chicks / Growers / Layers) with typical daily intake,
    fine-tune grams per bird, planning period, bag size (10/25/50 kg), price per kg;
  - live results with animated counters: **daily feed**, **total feed**,
    **bags needed**, **estimated cost**.
- **Settings + WebView:**
  - Privacy Policy → `https://henyardsprint.com/privacy-policy.html`
  - Support → `https://henyardsprint.com/support.html`

## Project layout

```
lib/
  main.dart                     app entry + theme
  theme.dart                    colors, fonts (Fredoka), shadows
  widgets/pressable.dart        juicy press-scale feedback
  screens/
    splash_screen.dart          loading screen
    calculator_screen.dart      feed calculator
    settings_screen.dart        settings list
    web_view_screen.dart        in-app WebView (Privacy / Support)
assets/images/                  chicken sprites, feed icons, loading backgrounds
assets/icon/app_icon.png        source for launcher icons
_source_assets/                 original artwork + slicing scripts
```

Assets were derived from the supplied artwork: the sprite sheet was sliced and had its
black background removed (`_source_assets/slice.py`); the feed sack and feed bowl were
AI-generated on a chroma-green background and keyed out (`_source_assets/chroma.py`).

## Dependencies

- `google_fonts` — Fredoka display font
- `webview_flutter` — in-app Privacy Policy / Support pages
- `shared_preferences` — lightweight storage (available for future use)
- `flutter_launcher_icons` (dev) — app icon generation

## Run / build

```bash
flutter pub get
flutter run                     # run on a device/simulator

# iOS release build (validated):
flutter build ios --no-codesign

# App icons (already generated):
dart run flutter_launcher_icons
```

For App Store signing, open `ios/Runner.xcworkspace` in Xcode and select your team.

## App Store note

Real, self-contained utility (feed calculator) — no user-generated content, no ads,
no external payment links. Feed values are guidance with an in-app disclaimer.
