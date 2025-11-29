# Firebase Web Yapılandırması

Web platformu için Firebase yapılandırması gerekiyor. Şu adımları izleyin:

## 🔥 Adım 1: Firebase Console'da Web Uygulaması Ekleme

1. Firebase Console'a gidin: https://console.firebase.google.com/
2. Projenizi seçin
3. Ana sayfada **Web ikonuna** (</>) tıklayın
4. **App nickname** girin: `Kolektif Akıl Web`
5. **"Register app"** (Uygulamayı Kaydet) butonuna tıklayın
6. Yapılandırma bilgileri gösterilecek

## 🔥 Adım 2: Firebase Yapılandırma Bilgilerini Alma

Firebase Console'da şu bilgileri göreceksiniz:

```javascript
const firebaseConfig = {
  apiKey: "AIza...",
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abcdef"
};
```

## 🔥 Adım 3: main.dart Dosyasını Güncelleme

`lib/main.dart` dosyasındaki Firebase yapılandırmasını güncelleyin:

1. `lib/main.dart` dosyasını açın
2. `YOUR_WEB_API_KEY`, `YOUR_WEB_APP_ID` vb. değerleri Firebase Console'dan aldığınız değerlerle değiştirin

Örnek:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: 'AIzaSy...', // Firebase Console'dan
    appId: '1:123456789:web:abcdef', // Firebase Console'dan
    messagingSenderId: '123456789', // Firebase Console'dan
    projectId: 'your-project-id', // Firebase Console'dan
    authDomain: 'your-project-id.firebaseapp.com', // Firebase Console'dan
    storageBucket: 'your-project-id.appspot.com', // Firebase Console'dan
  ),
);
```

## ✅ Alternatif: Sadece Mobil Platformlarda Çalıştırma

Eğer şimdilik sadece Android/iOS'ta test etmek istiyorsanız, Web platformunu devre dışı bırakabilirsiniz:

```bash
flutter run -d chrome --no-web
```

veya sadece Android/iOS cihazında çalıştırın:

```bash
flutter run
```

## 📝 Notlar

- Web yapılandırması sadece Web platformu için gereklidir
- Mobil platformlar (Android/iOS) için `google-services.json` ve `GoogleService-Info.plist` dosyaları yeterlidir
- Production'da API anahtarlarını environment variables'a taşımanız önerilir

