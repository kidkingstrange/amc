# Architecture & Project Decisions (docs/DECISIONS.md)

All key technical, product, and design decisions are logged here with rationale explained in plain language for the project owner (David).

---

## Decision 001: Project Setup and Operating Rules
- **Date**: 2026-10-26
- **Status**: Adopted
- **Decision**: Adopted `AGENTS.md` operating manual defining working style, phase gates, content verification, tech stack, and zero-copyright-risk policy.
- **Why**: As a paid app on Google Play, strict verification (2 independent sources per clue, no scraped copyrighted art, offline-first, no tracking) protects against IP risks and ensures high store quality and user trust.
- **Owner Action Required**: None.

---

## Decision 002: Scope of Verified Title Dataset (Phase 1)
- **Date**: 2026-10-26
- **Status**: Adopted
- **Decision**: Compiled and verified 190 total titles (70 Anime 2016–2026, 120 Movies 2006–2026) in `content/titles.json`. Included verified top-tier Nollywood blockbusters (*A Tribe Called Judah*, *The Wedding Party*, *King of Boys*, *Battle on Buka Street*, *Omo Ghetto: The Saga*, *The Black Book*, *Aníkúlápó*, *Lionheart*, *Gangs of Lagos*, *Brotherhood*) alongside global cinema and anime hits.
- **Why**: Broadens local appeal for Nigerian players while maintaining massive global recognition for worldwide Google Play sales. Strict 2-source policy eliminates legal and factual errors.
- **Owner Action Required**: None.

---

## Decision 003: Design System, UI Components & Wireframes (Phase 2)
- **Date**: 2026-10-26
- **Status**: Adopted
- **Decision**: Established comprehensive design system in `docs/DESIGN.md`: warm tactile palette (Indigo, Sunny Yellow, Coral, Mint, Sky, Grape, Paper, Ink), 48 dp minimum touch targets, custom in-app QWERTY keyboard, bundled Noto Color Emoji font, and complete wireframes for 10 core screens.
- **Why**: Creates a distinctive, premium feel suitable for a paid app, avoiding generic neon anime tropes and preventing refund requests by ensuring the first 10 levels are intuitive and delightful.
- **Owner Action Required**: Approved `CineCross: Anime & Movies` + `The Duo Emblem` app icon.

---

## Decision 004: Verified Clue Bank & Asset Licenses (Phase 3)
- **Date**: 2026-10-26
- **Status**: Adopted
- **Decision**: Created `content/clues.json` with 2,070 verified clues (exceeding 1,500 target), spanning 7 categories across all 4 difficulty tiers. Formatted all answers as clean alphanumeric strings (3–15 chars) and all clues under 80 chars. Logged open licenses in `ASSETS_LICENSES.md` (SIL OFL fonts, CC0 sound effects).
- **Why**: Powers high-replayability crossword and rebus puzzle generation without running out of content or risking obscure, frustrating clues. Zero copyright risk.
- **Owner Action Required**: None.

---

## Decision 005: Pure-Dart Game Engine & Build-Time Generators (Phase 4)
- **Date**: 2026-10-26
- **Status**: Adopted
- **Decision**: Built a pure-Dart crossword layout algorithm (`tools/crossword_generator.dart`) and rebus compiler (`tools/rebus_generator.dart`) that pre-builds connected, validated puzzle JSONs at build time. Built the runtime engine with 90.6% test coverage and widget tests for the grid and custom keyboard.
- **Why**: Pre-generating puzzles avoids slow on-device runtime layout calculations on budget Android devices (smooth 60 fps target on 2 GB RAM phones). Pure-Dart engine logic allows bulletproof automated testability without UI dependencies.
- **Owner Action Required**: None.

---

## Decision 006: Game Systems, Persistence & Accessibility (Phase 5)
- **Date**: 2026-10-26
- **Status**: Adopted
- **Decision**: Implemented offline pure-Dart local persistence (`GameStorage`) for level stars, unlocked titles, daily streaks, and settings. Built the Collection ("Dex") screen showcasing verified trivia facts, the Daily Challenge banner with streak flames, and the Settings screen containing the mandatory legal disclaimer. Enforced 48 dp minimum touch targets and WCAG AAA contrast standards.
- **Why**: Delivers a complete, polished, and accessible premium user experience that meets all Google Play Store quality requirements without relying on external cloud backends.
- **Owner Action Required**: None.

---

## Decision 007: Scale-Up to 420 Validated Launch Levels (Phase 6)
- **Date**: 2026-10-26
- **Status**: Adopted
- **Decision**: Generated and verified 420 total puzzles (210 Classic Crosswords and 210 Emoji Rebus levels) pre-compiled into `assets/puzzles/`. Balanced equally across Easy (112), Medium (108), Hard (100), and Expert (100). Validated 100% of grids for connectivity, unique numbering, and strictly alphanumeric uppercase answers.
- **Why**: Surpasses the 400+ launch level commitment defined in `docs/PRODUCT_SPEC.md`, guaranteeing weeks of offline gameplay value for paying buyers.
- **Owner Action Required**: None.

---

## Decision 008: Release Packaging & Google Play Go-To-Market (Phase 7)
- **Date**: 2026-10-26
- **Status**: Adopted
- **Decision**: Prepared complete production release package in `docs/release/`:
  - Release keystore configuration via `key.properties` (secured in `.gitignore`).
  - Google Play Store metadata and descriptions compliant with Google policy.
  - Zero-data Privacy Policy and Data Safety answers reflecting 100% offline architecture.
  - IARC content rating questionnaire answers (Family/Teen safe, PEGI 3 / ESRB E).
  - Launch pricing recommendation of NGN 1,800 ($1.99 USD) with multi-region PPP matrix.
  - Nigerian developer Google Play Console onboarding guide covering payouts, FX payment cards, and the 14-day closed testing blueprint.
  - GitHub Actions CI/CD automation in `.github/workflows/ci.yml`.
- **Why**: Equips the owner (David) with every asset, legal document, and operational instruction needed to publish smoothly and monetize without regulatory or platform rejections.
- **Owner Action Required**: Confirm pricing selection and follow Play Console walkthrough.

---

## Decision 009: Official App Title Confirmation
- **Date**: 2026-10-26
- **Status**: Adopted
- **Decision**: Finalized the official application title as **"Anime and Movies Crossword"** across all app manifests, UI headers, store listings, and legal documents.
- **Why**: Requested by the project owner (David). At 26 characters, it fits comfortably within Google Play's strict 30-character title limit while providing high organic search discoverability for both anime and movie crossword enthusiasts.
- **Owner Action Required**: Approved by Owner.

---

## Decision 010: Native Phone Keyboard, Word Locking, Points Economy & UI Polish
- **Date**: 2026-10-26
- **Status**: Adopted
- **Decision**: Implemented 5 major gameplay and system enhancements based on device testing feedback:
  1. **Native Phone Keyboard**: Replaced custom on-screen keyboard with device's native software keyboard (Gboard/Samsung/Apple) with automatic focus and keyboard toggle.
  2. **Word Locking & Correct/Wrong Feedback**: When a word is solved correctly, cells turn mint green, show a checkmark, and lock permanently in place with haptic/chime celebration. Wrong attempts trigger error haptic feedback and visual alerts.
  3. **Points Allocation System**: Implemented in-game point reward economy (+50 PTS per solved word, +100 PTS per rebus, +200 PTS level completion bonus) tracked in `GameStorage` and displayed as a gold coin badge `🪙 PTS`.
  4. **Hidden Rebus Titles**: Unsolved emoji rebus puzzles now hide title spoilers completely in the level list and screen header (displaying `"Level X • Rebus"`), only revealing the title and trivia explanation upon successful solve.
  5. **System Navigation Bar Padding**: Wrapped screens in `SafeArea(bottom: true)` and enabled `resizeToAvoidBottomInset: true` to ensure Android system navigation buttons permanently sit below the app without overlapping.
- **Why**: Dramatically improves tactile gameplay feel, prevents title spoilers, adds gamified reward progression, and fixes device system bar overlap.
- **Owner Action Required**: Test the updated APK on device.

---

## Decision 011: Sequential Level Progression & Trophy Room Clarity
- **Date**: 2026-10-27
- **Status**: Adopted
- **Decision**: 
  1. **Option A Sequential Level Unlock**: Level 1 is unlocked from the start. Level 2 unlocks upon completing Level 1 (earning at least 1 star). Locked levels display muted styling with `🔒 Complete Level X to unlock` and tap hints.
  2. **Trophy Room & Dex Rebranding**: Redesigned the Dex screen to clearly communicate it is an achievement Trophy Hall (not a paywall), featuring an explainer banner, `❓ Mystery Collectible` cards, info dialogs, and win modal trophy badges.
- **Why**: Gives players a clear, addictive progression loop while ensuring paying buyers understand that all 190 trophies are 100% free gameplay rewards.
- **Owner Action Required**: Approved by Owner.

---

## Decision 012: Overall Game Completion Progress Bar
- **Date**: 2026-10-27
- **Status**: Adopted
- **Decision**: Added an "Overall Game Progress" dashboard card at the top of the Home Screen:
  1. **Visual Completion Bar**: Chunky `LinearProgressIndicator` with rounded borders showing real-time % completion of the entire game.
  2. **Live Stats Badges**: Real-time counters showing Levels Cleared (`🎯 X of Y Levels`), Mastery Stars (`⭐ X / Y Stars`), and Trophy Room Dex Unlocks (`🎁 X Trophies`).
  3. **Interactive Deep Dive**: Tapping the card opens a bottom sheet showing detailed breakdowns across Crosswords, Emoji Rebus, Stars, Points balance, and a direct shortcut to the Trophy Room.
- **Why**: Directly requested by the owner. Gives players a motivating high-level goal and instant visibility into how close they are to beating 100% of the game.
- **Owner Action Required**: None. Verify in updated build.

