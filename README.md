# Blur Wave Mobile

## 🎯 What is Blur Wave Mobile?

This is a mobile app that **detects hand movements through your camera** and responds with interactive visual effects.

**Simple Example:**

- 📱 Open the app
- 👋 Show your hand to the camera
- ✌️ Make a peace sign (2 fingers) → Camera becomes **blurred**
- 👍 Thumbs up gesture → Shows **"OKE"** message on screen
- ✊ Close your fist → App detects and displays label

**Technology Used:**

- Your phone's camera
- Artificial Intelligence (AI) to recognize hand gestures
- All processing happens **on your phone** (no data sent to the internet)

---

## ✨ Main Features

### 🎥 Real-Time Hand Detection

- App sees your hand movements **directly from the camera**
- Can detect **up to 2 hands at the same time**
- Shows visual hand markers (landmarks) on screen

### 👆 Gesture Recognition

- **✌️ Peace Sign (2 fingers)** → Camera smoothly becomes blurred
- **👍 Thumbs Up** → "OKE" badge appears with notification
- **✊ Closed Fist** → App detects and displays label
- All gestures shown with accuracy percentage

### 🎨 Smooth Animations

- Blur appears **gradually** (not sudden)
- Transition from normal to blur takes 400 milliseconds
- Camera display is always in **portrait mode** (like most phones)

### 📊 Performance Monitoring

- App tracks how fast detection happens
- Shows real-time performance metrics
- Clear error messages if something goes wrong

---

## 🛠️ How It Works Behind the Scenes (Architecture)

**Technical stuff? Don't worry - this is for developers:**

Built with:

- **MVVM Pattern**: Organizes code to be easy to understand
- **Dependency Injection**: Connects components neatly
- **Repository Pattern**: Separates detection logic from UI
- **Provider**: Makes UI automatically update when data changes

---

## 📁 Folder Structure (For Developers)

```
lib/
├── main.dart                           # App startup point
├── apps/
│   └── app.dart                        # Main app settings
├── core/
│   ├── di.dart                         # Component setup
│   └── router/
│       └── app_router.dart             # Page navigation
├── feature/
│   └── hand_tracker/
│       ├── data/                       # Detection & data section
│       │   ├── datasources/
│       │   │   └── hand_detection_local_data_source.dart
│       │   ├── models/
│       │   │   └── detected_hand_model.dart
│       │   └── repositories/
│       ├── presentation/               # UI section
│       │   ├── viewmodels/
│       │   │   └── hand_tracker_viewmodel.dart
│       │   ├── pages/
│       │   │   └── hand_tracker_page.dart
│       │   └── widgets/
│       │       └── hand_overlay.dart
```

---

## 📦 Dependencies (Libraries Used)

| Library              | Purpose                            |
| -------------------- | ---------------------------------- |
| `camera`             | Access your phone's camera         |
| `hand_detection`     | AI for detecting hand gestures     |
| `permission_handler` | Request camera permission          |
| `provider`           | Make UI responsive to data changes |
| `get_it`             | Manage app components              |
| `go_router`          | Navigate between screens           |

---

## 🚀 Getting Started

### ✅ Requirements

- **Flutter SDK** version 3.10.8 or newer
  - Download from https://flutter.dev/docs/get-started/install
- **Android SDK** (for Android phones)
- **Android Studio** or an Android emulator (optional)

### 📥 Installation Steps

**1️⃣ Clone (Download) the Project**

```bash
git clone <repository-url>
cd blur_wave_mobile
```

**2️⃣ Install Dependencies (Libraries)**

```bash
flutter pub get
```

**3️⃣ Run the App**

```bash
flutter run
```

### 🤖 Android Only

- Make sure `android/app/build.gradle` uses API level 24 or higher
- Camera permission is requested automatically when you first open the app

---

## 📱 Platform Support

This project currently supports **Android only**.

- **Android**: ✅ Supported
- **iOS**: ❌ Not supported

The app is developed and tested for Android devices only.

---

## 📱 How to Use the App

**Step by Step:**

1. 🟢 **Open the app** → You'll see a camera permission request
2. ✅ **Allow camera access** → Camera feed will appear
3. 👋 **Show your hand to the camera:**
   - ✌️ **Make a peace sign (2 fingers)** → Camera will gradually blur
   - 👍 **Thumbs up** → "OKE" message and notification appear
   - ✊ **Make a fist** → "FIST" label will be displayed
4. 👐 **Open your hand again** → Blur will gradually disappear and screen returns to normal

---

## 🔍 Technical Details (How It Actually Works)

### Input → Process → Output

**Input:**

- Images from your camera in YUV420 format (standard camera format)

**Process:**

- App rotates images based on phone orientation (90°, 180°, or 270°)
- AI detects 21 points on your hand (called "landmarks")
- System recognizes gesture from these points

**Output:**

- List of detected hands
- Coordinates of each hand point
- Type of gesture (peace, thumbUp, fist, etc.)
- Confidence score (0-100%)

### 💡 Blur Animation

- Starts with blur level 0 (clear)
- Over 400 milliseconds, blur increases to level 10 (most blurred)
- Dark color also gradually appears

### 🖐️ Gesture Recognition

- **Peace/Victory**: AI sees 2 raised fingers
- **Thumbs Up**: Built-in recognition from hand_detection package
- **Fist/Closed Hand**: All hand points are very close to each other

### 🔒 Threading (Technical Detail)

- Camera runs on a separate thread so it doesn't slow down the UI
- App prevents duplicate detections from happening at the same time
- Memory is cleaned up properly when you close the app

---

## 📖 Code Reference (For Developers)

### State & Data from ViewModel

```dart
// Boolean values (true/false)
isBlurred          // true if peace gesture detected
isThumbOk          // true if thumbs up detected
isFist             // true if closed fist detected
permissionGranted  // true if camera permission was given

// Numbers and text
latestLatencyMs    // Last detection time (in milliseconds)
gestureLabel       // Current gesture label ("THUMB", "BLUR", etc)
statusMessage      // Status message ("OKE" or empty)

// Complex data
hands              // List of all detected hands
primaryHand        // Hand with highest confidence
```

---

## ❓ Troubleshooting (Problem Solving)

### ❌ Error: "HandDetector not initialized"

**What it means:** Camera sent images before AI was ready

**Solution:** Wait for the app to fully load (usually just 1-2 seconds)

---

### ❌ Gesture Not Being Detected

**What it means:** App doesn't recognize your hand movement

**Reasons & Solutions:**

- ☀️ Not enough light → **Use a brighter location**
- 👋 Hand outside camera frame → **Make sure hand is fully visible**
- 🔄 Too fast movements → **Move your hand more slowly**

---

### ❌ Blur Not Smooth (Stuttering)

**What it means:** Blur appears jerky instead of smooth

**Solution:** This is normal on older phones. Nothing to worry about.

---

### ❌ "Permission Denied" (Camera Access Denied)

**What it means:** You rejected camera access

**Solution:**

1. Open **Settings** on your phone
2. Find **App Permissions** or **Permissions**
3. Find **blur_wave_mobile**
4. Turn on **Camera**

---

## ⚙️ Performance Tips

| Metric              | Info                                             |
| ------------------- | ------------------------------------------------ |
| **Detection Speed** | ~50-100ms per image (depends on hand complexity) |
| **Memory (RAM)**    | AI model uses ~100MB                             |
| **Battery**         | ~15-20% per hour of camera usage                 |

**How to make it faster:**

- In the datasource file, change `maxDim: 320` to `maxDim: 256`
- Trade-off: Less accurate, but faster

---

## 🔮 Planned Features

- [ ] Back camera support
- [ ] Custom gesture training
- [ ] Multi-hand combinations
- [ ] 3D hand pose visualization
- [ ] Video recording with effects
- [ ] Cloud-based detection option

---

## 👨‍💻 For Developers

### Code Quality Check

```bash
# Check code quality
flutter analyze

# Auto-format code
dart format .
```

### Testing (Not Yet Available)

```bash
# Run tests
flutter test
```

---

## 📄 License

**This project is private.** It cannot be shared or distributed without permission.

---

## 🔗 Learning Resources

**Want to learn more?**

- 📚 [Flutter Docs](https://flutter.dev/docs) - Flutter documentation
- 🤖 [hand_detection Package](https://pub.dev/packages/hand_detection) - Hand detection package
- 📷 [Camera Package](https://pub.dev/packages/camera) - Camera package
- 🔄 [Provider Package](https://pub.dev/packages/provider) - State management
- 🧠 [Google ML Kit](https://developers.google.com/ml-kit/vision/hand-detection) - Technology behind hand detection

---

## 💬 Frequently Asked Questions (FAQ)

**Q: Is my hand data sent to the internet?**
A: No! All detection happens on your phone. Your data never leaves your device.

**Q: Can the app work without internet?**
A: Yes, the app doesn't need internet at all.

**Q: How accurate is the gesture detection?**
A: ~85-95% depending on lighting, movement speed, and hand angle.

**Q: Can I customize the gestures?**
A: Not currently, but this feature is planned for a future update.

**Q: How is this different from a regular camera app?**
A: This app has AI that can "see" and "understand" your hands, not just record them.

**Q: Does this work in low light?**
A: Yes, but accuracy is better with good lighting. Poor lighting may cause missed detections.

**Q: Can it detect both hands accurately?**
A: Yes! It can track up to 2 hands at the same time with good accuracy.

**Q: What if my phone doesn't have a front camera?**
A: The app will automatically switch to the back camera if available.
