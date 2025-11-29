# Kurulum Rehberi

## Hızlı Başlangıç

### 1. Firebase Projesi Oluşturma

1. [Firebase Console](https://console.firebase.google.com/)'a gidin
2. "Add project" ile yeni proje oluşturun
3. Projeye Android ve iOS uygulamalarını ekleyin
4. `google-services.json` (Android) ve `GoogleService-Info.plist` (iOS) dosyalarını indirin

### 2. Firebase Dosyalarını Ekleme

**Android:**
- `android/app/google-services.json` konumuna kopyalayın

**iOS:**
- `ios/Runner/GoogleService-Info.plist` konumuna kopyalayın

### 3. Firebase Realtime Database

1. Firebase Console'da "Realtime Database" oluşturun
2. Test modunda başlatın (güvenlik kuralları sonra eklenebilir)

### 4. API Anahtarlarını Yapılandırma

#### Gemini API Key

1. [Google AI Studio](https://makersuite.google.com/app/apikey) adresinden API anahtarı alın
2. `lib/main.dart` dosyasında `YOUR_GEMINI_API_KEY` yerine anahtarınızı yazın:

```dart
DecisionProvider(
  geminiApiKey: 'BURAYA_API_ANAHTARINIZI_YAZIN',
)
```

#### Google Maps API Key

**Android:**
1. `android/app/src/main/AndroidManifest.xml` dosyasına ekleyin:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

**iOS:**
1. `ios/Runner/AppDelegate.swift` dosyasına ekleyin:

```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

### 5. Bağımlılıkları Yükleme

```bash
cd kolektif_akil_platform
flutter pub get
```

### 6. Uygulamayı Çalıştırma

```bash
flutter run
```

## Önemli Notlar

1. **Firebase Güvenlik Kuralları**: Production'a geçmeden önce güvenlik kurallarını yapılandırın
2. **API Limitleri**: Gemini ve Google Maps API'lerinin kullanım limitlerine dikkat edin
3. **FCM Bildirimleri**: Canlı mekan durumu özelliği için FCM yapılandırması gerekli

## Sorun Giderme

### Firebase bağlantı hatası
- `google-services.json` ve `GoogleService-Info.plist` dosyalarının doğru konumda olduğundan emin olun
- Firebase projesinde Authentication'ı etkinleştirin

### Gemini API hatası
- API anahtarının doğru olduğundan emin olun
- API limitlerini kontrol edin

### Google Maps hatası
- API anahtarının doğru yapılandırıldığından emin olun
- Maps SDK'nın projede etkin olduğundan emin olun

