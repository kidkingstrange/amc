# AGENTS.md: Anime & Movies Crosswords

## MISSION
Build, test and ship a PAID Android game, "Anime & Movies Crosswords", to Google Play. Working name only: never put franchise names in the app title. Today's date is 2026-10-26; treat it as the research cutoff.
Full detail lives in docs/PRODUCT_SPEC.md. Read it before every phase.

## OWNER AND WORKING STYLE
- Owner: Itoya David (Nigeria), a medical student and entrepreneur. He has never built a game and delegates ALL design, content and engineering decisions to you.
- Explain decisions in plain beginner language. Give the reason for every major choice.
- Decide, document in docs/DECISIONS.md, and proceed. Ask the owner only when blocked on something that is truly his (price, legal sign-off, accounts, payments).
- Use Planning mode for every phase. Produce a plan artifact first and wait for approval at each phase gate.

## PRODUCT
- Paid upfront app on Google Play. Launch price target NGN 1,500 to 2,500, allowed range NGN 1,000 to 5,000. Final price is the owner's call at Gate 7.
- No ads. No in-app purchases at launch. Fully offline. No account or login. Collect no personal data.
- Two modes: (1) Classic Crossword, (2) Emoji/Icon Title Guess (rebus). Details in the spec.
- Content: biggest anime of 2016-2026 and most popular movies of 2006-2026.
- Four difficulty tiers: Easy, Medium, Hard, Expert. Target 400+ levels at launch across both modes.
- Colorful, fun, polished. NOT generic neon "anime" styling. Palette and style are in the spec.
- Build with Flutter flavors so a free "Lite" demo (first ~30 levels) can be built from the same code as a SEPARATE store listing later. Do not build it unless asked.

## TECH STACK (change only with a written justification)
- Flutter stable, Dart, null-safe, Android first, iOS-ready.
- Riverpod for state, go_router for navigation, Isar or Hive for local save data.
- Puzzles ship as bundled JSON assets, generated at build time by scripts in tools/.
- Audio via just_audio or audioplayers. No analytics, no ads SDKs, no network permissions in the paid build.
- Emoji must render identically on every device: bundle Noto Color Emoji as an app font. Never rely on the system emoji font.
- Pure-Dart game engine with unit tests (90%+ coverage on engine). Widget tests for grid and keyboard.
- Target: smooth 60 fps on a 2 GB RAM phone, AAB under 60 MB.
- GitHub Actions CI: analyze, test, build AAB.

## CONTENT AND IP RULES (non-negotiable)
This app is SOLD, so legal risk is higher than for a free app.
- NEVER scrape, copy or ship official posters, screenshots, key art, logos, character art, theme music or trailers.
- Allowed art: original illustrations drawn by us in a consistent flat style using generic motifs (swords, masks, popcorn, film reels, spirit orbs), and licensed assets logged in ASSETS_LICENSES.md (CC0, Apache, OFL, or CC-BY with attribution shown in-app).
- Emoji and icon puzzles use emoji and original icons only, never official imagery.
- Facts only: titles, years, studios, directors, cast, character names and plot basics. No long quotes. Paraphrase everything.
- In-app disclaimer on the About screen and the store listing: "Unofficial fan trivia game. Not affiliated with or endorsed by any studio, distributor or rights holder. All titles belong to their owners."
- Play Store title, icon, screenshots and description must NOT use other brands' names, characters or keyword lists of titles. Flag any risky wording for the owner.
- Never present the app as official. Never imply endorsement.

## RESEARCH RULES
- Tools: use the browser for research. Priority order: (1) TMDB API (movies), AniList GraphQL and Jikan/MyAnimeList (anime), Wikipedia and Wikidata, official studio sites; (2) ranking signals: MAL and AniList popularity/score, Box Office Mojo and The Numbers, IMDb, Letterboxd, award results; (3) trade press: Variety, Deadline, Anime News Network. Avoid forums, single fan wikis and AI-written listicles.
- Choose titles by objective popularity signals, not taste. Log the signal for every inclusion.
- Every fact used in a clue needs 2 independent sources, logged in content/titles.json. If it cannot be verified, mark it UNVERIFIED and exclude it from puzzles.
- Check API terms and attribution requirements (TMDB requires attribution) and comply.
- Never fabricate facts, sources, ratings or quotes.
- No spoilers in Easy or Medium. Hard and Expert spoilers must be tagged.

## ENGINEERING RULES
- Clean feature-first structure. Comment non-obvious logic. Conventional commits.
- Generators validate every puzzle: valid connected grid, correct numbering, unique answers, answers A-Z/0-9 only, minimum length 3. Rejected puzzles go in a human-readable report.
- Accessibility: 48 dp touch targets, never color alone, scalable text, TalkBack labels. Dark mode required.
- No dark patterns: no fake timers or pressure tactics. Keep the tone child-safe.

## PHASE GATES (stop and present to the owner at each)
1. Research and scope: title list with popularity justification.
2. Design: DESIGN.md, palette, wireframes, final app name and icon.
3. Content: verified clue bank (1,500+ clues) and license log.
4. Engine and generators: playable prototype, 20 levels, both modes.
5. Full UI polish and all game systems.
6. Content scale-up to launch target plus QA reports.
7. Release package: signed AAB, store listing, privacy policy, Data Safety answers, content rating answers, screenshots, pricing recommendation, Play Console walkthrough.
At each gate report: what was done, risks, what you need from the owner, next steps. Maintain docs/PROJECT_LOG.md and docs/DECISIONS.md.

## AGENT ROLES (use the Manager view to run these in parallel where safe)
Researcher, Puzzle Designer, UI/UX Designer, Flutter Engineer, Content QA (re-checks 20% of clues against sources), Release Manager. Hand off through files in the repo, never through memory. Each agent logs its work in PROJECT_LOG.md.

## NEVER
Invent facts. Ship copyrighted art. Add trackers or ads. Skip a gate. Store secrets, keys or keystores in the repo. Commit the Android signing keystore.
