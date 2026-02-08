# PhishGuard Lite

PhishGuard Lite is a Flutter mobile application that helps users **analyze phishing messages** and keep a record of suspicious content.  
The user can create a phishing report (message text, optional URL, optional screenshot), and the app calculates a clear **risk score (0–100)** with a label (**Safe / Suspicious / Dangerous**). Reports are saved offline and can be optionally synced to the cloud.

---

## ✨ Key Features
- **Authentication**: Register/Login with Email & Password (Firebase Auth)
- **Phishing Reports**:
  - Add report with message text + optional URL + optional image
  - Automatic **risk scoring** + matched keyword explanation
- **Local Storage**:
  - **Sqflite** for saving reports offline
  - **SharedPreferences** for settings (theme + cloud sync toggle)
- **Images**: pick from gallery and display inside the report
- **API Integration**: fetch phishing keywords/tips from an API  
  - Includes **offline fallback** (`assets/keywords_fallback.json`) so the app works without internet
- **Cloud Services (Optional)**: sync reports to **Firestore** when Cloud Sync is enabled
- **User Feedback**: loading indicators, snackbars, and validation messages
- **Clean Architecture**: separation of `presentation / data / domain / core`

---

## 🧭 Screens
Typical screens included:
- Splash
- Login
- Register
- Home / Reports List
- Add Report
- Report Details
- Tips (API keywords)
- Settings (theme + cloud sync)

---

## 🧠 How Risk Scoring Works 
The app uses a simple and explainable risk engine:
1. Combine message text + URL (if provided)
2. Match suspicious keywords (each match adds points)
3. Apply URL heuristics (very long URL, many subdomains, IP-like links, shorteners)
4. Cap the final score to **0–100** and map it to a label:
   - **0–34**: Safe
   - **35–69**: Suspicious
   - **70–100**: Dangerous

---

## 🧱 Project Structure
```
lib/
  core/           # routing, theme, shared widgets/utilities
  domain/         # models + risk engine
  data/           # local db, remote api, cloud sync
  presentation/   # screens + providers (state management)
assets/
  keywords_fallback.json
`

---

## 🚀 Getting Started

### 1) Install dependencies
```bash
flutter pub get
```

### 2) Run the app
```bash
flutter run
```

---

## 🔥 Firebase Setup 
Cloud features are optional Fore storing but essintial for rigestring. The app can still run with local storage and API fallback.

1. Create a Firebase project
2. Enable **Email/Password** authentication
3. Add Firebase config files:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`
4. Run:
```bash
flutter pub get
```

---

## 📚 References
- Flutter documentation
- Firebase for Flutter documentation
- Provider package documentation
- Sqflite package documentation
- Shared Preferences package documentation
