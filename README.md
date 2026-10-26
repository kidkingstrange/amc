# CineCross: Anime & Movies 🎬⚔️

A premium, privacy-first, 100% offline word and trivia puzzle game built with Flutter for Android and iOS.

> **Target Release**: Paid upfront on Google Play Store  
> **Launch Target Price**: NGN 1,800 (Nigeria) / $1.99 USD (Global Base)  
> **Owner & Creator**: Itoya David (Nigeria)  
> **Date Cutoff**: 2026-10-26

---

## 🌟 Game Overview

CineCross gives players an uninterrupted, ad-free mobile trivia puzzle experience celebrating the greatest anime (2016–2026) and cinema (2006–2026), including global blockbusters and acclaimed Nollywood masterpieces.

### Two Engaging Game Modes
1. **Classic Crosswords**: Interconnected word grids with clues across character names, directors, studios, abilities, and plot trivia. Complete with pencil drafting mode, clue navigation, and letter check/reveal hints.
2. **Emoji & Icon Rebus**: Decode famous film and anime titles from visual emoji riddles (e.g. `🦈 🌊 🚤` -> *JAWS*), supported by an incremental 4-stage hint ladder and post-solve explanations.

### Content Library
- **420 Handcrafted & Validated Levels**: Pre-compiled as bundled JSON assets.
- **4 Difficulty Tiers**: Easy (112 levels), Medium (108 levels), Hard (100 levels), Expert (100 levels).
- **8 Themed Packs**: *Shonen Showdown*, *Sci-Fi & Time Travel*, *Blockbuster Hits*, *Fantasy & Magic*, *Mystery & Thriller*, *Nollywood & Global Cinema*, *Animation Legends*, and *Cult Classics & Modern Icons*.
- **Trivia Dex**: Unlock verified lore cards with behind-the-scenes facts for every solved title.
- **Daily Challenges**: Daily puzzles with a persistent streak flame (`🔥`) counter.

---

## 🛡️ Legal, IP & Privacy Commitments

- **Zero Copyrighted Art**: Contains 100% original flat iconography and typography. No scraped studio posters, film stills, character silhouettes, or audio tracks.
- **Strict Verification**: Every fact used in a clue has $\ge 2$ independent sources logged in `content/titles.json`.
- **100% Offline & Private**: Zero network permissions in `AndroidManifest.xml`. No tracking SDKs, no ads, no analytics, no user accounts.

---

## 🏗️ Architecture & Tech Stack

- **Framework**: Flutter Stable (Dart null-safe)
- **Game Engine**: Pure-Dart logic (`lib/engine/crossword_engine.dart`, `lib/engine/rebus_engine.dart`) completely decoupled from UI widgets.
- **Engine Test Coverage**: **90.6%** line coverage.
- **Local Persistence**: Pure-Dart offline file storage service (`lib/services/game_storage.dart`).
- **Typography & Assets**: Bundled Noto Color Emoji, Fredoka, and Nunito open-licensed fonts (`ASSETS_LICENSES.md`).
- **CI/CD**: GitHub Actions pipeline (`.github/workflows/ci.yml`) validating tests, static analysis, and release bundle builds.

---

## 📁 Repository Structure

```text
├── assets/
│   ├── fonts/                   # Open-source bundled fonts (Noto Color Emoji, Fredoka, Nunito)
│   └── puzzles/
│       ├── crosswords/          # 210 validated crossword JSON levels (cw_001 to cw_210)
│       └── rebus/               # 210 validated rebus JSON levels (rebus_001 to rebus_210)
├── content/
│   ├── titles.json              # 190 verified anime & movie titles with 2+ sources each
│   └── clues.json               # 2,070 verified trivia clues across 7 categories
├── docs/
│   ├── DESIGN.md                # Color palette tokens, UI components, wireframes
│   ├── DECISIONS.md             # Architecture & product decision log (Decisions 001–008)
│   ├── PROJECT_LOG.md           # Activity log across all project phases
│   ├── PRODUCT_SPEC.md          # Full product requirements specification
│   ├── qa/                      # Phase QA audit reports (100% verification)
│   └── release/
│       ├── KEYSTORE_AND_SIGNING.md       # Android keystore generation guide
│       ├── STORE_LISTING.md              # Google Play copy, title & descriptions
│       ├── GRAPHICS_SPEC.md              # 512x512 icon, 1024x500 banner, screenshots
│       ├── PRIVACY_POLICY.md             # Zero-data privacy policy document
│       ├── DATA_SAFETY.md                # Play Console Data Safety form answers
│       ├── CONTENT_RATING.md             # IARC rating questionnaire answers
│       ├── PRICING_RECOMMENDATION.md     # Pricing strategy (NGN 1,800 / $1.99)
│       └── PLAY_CONSOLE_WALKTHROUGH.md   # Nigerian developer onboarding & 14-day testing
├── lib/
│   ├── engine/                  # Pure-Dart crossword & rebus runtime engines
│   ├── models/                  # Title, clue, and puzzle data models
│   ├── services/                # Local offline persistence (GameStorage)
│   └── ui/                      # Responsive Flutter widgets and screens
├── test/                        # Comprehensive unit and widget test suite (23 tests passing)
└── tools/                       # Build-time generators and verification CLI scripts
```

---

## 🚀 How to Run & Build

### Running Locally
```bash
# Get dependencies
flutter pub get

# Run test suite
flutter test

# Verify all 420 puzzle JSONs
dart tools/verify_all_puzzles.dart

# Run app (Windows desktop or Chrome web)
flutter run -d windows
```

### Building the Production Android App Bundle (`.aab`)

#### Option A: Cloud Build via GitHub Actions (Zero Local Setup)
1. Push this repository to your private GitHub account.
2. In your repo, go to **Actions** > **CineCross CI**.
3. GitHub automatically runs tests and builds the release bundle `app-release.aab`.
4. Download the built artifact directly from the GitHub Actions run summary.

#### Option B: Local Android Build
1. Follow [`docs/release/KEYSTORE_AND_SIGNING.md`](docs/release/KEYSTORE_AND_SIGNING.md) to generate your upload key.
2. Place your `key.properties` in the `android/` directory.
3. Run:
   ```bash
   flutter build appbundle --release
   ```
4. Output will be generated at:
   `build/app/outputs/bundle/release/app-release.aab`

---

## ⚖️ License & Attribution
- App source code © 2026 Itoya David. All rights reserved.
- Fonts licensed under the SIL Open Font License (OFL 1.1).
- Sound effects licensed under Creative Commons 0 (Public Domain).
- Unofficial fan trivia game created under fair use for educational and entertainment purposes.
