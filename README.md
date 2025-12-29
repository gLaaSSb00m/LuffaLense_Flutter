# LuffaLense

LuffaLense is a comprehensive Flutter application for luffa plant care, combining disease detection using Hugging Face machine learning models with an AI-powered chatbot for expert advice. Users can capture or select images of luffa plants to predict potential diseases via Hugging Face API, and consult a specialized chatbot for information on luffa cultivation, health, and related topics.

## Features

### Disease Detection
- **Image Capture and Selection**: Users can take photos directly from the camera or select images from their gallery for analysis.
- **Machine Learning Prediction**: Utilizes Hugging Face API to analyze luffa plant images and predict potential diseases such as Smooth and Sponge varieties.
- **Real-time Results**: Provides instant disease prediction results with recommendations through cloud-based ML models.
- **Dual Prediction Modes**: Supports both image-based prediction and feature-based prediction for comprehensive analysis.

### AI-Powered Chatbot
- **Specialized Knowledge**: Powered by DeepSeek AI via OpenRouter, the chatbot provides expert information specifically about luffa plants.
- **Comprehensive Coverage**: Offers advice on cultivation, disease prevention, health benefits, and general plant care.
- **Interactive Interface**: User-friendly chat interface with markdown support for rich text responses.
- **Context-Aware Responses**: Maintains conversation context and redirects queries back to luffa-related topics.

### User Experience
- **Intuitive Navigation**: Clean, modern interface with smooth animations and transitions.
- **Multi-Platform Support**: Fully functional on Android, iOS, and web platforms.
- **Cloud-Powered ML**: Leverages Hugging Face models for accurate disease detection without local model files.
- **Responsive Design**: Adapts seamlessly to different screen sizes and orientations.

## Project Structure

```
luffalense/
├── android/                 # Android-specific code and configurations
├── assets/                  # Static assets (images)
│   └── images/              # App images and icons
├── build/                   # Build outputs
├── ios/                     # iOS-specific code and configurations
├── lib/                     # Flutter source code
│   ├── main.dart            # App entry point
│   ├── home_page.dart       # Alternative home page implementation
│   ├── second_page.dart     # Main functionality page
│   ├── chat_screen.dart     # Chatbot interface
│   ├── deepseek_service.dart # DeepSeek API integration
│   └── xgboost_predictor.dart # Hugging Face API integration
├── linux/                   # Linux-specific code
├── macos/                   # macOS-specific code
├── test/                    # Unit and widget tests
├── web/                     # Web-specific code
└── windows/                 # Windows-specific code
```

## Technology Stack

### Machine Learning
- **Hugging Face API**: Cloud-based ML models for disease prediction
- **API Endpoint**: `https://Abid1012-luffa-disease-api.hf.space/predict`
- **Supported Models**: Smooth Luffa and Sponge Luffa disease detection
- **Input Methods**: Image upload and feature-based prediction

### AI Chatbot
- **DeepSeek AI**: Advanced language model for plant-specific queries
- **OpenRouter**: API gateway for AI model access
- **Model**: `deepseek/deepseek-r1-0528:free`
- **Specialization**: Luffa plant cultivation and disease management

### Flutter Framework
- **SDK**: Flutter 3.8.1+
- **Language**: Dart
- **Platforms**: Android, iOS, Web, Windows, macOS, Linux

## Prerequisites

- Flutter SDK (^3.8.1)
- Dart SDK
- Android Studio or Xcode for mobile development
- Internet connection for API calls

## Dependencies

### Core Dependencies
- `flutter`: SDK
- `http: ^1.2.0` - For API communications
- `image_picker: ^1.0.7` - For camera and gallery image selection
- `flutter_markdown: ^0.7.1` - For rich text formatting in chat

### Development Dependencies
- `flutter_test`: SDK
- `flutter_lints: ^5.0.0`
- `flutter_launcher_icons: ^0.13.1`

## How to Run

1. **Clone the repository:**
   ```
   git clone <repository-url>
   cd luffalense
   ```

2. **Install dependencies:**
   ```
   flutter pub get
   ```

3. **Run the app:**
   - For Android: `flutter run`
   - For iOS: `flutter run` (requires Xcode)
   - For web: `flutter run -d chrome`

4. **Build APK:**
   ```
   flutter build apk --debug
   ```

## API Configuration

### Hugging Face API
The app uses a Hugging Face Space for disease prediction:
- **Endpoint**: `https://Abid1012-luffa-disease-api.hf.space/predict`
- **Supported Categories**: "Smooth" and "Sponge"
- **Input**: Image files or feature vectors

### DeepSeek Chatbot
The chatbot uses DeepSeek AI via OpenRouter:
- **API**: OpenRouter AI Gateway
- **Model**: `deepseek/deepseek-r1-0528:free`
- **Specialization**: Luffa plant information and care

## Screenshots

### Home Screen
<img src="assets/images/Home.jpg" alt="Home Screen" width="300"/>

### Before Prediction
<img src="assets/images/before_Prediction.jpg" alt="Before Prediction" width="300"/>

### After Prediction
<img src="assets/images/after_Prediction.jpg" alt="After Prediction" width="300"/>

### Chatbot Interface
<img src="assets/images/chatbot.jpeg" alt="Chatbot Interface" width="300"/>

## APK Download

Download the latest APK: [download apk](https://drive.google.com/file/d/1_XJcWY64-djYHnEofC8tSX9aLCPT7b6N/view?usp=drivesdk)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

This project is licensed under the MIT License.

## Technical Notes

- The app requires an active internet connection for both disease prediction and chatbot features
- Hugging Face API provides cloud-based ML inference without requiring local model files
- DeepSeek API key is currently hardcoded for demonstration purposes - consider using environment variables in production
- Image prediction supports common formats (JPEG, PNG, etc.)
- The app is optimized for both portrait and landscape orientations
