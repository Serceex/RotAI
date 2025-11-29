# Kolektif Akıl ve Karar Destek Platformu

Bu platform, kullanıcıların hem kişisel kararlarını AI ile analiz edebildiği hem de topluluğun kolektif bilgisini ve anlık durumunu kullanarak daha iyi tercihler yapabildiği bir araçtır.

## Özellikler

### 1. Karar Ağacı Yardımcısı (AI Gücü)
- Kullanıcının kişisel kararlarını Google Gemini AI ile analiz eder
- Detaylı karar ağacı diyagramı oluşturur
- Risk ve fayda analizleri sunar

### 2. Tarafını Seç (Kolektif Bilgi)
- Karar alternatiflerini topluluk önünde oylamaya sunar
- Şehir, yaş ve cinsiyet bazlı istatistikler gösterir
- Gerçek zamanlı oy takibi

### 3. Canlı Mekan Durumu (Anlık Veri)
- Karar sonucu gidilecek/yapılacak yerler hakkında anlık bilgi sağlar
- Harita üzerinde konum seçimi
- O konumdaki kullanıcılardan geri bildirim alma

### 4. Ortak Sanal Bitki (Oyunlaştırma/Sorumluluk)
- Platformun kullanımını ve topluluk etkileşimini teşvik eden sosyal bir görev
- Karar analizi, oylama veya geri bildirim sonrası "Sula" hakkı kazanma
- Ortak sorumluluk ile bitkiyi büyütme

## Teknoloji Stack

- **Flutter**: Cross-platform mobil uygulama framework'ü
- **Firebase**: 
  - Firestore: Veritabanı
  - Realtime Database: Bitki durumu için
  - Cloud Functions: Gemini API çağrıları için
  - FCM: Push bildirimleri için
  - Authentication: Kullanıcı kimlik doğrulama
- **Google AI (Gemini)**: Karar analizi için AI servisi
- **Google Maps**: Harita ve konum servisleri

## Kurulum

### 1. Gereksinimler
- Flutter SDK (3.9.2 veya üzeri)
- Dart SDK
- Firebase projesi
- Google AI (Gemini) API anahtarı
- Google Maps API anahtarı

### 2. Firebase Kurulumu

1. [Firebase Console](https://console.firebase.google.com/)'da yeni bir proje oluşturun
2. Android ve iOS uygulamalarınızı ekleyin
3. `google-services.json` (Android) ve `GoogleService-Info.plist` (iOS) dosyalarını indirin
4. Android için: `android/app/google-services.json` konumuna kopyalayın
5. iOS için: `ios/Runner/GoogleService-Info.plist` konumuna kopyalayın

### 3. Firebase Realtime Database Kurulumu

1. Firebase Console'da Realtime Database oluşturun
2. Test modunda başlatın (production için güvenlik kuralları ekleyin)

### 4. API Anahtarlarını Yapılandırma

1. `lib/main.dart` dosyasında `YOUR_GEMINI_API_KEY` yerine Gemini API anahtarınızı ekleyin
2. Google Maps API anahtarını yapılandırın:
   - Android: `android/app/src/main/AndroidManifest.xml`
   - iOS: `ios/Runner/AppDelegate.swift`

### 5. Bağımlılıkları Yükleme

```bash
cd kolektif_akil_platform
flutter pub get
```

### 6. Uygulamayı Çalıştırma

```bash
flutter run
```

## Proje Yapısı

```
lib/
├── models/              # Veri modelleri
│   ├── decision.dart
│   ├── vote.dart
│   ├── location_status.dart
│   ├── virtual_plant.dart
│   └── user_model.dart
├── services/            # Servisler
│   ├── firebase_service.dart
│   ├── gemini_service.dart
│   ├── auth_service.dart
│   └── location_service.dart
├── providers/           # State management
│   ├── auth_provider.dart
│   ├── decision_provider.dart
│   └── plant_provider.dart
├── screens/             # Ekranlar
│   ├── auth/
│   ├── home/
│   ├── decision/
│   ├── plant/
│   └── location/
├── widgets/             # Yeniden kullanılabilir widget'lar
├── utils/               # Yardımcı fonksiyonlar
└── main.dart            # Ana uygulama dosyası
```

## Firebase Güvenlik Kuralları

### Firestore Kuralları

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /decisions/{decisionId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    match /votes/{voteId} {
      allow read: if true;
      allow create: if request.auth != null;
    }
    
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Realtime Database Kuralları

```json
{
  "rules": {
    "plants": {
      ".read": true,
      ".write": "auth != null"
    }
  }
}
```

## Firebase Cloud Functions (Opsiyonel)

Gemini API çağrılarını Cloud Functions üzerinden yapmak için:

```javascript
const functions = require('firebase-functions');
const { GoogleGenerativeAI } = require('@google/generative-ai');

exports.analyzeDecision = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
  const model = genAI.getGenerativeModel({ model: 'gemini-pro' });
  
  const result = await model.generateContent(data.question);
  return { analysis: result.response.text() };
});
```

## Notlar

- Gemini API anahtarınızı güvenli tutun ve versiyon kontrolüne eklemeyin
- Production ortamında Firebase güvenlik kurallarını dikkatli yapılandırın
- Google Maps API kullanım limitlerine dikkat edin
- FCM bildirimleri için gerekli izinleri ekleyin

## Lisans

Bu proje özel bir projedir.

## Katkıda Bulunma

Proje geliştirme aşamasındadır. Önerileriniz için issue açabilirsiniz.
