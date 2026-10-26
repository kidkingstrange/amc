# Android Keystore Creation and Release Signing Guide

> **Audience**: David (Owner & Solo Developer)  
> **Level**: Beginner-friendly step-by-step  
> **Purpose**: Safely sign the Android App Bundle (`.aab`) without exposing security credentials to GitHub or third parties.

---

## 1. What is an Android Keystore?
Think of an Android Keystore like a digital signature stamp and wax seal on an official medical certificate. When you upload your game to Google Play, Google requires proof that every update comes from **you** and not an impostor. The keystore holds your private cryptographic key.

> [!CAUTION]
> **NEVER SHARE OR LOSE YOUR KEYSTORE FILE OR ITS PASSWORDS.**
> - Never commit your `.jks` file or `key.properties` to Git. (They are already protected in your `.gitignore`).
> - Back up your keystore file and passwords in a secure password manager or offline flash drive.

---

## 2. Step 1: Generate Your Upload Keystore
Open PowerShell in a safe folder on your computer (outside of Git, or directly in your local user profile):

```powershell
keytool -genkey -v -keystore "C:\Users\david\cinecross-upload-key.jks" -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias cinecross_upload
```

### What it will ask you:
1. **Keystore password**: Choose a strong password (at least 12 characters). Write it down!
2. **What is your first and last name?**: `Itoya David`
3. **What is the name of your organizational unit?**: `Mobile Games`
4. **What is the name of your organization?**: `David Itoya Studios` (or your company name)
5. **What is the name of your City or Locality?**: Your city (e.g., `Benin City` or `Lagos`)
6. **What is the name of your State or Province?**: Your state (e.g., `Edo` or `Lagos`)
7. **What is the two-letter country code?**: `NG`
8. **Is CN=..., OU=..., ... correct?**: Type `yes` and press Enter.

This generates `C:\Users\david\cinecross-upload-key.jks`.

---

## 3. Step 2: Configure `android/key.properties`
Inside your project folder `android/`, create a plain text file named `key.properties` (or copy it there).

Add these 4 lines:
```properties
storePassword=YOUR_KEYSTORE_PASSWORD_HERE
keyPassword=YOUR_KEYSTORE_PASSWORD_HERE
keyAlias=cinecross_upload
storeFile=C:\\Users\\david\\cinecross-upload-key.jks
```
*(Note: In Windows paths inside properties files, use double backslashes `\\`)*.

---

## 4. Step 3: Build the Signed Production AAB
In your terminal, navigate to the project directory and run:

```bash
flutter build appbundle --release
```

Flutter will automatically:
1. Detect `android/key.properties`.
2. Compile and compress your Dart code and 420 puzzle JSONs.
3. Cryptographically sign the bundle with your `cinecross_upload` key.
4. Output the production file at:
   `build/app/outputs/bundle/release/app-release.aab`

This `.aab` file is the exact file you upload to the Google Play Console!

---

## 5. Google Play App Signing
When creating your app on Google Play Console:
1. Google will ask if you want **Play App Signing** (Google manages the master signing key).
2. **Select YES (recommended)**.
3. This means Google securely holds the master delivery key in their data center. If your computer ever crashes or your upload key is lost, Google Support can easily reset your upload key so you can keep updating your game.
