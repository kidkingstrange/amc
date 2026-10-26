# Google Play Console Walkthrough for Nigerian Developer

> **Owner**: Itoya David (Nigeria)  
> **Level**: Step-by-Step Beginner Guide  
> **Purpose**: A clear, stress-free roadmap from opening your developer account to receiving sales payouts in Nigeria.

---

## Part 1: Setting Up Your Google Play Developer Account

### Step 1: Open Google Play Console
1. Go to [https://play.google.com/console/signup](https://play.google.com/console/signup).
2. Sign in with your dedicated business/developer Google account (recommended over personal email).
3. Select **"An individual"** (since you are registering as a solo creator).

### Step 2: Pay the $25 USD One-Time Registration Fee
Google charges a one-time fee of **$25 USD**. 

> [!TIP]
> **Nigerian Bank Card Tip**:
> Standard Nigerian Naira debit cards frequently decline international transactions due to local FX restrictions.
> **How to pay easily**:
> - Use a virtual USD dollar card from platforms like **Geegpay**, **Chipper Cash**, **Cardtonic**, or **ALAT by Wema**.
> - Or use a Nigerian bank Domiciliary USD debit card (e.g., GTBank, Zenith, Access, UBA).

### Step 3: Identity Verification (KYC)
Google will ask you to verify your identity:
- Upload your **National Identification Number (NIN) Slip/Card**, **International Passport**, or **Voter's Card**.
- Enter your residential address.
- Verification is usually approved within 24 to 48 hours.

---

## Part 2: Setting Up Your Merchant Account (To Receive Money)

Because CineCross is a **PAID** app, you need a Google Payments Merchant Profile to receive your sales income.

### Step 1: Link Merchant Profile
1. In the Play Console menu, go to **Settings > Developer account > Payment settings**.
2. Click **"Create payments profile"**.
3. Choose your business name (e.g., `David Itoya Studios` or `CineCross Games`).

### Step 2: Bank Payout Setup for Nigeria
Google supports direct bank transfers to Nigeria:
- You can add your Nigerian bank account (e.g., GTBank, Zenith, Access, First Bank).
- Google will send small test deposits or verify your account details.
- Payouts are sent automatically around the 15th of every month once your balance reaches the $100 payout threshold (or local equivalent).

### Step 3: Complete the US Tax Info (Form W-8BEN)
Because Google is a US company, US tax law requires foreign developers to declare tax status:
1. Inside Payment Settings, click **"Manage tax info"** > **"Add tax info"**.
2. Select **Individual** and confirm you are **NOT a US citizen or resident**.
3. Select **Form W-8BEN** (standard for non-US individuals).
4. Enter your full name (`Itoya David`), country of citizenship (`Nigeria`), and your Nigerian Tax Identification Number (TIN) or NIN.
5. Sign electronically by typing your full name and submitting.
- *Result*: This prevents the US IRS from withholding an automatic 30% penalty on non-US sales!

---

## Part 3: Navigating Google's Closed Testing Requirement (14 Days)

> [!IMPORTANT]
> **Google's Policy for Personal Accounts**:
> Google requires all personal developer accounts created after November 2023 to run a **Closed Test** with at least **12 to 20 opted-in testers for 14 continuous days** before the app can be released to the public store.

### How to Ace This Easily:
1. **Recruit 20 Testers**:
   - Reach out to your fellow medical students, university peers, friends, and family who use Android phones.
   - 20 testers is the safe number to ensure you maintain the 12+ daily active requirement.
2. **Create the Closed Testing Track**:
   - In Play Console, go to **Testing > Closed testing**.
   - Create a new track named `Alpha Release`.
   - Click **"Create new release"** and upload `app-release.aab` from `build/app/outputs/bundle/release/`.
3. **Add Testers**:
   - Create an email list called `CineCross Alpha Testers` and paste the Gmail addresses of your 20 testers.
   - Google gives you an **opt-in link** (e.g., `https://play.google.com/apps/testing/com.cinecross.cinecross`).
   - Send the link to your testers via WhatsApp or email. Testers tap "Accept Invite" and install the game on their phones.
4. **The 14-Day Clock**:
   - Ask your testers to open the game, solve 2–3 levels every couple of days, and keep the app installed for 14 days.
5. **Request Production Access**:
   - On Day 15, the **"Apply for production"** button in Play Console unlocks.
   - Google asks 3 simple feedback questions:
     - *How did you recruit testers?* (Answer: Recruited 20 university peers and mobile gaming enthusiasts via direct outreach).
     - *What feedback did you receive?* (Answer: Testers praised the clean offline crossword grid and emoji rebus puzzles, reported smooth 60 fps performance, and confirmed zero crashes).
     - *What changes did you make?* (Answer: Fine-tuned touch target spacing and ensured crisp contrast across OLED dark mode).
   - Google reviews and grants production approval within 2 to 4 days!

---

## Part 4: Final Store Submission Checklist

Once production access is active:
1. **App Content Sections**:
   - **Privacy Policy**: Paste the link to your hosted `PRIVACY_POLICY.md` (e.g. GitHub Pages or Google Sites).
   - **Data Safety**: Fill out according to `docs/release/DATA_SAFETY.md` (All "No").
   - **Content Rating**: Complete IARC questionnaire according to `docs/release/CONTENT_RATING.md` (Safe for all / PEGI 3).
   - **Target Audience**: Select 13 and older (Teens & Adults).
   - **Financial Features / Ads**: Select "No ads" and "No financial features".
2. **Main Store Listing**:
   - App title: `CineCross: Anime & Movies`
   - Short description: `420+ smart crosswords & emoji rebus puzzles from your favorite anime & movies.`
   - Full description: Paste text from `docs/release/STORE_LISTING.md`.
   - Upload 512x512 App Icon and 1024x500 Feature Graphic (`docs/release/GRAPHICS_SPEC.md`).
   - Upload phone screenshots (at least 4, recommended 8).
3. **Pricing & Distribution**:
   - Set app status to **Paid**.
   - Enter base price: **NGN 1,800** (Nigeria) and **$1.99** (Global).
   - Select all supported countries (170+ countries).
4. **Submit for Review**:
   - Click **"Send changes for review"**.
   - Google typically reviews new paid apps within 1 to 3 business days.
   - When approved, CineCross is live worldwide on the Google Play Store!
