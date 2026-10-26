# DESIGN.md: Design System, Tokens, Wireframes & Identity

> **Project**: Anime & Movies Crosswords (Paid Android Game)  
> **Target Experience**: Joyful, colorful, tactile, high-polish puzzle gaming with zero ads.  
> **Role**: UI/UX Designer & Lead Engineer  
> **Date**: 2026-10-26  
> **Status**: Approved for Implementation (Phase Gate 2)  

---

## 1. Design Philosophy

Unlike ad-driven free games that feel cluttered with banners, pop-ups, and harsh neon anime styling, **Anime & Movies Crosswords** is a premium, paid-upfront title. It must feel like opening a beautifully printed, tactile game book on your phone:
- **Warm & Delightful**: Rounded corners, organic shapes, friendly typography, and soft paper-like textures.
- **Immediate Clarity**: Minimum 48 dp touch targets. Never convey information through color alone (accessible for color-blind players and compatible with TalkBack screen readers).
- **Juicy Feedback**: Every tap has sound, haptic feedback, and smooth micro-animations (letter pop, streak flames, confetti bursts).
- **Distraction-Free**: 100% offline, zero banner real-estate, pure puzzle focus.

---

## 2. Design Tokens & Palette

### 2.1 Color Tokens
The color palette uses 8 core shades that can be paired seamlessly across light and dark themes:

| Token Name | Hex Code | Light Theme Usage | Dark Theme Usage |
| :--- | :--- | :--- | :--- |
| `primary` (Indigo) | `#4F46E5` | Primary buttons, active cell outline, brand hero | Vibrant focus highlights, active tab line |
| `accent-yellow` (Sunny) | `#FFC93C` | Stars, streak flame, celebration sparkles | High-contrast stars, streak badge |
| `accent-coral` (Coral) | `#FF6B6B` | Error badge, erase action, movie pack accent | Warning highlights, movie indicator |
| `accent-mint` (Mint) | `#2EC4B6` | Word solved celebration, success checkmark | Success state, anime pack accent |
| `accent-sky` (Sky) | `#4CC9F0` | Rebus letter slot, hint buttons | Active rebus cursor, secondary buttons |
| `accent-grape` (Grape) | `#9B5DE5` | Expert tier badge, special collection items | Mystery badges, expert banner |
| `surface-light` (Paper) | `#FFF9F0` | Default game background, clean card background | N/A |
| `surface-dark` (Ink) | `#1F2340` | Main text color, strong borders | Card background, puzzle container |
| `bg-dark` (Night) | `#121526` | N/A | Default deep background in dark mode |
| `cell-bg-light` | `#FFFFFF` | Crossword cell background | N/A |
| `cell-bg-dark` | `#1A1E36` | N/A | Crossword cell background in dark mode |
| `cell-active-light` | `#EEF2FF` | Highlighted word row/column | N/A |
| `cell-active-dark` | `#2D325A` | N/A | Highlighted word row/column in dark mode |

### 2.2 Pack Accent Pairings
Each themed pack receives an iconic accent pair to create instant visual personality:
- **Shonen Showdown**: Sunny Yellow (`#FFC93C`) & Coral (`#FF6B6B`)
- **Oscar Night**: Indigo (`#4F46E5`) & Sunny Yellow (`#FFC93C`)
- **Isekai & Fantasy Realm**: Mint (`#2EC4B6`) & Grape (`#9B5DE5`)
- **Nollywood Gold**: Coral (`#FF6B6B`) & Sunny Yellow (`#FFC93C`)
- **Sci-Fi & Cyber Futures**: Sky (`#4CC9F0`) & Indigo (`#4F46E5`)
- **Animated Classics**: Mint (`#2EC4B6`) & Sky (`#4CC9F0`)

### 2.3 Typography Tokens
- **Headings & Titles**: `Fredoka` or `Baloo 2` (Rounded, bubbly, warm, highly legible).
  - `Display Large`: 32 sp, Bold, letter spacing -0.5px.
  - `Title Medium`: 22 sp, Semi-bold.
  - `Title Small`: 18 sp, Medium.
- **Body & Clues**: `Nunito` (Exceptional readability at small sizes on compact screens).
  - `Clue Text`: 16 sp, Semi-bold (minimum 14 sp when scaled up for accessibility).
  - `Body Regular`: 14 sp, Regular.
  - `Caption`: 12 sp, Medium.
- **Grid Cell Letters**: Bold Monospace / Custom Sans-Serif (Centered, high contrast, dynamic scaling based on grid dimensions: 7x7 to 15x15).
- **Emoji Rendering**: **Bundled Noto Color Emoji font**. Never uses the system emoji font to ensure 100% identical cross-device rendering without broken boxes.

### 2.4 Spacing & Dimensions
- `touch-target-min`: 48 dp $\times$ 48 dp (Google Accessibility standard).
- `radius-sm`: 8 dp (chips, small badges).
- `radius-md`: 14 dp (buttons, puzzle cells).
- `radius-lg`: 24 dp (cards, bottom sheets).
- `elevation-card`: 0 dp offset, 8 dp blur, rgba(31, 35, 64, 0.08).

### 2.5 Haptic & Audio Feedback Map
- `HapticFeedback.lightImpact()`: Cell tap, keyboard key press.
- `HapticFeedback.mediumImpact()`: Word completed successfully, clue toggled.
- `HapticFeedback.vibrate()`: Error shake (invalid letter in check mode).
- `Celebratory Triple Buzz`: Full puzzle completed, 3-star win.
- Sound effects (synthesized or CC0 licensed in `assets/audio/`):
  - `tap.wav`: Subtle wooden block tick.
  - `word_done.wav`: Crisp bell chime.
  - `puzzle_win.wav`: Ascending joyful arpeggio.
  - `rebus_reveal.wav`: Magic sparkle swoosh.

---

## 3. Component Specifications

### 3.1 Crossword Grid Component
- **Adaptive Cell Size**: Automatically computes cell dimensions based on viewport width (e.g. 7x7 cells = 42 dp, 15x15 cells = 22 dp with two-finger pinch-to-zoom and pan support).
- **Cell States**:
  - `Default Empty`: White / Dark Ink with subtle 1.5 dp rounded border.
  - `Selected Focused`: Primary Indigo outline (2.5 dp) with pulsing cursor dot.
  - `Active Word Highlight`: Soft Indigo tint across all cells forming the current across/down word.
  - `Blocked Cell`: Elegant textured dark block (never jarring pitch-black).
  - `Pencil Mode`: Smaller gray draft letter in top-right corner.
  - `Checked Correct`: Subtle green pulse.
  - `Checked Error`: Red strike/flag for wrong letter.
- **Navigation Controls**:
  - Tapping an active cell toggles orientation between **Across** and **Down**.
  - Auto-advances to the next letter slot upon typing.
  - Backspace deletes current letter and auto-retreats to previous cell.

### 3.2 In-App Custom Keyboard
- Designed specifically for crosswords:
  - 3 rows of 26 letters (`QWERTY` layout).
  - Left button: **Pencil Mode Toggle** (Drafting vs Permanent).
  - Right button: **Backspace** with hold-to-clear.
  - Height fixed at ~210 dp so grid and clue bar remain visible without scrolling on standard screens.
  - Meets TalkBack screen reader requirements with custom semantic labels (e.g., "Letter A", "Pencil Mode Active").

### 3.3 Clue Navigation Bar
- Pinned directly above the keyboard:
  - Left Arrow (`<`) and Right Arrow (`>`) to hop to previous/next clue.
  - Direction Badge: `ACROSS [12]` or `DOWN [4]`.
  - Clue Text: Max 80 characters, crisp, high contrast.
  - Hint Icon: Floating magic wand button with available hint count badge.

### 3.4 Rebus Puzzle Card
- Top Area: Clean floating card containing the **Emoji Sequence** (e.g., 🦈 🌊 🚤).
- Extra Icon Slot: Original flat vector icon badge (e.g., movie camera or anime mask).
- Center: Segmented letter slots with fixed space / punctuation bars (e.g., `_ _ _ _   _ _ _ _ _ _`).
- Bottom Hint Ladder:
  1. *Hint 1*: Reveal Category & Year (e.g., "Movie, 2010").
  2. *Hint 2*: Reveal First Letter.
  3. *Hint 3*: Reveal Random Letter.
  4. *Hint 4*: Reveal Complete Emoji Explanation.
- Solved Reveal: Flipping animation reveals title poster motif, verified fun fact, and "Add to Dex" button.

---

## 4. Screen Wireframes & UX Flows

### 4.1 Screen 1: Splash & First-Run Experience
```
+------------------------------------------+
|                                          |
|                [ ICON ]                  |
|         Popcorn & Sword Emblem           |
|                                          |
|        ANIME & MOVIES CROSSWORDS         |
|         "Play Offline Trivia"            |
|                                          |
|         ( * ) ( * ) ( * ) ( * )          |
|                                          |
|       [ START PLAYING - LEVEL 1 ]        |
|                                          |
|       100% Offline • Zero Ads • No Logins|
+------------------------------------------+
```
*First-run magic*: No signups, no permissions requested. Clicking Start drops the player immediately into a 15-second interactive tutorial on Level 1.

### 4.2 Screen 2: Home Hub
```
+------------------------------------------+
| [=] Settings           🔥 Streak: 7 Days |
+------------------------------------------+
|  DAILY CHALLENGE                         |
|  [ ⭐ "Oscar Hits 2024" - Play Today ]   |
+------------------------------------------+
|  SELECT MODE:                            |
|                                          |
|  +-------------------+  +---------------+|
|  |  CLASSIC          |  |  EMOJI REBUS  ||
|  |  CROSSWORDS       |  |  TITLE GUESS  ||
|  |  200+ Grids       |  |  200+ Puzzles ||
|  |  [ CONTINUE > ]   |  |  [ PLAY > ]   ||
|  +-------------------+  +---------------+|
|                                          |
|  [ 📖 COLLECTION / DEX ]   [ 📊 STATS ]  |
+------------------------------------------+
```

### 4.3 Screen 3: Pack & Difficulty Selector
```
+------------------------------------------+
| [< Back]     CLASSIC CROSSWORDS          |
+------------------------------------------+
| [ EASY ]   [ MEDIUM ]   [ HARD ]   [EXP] |
+------------------------------------------+
|  PACKS:                                  |
|  +-------------------------------------+ |
|  | 🌟 SHONEN SHOWDOWN                  | |
|  | 25 Levels • Progress: [====--] 18/25 | |
|  | Stars: 51/75                        | |
|  +-------------------------------------+ |
|  +-------------------------------------+ |
|  | 🎬 BLOCKBUSTER ERA                  | |
|  | 30 Levels • Progress: [======] 30/30 | |
|  | Stars: 90/90  🏆 COMPLETED          | |
|  +-------------------------------------+ |
|  +-------------------------------------+ |
|  | 🇳🇬 NOLLYWOOD GOLD                   | |
|  | 20 Levels • Progress: [==----] 6/20  | |
|  +-------------------------------------+ |
+------------------------------------------+
```

### 4.4 Screen 4: Classic Crossword Screen
```
+------------------------------------------+
| [<] Level 14: Shonen Showdown     [💡 3] |
| Time: 02:45            [Check] [Pencil]  |
+------------------------------------------+
|                                          |
|        [ 1 ][ D ][ E ][ M ][ O ][ N ]    |
|        [   ][   ][   ][ U ][   ][   ]    |
|        [ S ][ L ][ A ][ Y ][ E ][ R ]    |
|        [   ][   ][   ][ A ][   ][   ]    |
|        [ T ][ A ][ N ][ J ][ I ][ R ][O] |
|                                          |
+------------------------------------------+
|  <  ACROSS 5: Fire-breathing swordsman > |
+------------------------------------------+
|   Q  W  E  R  T  Y  U  I  O  P           |
|    A  S  D  F  G  H  J  K  L             |
|  [✏️]  Z  X  C  V  B  N  M  [ ⌫ ]       |
+------------------------------------------+
```

### 4.5 Screen 5: Rebus Title Guess Screen
```
+------------------------------------------+
| [<] Rebus #42: Movies (Easy)      [💡 2] |
+------------------------------------------+
|                                          |
|        +------------------------+        |
|        |      🦈  🌊  🚤        |        |
|        |   [ Movie • 1975 ]     |        |
|        +------------------------+        |
|                                          |
|              [J] [A] [W] [S]             |
|                                          |
|        [ Reveal 1st Letter (Free) ]      |
+------------------------------------------+
|   Q  W  E  R  T  Y  U  I  O  P           |
|    A  S  D  F  G  H  J  K  L             |
|       Z  X  C  V  B  N  M  [ ⌫ ]         |
+------------------------------------------+
```

### 4.6 Screen 6: Victory & Fun Fact Screen
```
+------------------------------------------+
|              🎉 LEVEL COMPLETE!          |
|                                          |
|                 ⭐⭐⭐                   |
|                                          |
|         Time: 01:42 • Mistakes: 0        |
|                                          |
|  +-------------------------------------+ |
|  | 💡 UNLOCKED TRIVIA FACT:            | |
|  | "Jaws was the first film in history | |
|  | to cross $100M at the US box office"| |
|  | Source: Box Office Mojo             | |
|  +-------------------------------------+ |
|                                          |
|         [ 📖 VIEW IN COLLECTION ]        |
|         [ ➡️  NEXT LEVEL ]               |
+------------------------------------------+
```

### 4.7 Screen 7: Collection / "Dex" Screen
```
+------------------------------------------+
| [<] TRIVIA COLLECTION (DEX)      78/190  |
+------------------------------------------+
| [ ALL ]    [ ANIME (32) ]   [ MOVIES (46)]
+------------------------------------------+
|  🔍 Search title or character...         |
|                                          |
|  [ CARD: INCEPTION (2010) ]              |
|  Director: Christopher Nolan             |
|  Status: UNLOCKED ⭐⭐⭐                 |
|  Fact: Won 4 Academy Awards in 2011.     |
|                                          |
|  [ CARD: FREIREN (2023) ]                |
|  Studio: Madhouse                        |
|  Status: UNLOCKED ⭐⭐⭐                 |
|  Fact: Ranked #1 anime of all time on MAL|
|                                          |
|  [ CARD: ??? LOCKED ]                    |
|  Solve Rebus #88 to unlock!              |
+------------------------------------------+
```

### 4.8 Screen 8: Settings & Legal Screen
```
+------------------------------------------+
| [<] SETTINGS & ABOUT                     |
+------------------------------------------+
|  Sound Effects              [ ON  / off ]|
|  Haptic Vibration           [ ON  / off ]|
|  Theme: Dark Mode           [ on  / OFF ]|
|  Text Size Scale            [  Normal   ]|
|  Auto-Advance Cell          [ ON  / off ]|
|                                          |
|  LEGAL DISCLAIMER:                       |
|  "Unofficial fan trivia game. Not        |
|  affiliated with or endorsed by any      |
|  studio, distributor or rights holder.   |
|  All titles, character names and facts   |
|  belong to their respective owners."     |
|                                          |
|  App Version: 1.0.0 (Paid Edition)       |
+------------------------------------------+
```

---

## 5. Store & Brand Identity Proposals

To ensure zero trademark risk and maximum conversion on Google Play, we propose the following options for the Owner:

### 5.1 App Name Proposals (Choose 1)

1. **Option A (Recommended)**: `CineCross: Anime & Movies`
   - *Why*: Catchy, brandable, easy to remember. "Cine" honors cinema, "Cross" signifies crosswords. Avoids trademarked titles. Clean metadata.
2. **Option B**: `Popcorn Puzzles: Film & Anime`
   - *Why*: Warm, casual, highly recognizable iconography. Appeals to casual trivia lovers.
3. **Option C**: `Reel Crossword: Anime & Cinema`
   - *Why*: Classic film reel aesthetic, clear game mode description.

### 5.2 App Icon Concepts (Choose 1)

1. **Concept 1 (Recommended - The Duo Emblem)**:
   - A modern split flat badge: Left side has a golden butter popcorn bucket, right side has a sleek samurai katana handle, resting on a clean, rounded 2x2 crossword grid background in Indigo `#4F46E5`.
2. **Concept 2 (The Film Reel Letter)**:
   - A vintage 35mm film reel whose center spokes form a crossword letter "C", accented with colorful anime speed lines and star sparkles.
3. **Concept 3 (The Rebus Clue)**:
   - Two bright, flat illustrated emoji emblems (a sparkling spirit orb and a cinema camera) resting inside two rounded crossword tiles.
