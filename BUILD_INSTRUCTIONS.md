# 📱 GPA Calculator - Build & Run Guide

A modern Flutter GPA Calculator built specifically for **University & Honours Degree Students** (supporting Sri Lankan UGC / SLQF standard grading system, multi-semester management, auto-saved local storage, and PDF transcript export).

---

## 🚀 1. How to Run Locally

### Prerequisites
Make sure your Flutter and Android SDK tools are in your environment `PATH`. 
To set it up in PowerShell:
```powershell
$env:Path = "$env:LOCALAPPDATA\Android\Sdk\platform-tools;C:\Users\micha\flutter\bin;$env:Path"
```

### Install Dependencies
```powershell
flutter pub get
```

### Run Options

#### Option A: Run in Google Chrome (Web)
```powershell
flutter run -d chrome
```

#### Option B: Run on Android Emulator
1. Start the emulator:
   ```powershell
   flutter emulators --launch Pixel_9_Pro
   ```
2. Run the application:
   ```powershell
   flutter run -d emulator-5554
   ```

#### Option C: Run as Windows Desktop Application
```powershell
flutter run -d windows
```

---

## 📦 2. How to Build Android APKs

### 1. Build Universal Release APK (Recommended)
This produces a single `.apk` file that installs on any Android phone:
```powershell
flutter build apk --release
```
**Output Location:**
```
build\app\outputs\flutter-apk\app-release.apk
```

---

### 2. Build Split APKs (Smaller Download Size)
Generates separate APKs optimized for specific phone architectures (arm64, arm32, x86_64):
```powershell
flutter build apk --split-per-abi
```
**Output Locations:**
- Modern 64-bit phones: `build\app\outputs\flutter-apk\app-arm64-v8a-release.apk`
- Older 32-bit phones: `build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk`

---

### 3. Build Android App Bundle (`.aab` for Google Play Store)
If publishing to the Google Play Store:
```powershell
flutter build appbundle --release
```
**Output Location:**
```
build\app\outputs\bundle\release\app-release.aab
```

---

## 🎓 3. University Honours Degree Grading System

The app follows the **Sri Lankan University (UGC / SLQF) & Commonwealth Honours Degree** standard:

### Grade Points Table:
| Grade | Grade Point |
| :---: | :---: |
| **A+** | 4.00 |
| **A** | 4.00 |
| **A-** | 3.70 |
| **B+** | 3.30 |
| **B** | 3.00 |
| **B-** | 2.70 |
| **C+** | 2.30 |
| **C** | 2.00 |
| **C-** | 1.70 |
| **D+** | 1.30 |
| **D** | 1.00 |
| **E / F** | 0.00 |

### Honours Degree Classifications:
- **First Class Honours 🏆**: $\text{GPA} \ge 3.70$
- **Second Class (Upper Division) (2:1)**: $3.30 \le \text{GPA} < 3.70$
- **Second Class (Lower Division) (2:2)**: $3.00 \le \text{GPA} < 3.30$
- **General Pass**: $2.00 \le \text{GPA} < 3.00$

---

## 💾 4. Features & Usage

- **Local Offline Auto-Save**: All entered subjects, grades, credits, and semesters are automatically saved to `SharedPreferences` as you type.
- **Multi-Semester Management**: Tap any semester title to rename it (e.g. *"Year 1 Sem 1"*, *"Year 2 Sem 1"*), add subjects, or delete semesters.
- **Per-Semester GPA**: Shows individual semester GPA badge alongside the cumulative GPA.
- **PDF Export**: Generate a printable Academic Transcript report by clicking the PDF icon.
