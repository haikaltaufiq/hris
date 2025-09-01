# 👥 HR - Human Resource Information System

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-green.svg)](https://github.com/username/hr/releases)
[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)](https://github.com/username/hr/actions)
[![Flutter Version](https://img.shields.io/badge/flutter-3.0.0+-blue.svg)](https://flutter.dev/)

> Aplikasi HRIS (Human Resource Information System) mobile yang powerful untuk manajemen karyawan. Solusi lengkap untuk HR dalam mengelola data karyawan, absensi, payroll, dan administrasi kepegawaian lainnya.

<div align="center">
  <img src="assets/demo.gif" alt="Demo GIF" width="300"/>
  <br>
  <em>Demo aplikasi dalam aksi</em>
</div>

## ✨ Features

- 👤 **Employee Management** - Kelola data lengkap karyawan
- ⏰ **Attendance System** - Sistem absensi dengan GPS tracking
- 💰 **Payroll Management** - Perhitungan gaji dan tunjangan otomatis
- 📊 **Performance Tracking** - Monitor kinerja karyawan
- 🗓️ **Leave Management** - Pengajuan dan approval cuti
- 📱 **Mobile First** - Akses mudah melalui smartphone
- 🔐 **Role-based Access** - Kontrol akses berdasarkan jabatan
- 📈 **Analytics & Reports** - Dashboard dan laporan komprehensif
- 🔔 **Notifications** - Notifikasi real-time untuk updates penting

## 🛠️ Tech Stack

**Frontend:**
- [Flutter](https://flutter.dev/) - Cross-platform mobile framework
- [Dart](https://dart.dev/) - Programming language
- [Provider](https://pub.dev/packages/provider) - State management
- [HTTP](https://pub.dev/packages/http) - REST API integration
- [Shared Preferences](https://pub.dev/packages/shared_preferences) - Local storage
- [Image Picker](https://pub.dev/packages/image_picker) - Photo upload
- [Geolocator](https://pub.dev/packages/geolocator) - GPS tracking

**Backend:**
- [Node.js](https://nodejs.org/) - Server runtime
- [Express.js](https://expressjs.com/) - Web framework
- [JWT](https://jwt.io/) - Authentication
- [Multer](https://github.com/expressjs/multer) - File upload

**Database:**
- [MySQL](https://www.mysql.com/) - Primary database
- [Firebase](https://firebase.google.com/) - Real-time notifications
- [SQLite](https://sqlite.org/) - Offline storage

## 🚀 Quick Start

### Prerequisites

Pastikan Anda sudah menginstall:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>=3.0.0)
- [Android Studio](https://developer.android.com/studio) atau [VS Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/)

### Installation

1. **Clone repository**
   ```bash
   git clone https://github.com/username/project-name.git
   cd project-name
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup environment**
   ```bash
   cp .env.example .env
   # Edit .env file dengan konfigurasi Anda
   ```

4. **Run aplikasi**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── 📁 core/
│   ├── 📁 constants/
│   ├── 📁 utils/
│   └── 📁 themes/
├── 📁 data/
│   ├── 📁 models/
│   ├── 📁 repositories/
│   └── 📁 services/
├── 📁 presentation/
│   ├── 📁 screens/
│   ├── 📁 widgets/
│   └── 📁 providers/
└── main.dart
```

## 🎯 Usage

### Basic Example

```dart
import 'package:your_package/your_package.dart';

void main() {
  // Inisialisasi aplikasi
  final app = MyApp();
  
  // Konfigurasi
  app.configure(
    apiKey: 'your-api-key',
    baseUrl: 'https://api.example.com',
  );
  
  // Jalankan aplikasi
  runApp(app);
}
```

### Advanced Usage

```dart
// Contoh penggunaan fitur advanced
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Awesome App')),
      body: Center(
        child: Text('Hello World!'),
      ),
    );
  }
}
```

## 🔧 Configuration

### Environment Variables

Buat file `.env` di root directory:

```env
API_BASE_URL=https://api.example.com
API_KEY=your-api-key-here
DEBUG_MODE=true
```

### Firebase Setup

1. Buat project baru di [Firebase Console](https://console.firebase.google.com/)
2. Download `google-services.json` untuk Android
3. Download `GoogleService-Info.plist` untuk iOS
4. Place files sesuai dengan dokumentasi Firebase

## 📊 Performance

| Feature | Benchmark |
|---------|-----------|
| App Launch | < 2 seconds |
| Navigation | < 500ms |
| API Response | < 1 second |
| Memory Usage | < 100MB |

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Generate coverage report
flutter test --coverage
```

## 📦 Build & Deploy

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Haikal** - *Initial work* - [YourGithub](https://github.com/HaikalTaufiq)
- **Grey** - *Initial work* - [YourGithub](https://github.com/Greyari)

## 🙏 Acknowledgments

- Hat tip to anyone whose code was used
- Inspiration dari project-project open source lainnya
- Thanks to the Flutter community


---
