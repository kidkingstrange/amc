# PRODUCT SPEC: Anime & Movies Crosswords

## 1. Game modes

### 1A. Classic Crossword
- Clue types: title from description, character from description, who voiced/played, director/studio, fill-in-the-blank, abilities/terms, number/year answers.
- Clues under ~80 characters, fun, fair, one unambiguous answer.
- Mixed packs plus anime-only and movie-only packs.
- Puzzle screen: tap a cell to toggle across/down, current clue pinned above a custom in-app keyboard, next/previous clue arrows, auto-advance, pencil mode, check letter/word/puzzle, reveal letter/word, undo, optional timer.

### 1B. Emoji/Icon Title Guess (rebus mode)
- Show a short emoji sequence (2-6 symbols) that represents a title. The player fills letter slots (spaces and punctuation shown as fixed separators). Example format: 🦈🌊🚤 -> the answer is a famous movie title.
- Tiers: Easy = famous titles, obvious emoji. Medium = partial pun/rebus. Hard = abstract or multi-step rebus, anime titles with subtle clues. Expert = deep cuts, minimal hints.
- Each puzzle needs: the emoji string, the answer, a one-line "why" explanation shown AFTER solving, a category tag (anime/movie/genre), difficulty, and a verified title entry.
- Hint ladder: (1) reveal category and year, (2) reveal the first letter, (3) reveal a random letter, (4) show the full emoji explanation.
- Original icon packs: the Designer creates a consistent flat-icon set (swords, masks, rockets, ghosts, ramen, film reels) used as extra visual clues alongside emoji.
- Check every emoji exists in the bundled Noto Color Emoji font version. Never use emoji that render as blank boxes on older Android versions.
- Reject any puzzle where a typical player could reasonably get a different answer, and log it.

## 2. Levels and difficulty
- Easy: grids 7x7 to 9x9, famous titles, direct clues, generous hints.
- Medium: 9x9 to 11x11, light wordplay.
- Hard: 11x11 to 13x13, creators and studios, secondary characters.
- Expert: 13x13 to 15x15, deep cuts, minimal hints, tagged spoilers.
- Launch target: 100+ levels per tier across both modes (400+ total).
- Themed packs with their own accent colors, for example Shonen Showdown, Isekai, Sports Anime, Sci-Fi, Horror Night, Oscar Night, Animated Hits, Superhero Era.
- Daily puzzle with a streak counter and a weekly themed challenge.
- Stars per puzzle based on mistakes, hints used and speed.

## 3. Collection ("Dex")
- Every solved title is unlocked in a collection screen with a verified fun fact (facts from the verified dataset only).
- Progress bar per pack and per mode.

## 4. Visual design
- Palette: Indigo #4F46E5, Sunny Yellow #FFC93C, Coral #FF6B6B, Mint #2EC4B6, Sky #4CC9F0, Grape #9B5DE5, Ink #1F2340, Paper #FFF9F0. Each pack gets its own accent pair. Dark mode required.
- Fonts: Fredoka or Baloo 2 for headings, Nunito for body and clues, a bold clear font in grid cells.
- Rounded cells, soft shadows, letter-pop animation, confetti on word complete, streak flame, satisfying sound and haptics.
- Screens: Splash, Home, Level Map per tier, Puzzle (both modes), Hints modal, Win screen, Collection, Stats, Settings (sound, haptics, theme, text size), About/Disclaimer/Credits.
- Deliver DESIGN.md with tokens, components and wireframes BEFORE coding UI. The first-run experience and the first 10 levels must be excellent because the buyer has paid and refunds are easy.

## 5. Content dataset
content/titles.json fields: id, type (anime|movie), title, altTitles, year, studioOrDirector, genres, popularitySignals[], characters[], keyTerms[], facts[{text, sources[]}], spoilerLevel, emojiCandidates[], status (VERIFIED|UNVERIFIED).
- Anime target: 60-80 titles from 2016-2026 (big long-running hits still relevant, breakout hits, theatrical anime).
- Movies target: 100-150 titles from 2006-2026 across genres, including global crossovers from Nollywood, Bollywood and K-cinema where genuinely popular.
- Include things Nigerian players will recognize, but select on evidence, not on assumption.

## 6. Monetization and pricing
- Model: paid upfront, one price, no ads, no IAP at launch.
- Because buyers cannot try before they buy, protect conversion with: strong screenshots, a short honest description, a polished first 10 levels, and a clear refund-friendly experience.
- Recommend one launch price and a later "launch sale" plan in NGN within NGN 1,000-5,000, with reasoning (local purchasing power, comparable paid games). The owner decides.
- Note for the owner: Google does not let a free app be switched to paid later, and a paid app can be made free. Future paid expansion packs would need Play Billing, which is out of scope until the owner asks.
- Consider a separate free "Lite" listing as marketing. Build with Flutter flavors so this stays cheap. Do not implement it unless the owner asks.
- Optional piracy protection: evaluate Play licensing/Play Integrity checks for the paid build and recommend whether it is worth the complexity.

## 7. Release checklist (Phase 7)
- Play Console developer account and merchant/payments profile: write a first-timer step-by-step for a Nigeria-based developer. Verify current payout requirements and tax forms at the time.
- Closed testing: write the tester recruitment plan. Verify the CURRENT closed-testing requirement for new personal accounts (recently 12 testers for 14 days) because it changes.
- Signed AAB with Play App Signing. Keep the keystore OUT of the repo and tell the owner how to back it up safely.
- Privacy policy (hosted page text), Data Safety form answers, content rating questionnaire answers, target audience and ads declarations, all drafted and truthful.
- Store listing: title, short description, full description, 8 screenshots, feature graphic, icon (all original), ASO keywords checked against Play's metadata policy (no misleading or keyword-stuffed text, no third-party brand names).
- Pre-launch IP review: list every title name appearing in the app, confirm only factual/text use, confirm no official art, disclaimer visible.
- Post-launch: crash monitoring through Play Console vitals, a monthly content pack plan (new anime seasons and releases), and a support email.

## 8. Definition of done
All 7 gates approved, CI green, all puzzles validated, QA report signed off, zero official art, every clue sourced, and a release folder containing the AAB, listing assets, legal text and a walkthrough.
