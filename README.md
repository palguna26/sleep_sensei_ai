# Sleep Sensei AI 🌙

A professional sleep tracking and coaching application powered by AI, designed to help users improve their sleep quality and establish better sleep habits.

![Sleep Sensei AI](https://img.shields.io/badge/Flutter-3.32.6-blue?style=for-the-badge&logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange?style=for-the-badge&logo=firebase)
![AI Powered](https://img.shields.io/badge/AI-Powered-purple?style=for-the-badge)

## ✨ Features

### 🛏️ Sleep Tracking
- **Automatic Sleep Detection**: Uses device sensors to detect sleep patterns
- **Sleep Debt Calculation**: Tracks accumulated sleep debt vs. ideal sleep hours
- **Real-time Status**: Shows current sleep/wake status
- **7-Day History**: Comprehensive sleep session tracking
- **Health Data Integration**: Google Fit integration for Android

### 🤖 AI Sleep Coaching
- **Personalized Chat**: Interactive AI coach powered by GPT-4
- **Sleep Advice**: Tailored recommendations based on sleep patterns
- **Conversation History**: Persistent chat sessions
- **Smart Insights**: AI-powered sleep analysis

### ⏰ Smart Alarm System
- **Wake Window**: Configurable optimal wake-up time range
- **Smart Wake-up**: Alarms trigger during lightest sleep phase
- **Customizable Settings**: Flexible alarm configuration

### 🎵 Wind-Down & Relaxation
- **Audio Library**: Curated collection of relaxing sounds
- **Professional Player**: Full audio controls and playback
- **Sleep Preparation**: Designed for evening use

### 📊 Analytics & Insights
- **Energy Curve**: Visual daily energy pattern analysis
- **Sleep Quality**: Automatic sleep quality assessment
- **Trend Analysis**: Long-term sleep pattern tracking
- **Professional Charts**: Beautiful data visualization

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.32.6 or higher
- **Dart SDK**: 3.2.0 or higher
- **Android Studio** / **VS Code** with Flutter extensions
- **Firebase Project** (for backend services)
- **OpenAI API Key** (for AI coaching)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/sleep_sensei_ai.git
   cd sleep_sensei_ai
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Firebase**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication (Email/Password)
   - Enable Firestore Database
   - Download `google-services.json` for Android
   - Update `lib/firebase_options.dart` with your Firebase configuration

4. **Configure Environment Variables**
   ```bash
   cp env.example .env
   ```
   Edit `.env` file with your API keys:
   ```env
   FIREBASE_API_KEY=your-firebase-api-key
   FIREBASE_APP_ID=your-firebase-app-id
   FIREBASE_MESSAGING_SENDER_ID=your-sender-id
   FIREBASE_PROJECT_ID=your-project-id
   FIREBASE_AUTH_DOMAIN=your-project-id.firebaseapp.com
   FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
   OPENAI_API_KEY=your-openai-api-key
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

### Platform Setup

#### Android
- Ensure Android SDK is properly configured
- Grant necessary permissions for sensors and health data
- For Google Fit integration, configure OAuth 2.0

#### iOS
- Configure iOS bundle identifier
- Set up iOS-specific Firebase configuration
- Grant health data permissions

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
│   ├── sleep_session.dart
│   ├── user_profile.dart
│   ├── chat_message.dart
│   └── ...
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── sleep_provider.dart
│   ├── chat_provider.dart
│   └── ...
├── screens/                  # UI screens
│   ├── dashboard/
│   ├── auth/
│   ├── chat/
│   └── ...
├── services/                 # Business logic
│   ├── firebase_service.dart
│   ├── chat_service.dart
│   ├── health_service.dart
│   └── ...
├── widgets/                  # Reusable components
│   ├── sleep_chart.dart
│   ├── session_tile.dart
│   └── ...
└── theme/                    # App theming
    └── app_theme.dart
```

## 🎨 Design System

The app follows a modern, professional design inspired by the Rise sleep app:

- **Color Palette**: Deep blues, purples, and warm accents
- **Typography**: Inter font family for readability
- **Components**: Material Design 3 with custom styling
- **Dark/Light Mode**: Full theme support

## 🔧 Configuration

### Firebase Setup
1. Create Firebase project
2. Enable Authentication (Email/Password)
3. Create Firestore database
4. Set up security rules
5. Configure platform-specific settings

### OpenAI Integration
1. Get API key from [OpenAI Platform](https://platform.openai.com/)
2. Add to environment variables
3. Configure chat service

### Health Data (Android)
1. Configure Google Fit API
2. Set up OAuth 2.0 credentials
3. Grant necessary permissions

## 📱 Features in Detail

### Sleep Tracking
- **Sensor Integration**: Uses accelerometer for movement detection
- **Sleep Detection**: 20-minute inactivity threshold
- **Data Storage**: Local and cloud synchronization
- **Health Integration**: Google Fit data import

### AI Coaching
- **GPT-4 Integration**: Advanced language model for responses
- **Context Awareness**: Personalized based on sleep data
- **Conversation Memory**: Persistent chat history
- **Smart Suggestions**: Proactive sleep advice

### Smart Alarm
- **Sleep Cycle Detection**: Wakes during lightest sleep phase
- **Customizable Windows**: Flexible wake-up time ranges
- **Notification Integration**: Rich alarm notifications
- **Snooze Support**: Intelligent snooze functionality

## 🚀 Deployment

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

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by the Rise sleep app design
- Built with Flutter and Firebase
- AI powered by OpenAI GPT-4
- Health data integration with Google Fit

## 📞 Support

For support, email support@sleepsensei.ai or create an issue in this repository.

---

**Sleep Sensei AI** - Your personal sleep coach powered by AI 🌙✨
