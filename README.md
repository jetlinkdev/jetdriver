# Jetdriver - Driver App for Jetlink Ride-Hailing Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Linux%20%7C%20Windows%20%7C%20macOS-lightgrey.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

**Jetdriver** adalah aplikasi Flutter untuk driver mitra Jetlink, platform ride-hailing real-time yang memungkinkan driver menerima order, menawar harga, dan mengelola perjalanan mereka.

## 📱 Fitur Utama

### Authentication & Profile
- ✅ Google Sign-In via Firebase Authentication
- ✅ Profile completion dengan email, nama, dan nomor telepon
- ✅ Driver registration dengan informasi kendaraan (tipe & plat nomor)
- ✅ Driver status verification

### Order Management
- ✅ Real-time order notifications via WebSocket
- ✅ Order list dengan detail lengkap (pickup, destination, fare, notes)
- ✅ Scheduled pickup time display ("Segera" atau waktu yang dijadwalkan)
- ✅ Order filtering (pending, accepted, driver_arrived, completed)

### Bidding System
- ✅ Submit bid dengan harga dan ETA (Estimated Time of Arrival)
- ✅ Bid status tracking (pending, accepted, rejected)
- ✅ View existing bids history
- ✅ Real-time bid notifications

### Trip Management
- ✅ "I'm Here" check-in saat tiba di lokasi pickup
- ✅ Trip completion dengan konfirmasi
- ✅ Order status updates (pending → accepted → driver_arrived → completed)

### Real-time Communication
- ✅ WebSocket connection dengan auto-reconnect (exponential backoff)
- ✅ Order state sync setelah reconnect
- ✅ Multi-tab synchronization via Redis backend
- ✅ Ping/Pong keep-alive mechanism

### UI/UX Features
- ✅ Dark theme dengan Material Design 3
- ✅ Responsive design untuk semua platform
- ✅ Bottom navigation (Home, Earnings, Profile)
- ✅ Earnings tracking dashboard
- ✅ Connection status indicator
- ✅ Real-time order status badges

## 🏗️ Arsitektur

### Tech Stack
- **Frontend:** Flutter 3.x (Dart)
- **State Management:** Provider + ChangeNotifier
- **Authentication:** Firebase Auth (Google Sign-In)
- **Real-time:** WebSocket (gorilla/websocket backend)
- **Local Storage:** Hive (settings & driver state)
- **Backend:** Go (MySQL + Redis)

### Project Structure
```
jetdriver/
├── lib/
│   ├── config/           # App configuration & Firebase options
│   ├── constants/        # Constants (API, intents, colors, UI strings)
│   ├── models/           # Data models (Order)
│   ├── screens/          # Main screens (Home, Settings, Registration)
│   ├── services/         # Business logic (Auth, Driver, WebSocket)
│   ├── utils/            # Utilities (Logger)
│   ├── widgets/          # Reusable widgets (OrderCard, BidBottomSheet)
│   ├── widget/           # Dialog widgets (ProfileCompletionDialog)
│   ├── app.dart          # Root app widget
│   └── main.dart         # Entry point
├── test/                 # Unit & widget tests
└── pubspec.yaml          # Dependencies
```

### WebSocket Intents

#### Client → Server
| Intent | Description |
|--------|-------------|
| `auth` | Authenticate user with Firebase UID |
| `complete_profile` | Submit complete profile data |
| `driver_registration` | Register as driver with vehicle info |
| `check_driver_status` | Check if user is registered driver |
| `submit_bid` | Submit bid for order |
| `driver_arrived` | Notify arrival at pickup location |
| `complete_trip` | Mark trip as completed |
| `get_my_bids` | Get driver's bid history |
| `ping` | Keep-alive ping |

#### Server → Client
| Intent | Description |
|--------|-------------|
| `auth_success` | Authentication successful |
| `auth_profile_needed` | Profile completion required |
| `driver_registered` | Driver registration successful |
| `driver_status` | Driver status response |
| `new_order_available` | New order notification |
| `order_state_sync` | Sync order state after reconnect |
| `existing_order_found` | User has active order |
| `bid_accepted` | Bid accepted by customer |
| `bid_rejected` | Bid declined by customer |
| `new_bid_received` | New bid notification (multi-driver) |
| `order_cancelled` | Order cancelled by customer |
| `trip_completed` | Trip completion confirmation |
| `driver_arrived` | Driver arrival confirmation |
| `my_bids` | Driver's bids history |
| `error` | Error response |
| `pong` | Ping response |

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.x or higher
- Dart 3.x or higher
- Firebase project with Google Sign-In enabled
- Backend server running (Go + MySQL + Redis)

### Installation

1. **Clone repository**
   ```bash
   git clone https://github.com/jetlinkdev/jetdriver.git
   cd jetdriver
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create Firebase project
   - Enable Google Sign-In authentication
   - Download `GoogleService-Info.plist` (iOS) and `google-services.json` (Android)
   - Place files in respective platform directories

4. **Configure backend URL**
   - Update `lib/config/app_config.dart` with your backend WebSocket URL
   - Default: `ws://localhost:8080/ws`

5. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.x.x
  firebase_auth: ^4.x.x
  google_sign_in: ^6.x.x
  provider: ^6.x.x
  hive_flutter: ^1.x.x
  web_socket_channel: ^2.x.x
  intl: ^0.18.x
  flutter_svg: ^2.x.x
```

## 🔧 Configuration

### Environment Variables
Create `.env` file or update `lib/config/app_config.dart`:

```dart
class AppConfig {
  static const String defaultWebSocketUrl = 'ws://your-backend-url:8080/ws';
  static const String defaultDriverId = 'driver_anonymous';
  static const Duration pingInterval = Duration(seconds: 30);
  static const int maxReconnectionAttempts = 10;
  static const Duration reconnectionDelay = Duration(seconds: 5);
}
```

### Backend Connection
The app connects to a Go backend with:
- **MySQL** for persistent storage (users, orders, bids, reviews)
- **Redis** for real-time caching and session management
- **WebSocket** for bidirectional communication

## 📱 Screens

### Home Screen
- Main dashboard with order list
- Online/Offline toggle switch
- Real-time connection status
- Bottom navigation (Home, Earnings, Profile)

### Settings Screen
- Driver ID configuration
- WebSocket URL settings
- Driver status (Available/Busy/Offline)
- Logout

### Driver Registration Screen
- Vehicle type input
- Vehicle plate number input
- Phone number input
- Registration submission

## 🧪 Testing

Run tests:
```bash
flutter test
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Contributors

- Jetlink Development Team

## 🔗 Related Projects

- [Backend](https://github.com/jetlinkdev/jetlink-backend) - Go backend with WebSocket server
- [Customer App](https://github.com/jetlinkdev/jetlink-react) - React customer application

## 📞 Support

For issues and feature requests, please create an issue in the GitHub repository.

---

**Built with ❤️ using Flutter**
