# 🎥 Vid Editor

A simple Flutter-based video editor app where users can create, preview, and manage their video creations.  
Built with clean separation of concerns using **screens, services, widgets, and helpers** for maintainability.

---

## ✨ Features
- 📂 Save and list all created videos  
- 🖼️ Auto-generate video thumbnails  
- ▶️ Preview videos inside the app  
- 🗑️ Delete saved videos with confirmation  
- 📤 Share videos directly from the app  
- 🎨 Clean UI with modular widget separation  

---

## 📂 Project Structure
```
lib/
├── helpers/
│   └── video_name_helper.dart       # Utility for video file names
├── screens/
│   ├── creations.dart               # List of saved videos
│   ├── edit_video.dart              # Edit video screen
│   ├── home.dart                    # Home screen
│   ├── preview.dart                 # Video preview player
│   └── splash.dart                  # Splash screen
├── services/
│   ├── storage_service.dart         # Video storage handling
│   ├── thumbnail_service.dart       # Generate thumbnails
│   └── video_service.dart           # Video-related operations
├── utils/                           # (future utilities)
├── widgets/
│   ├── data_card.dart
│   ├── header_row.dart
│   ├── navbar.dart                  # Bottom navigation
│   ├── video_list_item.dart         # List item for videos
│   ├── video_preview.dart
│   └── welcome_card.dart
└── main.dart                        # App entry point
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.0.0)
- Android Studio / VS Code
- Android Emulator or Physical Device

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/<your-username>/vid_editor.git
   cd vid_editor
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

---

## 📦 Build Release APK

### Generate a release APK:
```bash
flutter build apk --release
```

Find the APK at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### (Optional) Split APK by ABI:
```bash
flutter build apk --release --split-per-abi
```

### (Optional) Build App Bundle:
```bash
flutter build appbundle --release
```

---

## 🛠️ Tech Stack
- **Flutter** (Dart)
- **video_thumbnail** – for generating thumbnails
- **share_plus** – for sharing videos
- **path** – for path utilities

---

## 📸 Screenshots (Optional)
_Add screenshots here if available._

---

## 🤝 Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

---

## 📜 License
This project is licensed under the MIT License.
