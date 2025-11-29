# Adım Adım Kurulum Rehberi

Bu rehber, projeyi adım adım kurmanız için hazırlanmıştır.

## 📋 Adım 1: Gemini API Anahtarı Alma

1. Tarayıcınızda şu adrese gidin: https://makersuite.google.com/app/apikey
2. Google hesabınızla giriş yapın
3. "Create API Key" butonuna tıklayın
4. Oluşturulan API anahtarını kopyalayın
5. `lib/config/api_config.dart` dosyasını açın
6. `YOUR_GEMINI_API_KEY` yerine kopyaladığınız anahtarı yapıştırın

```dart
static const String geminiApiKey = 'BURAYA_API_ANAHTARINIZI_YAPIŞTIRIN';
```

✅ **Kontrol**: API anahtarınızı ekledikten sonra bu adımı tamamladınız.

---

## 📋 Adım 2: Firebase Projesi Oluşturma

1. Tarayıcınızda şu adrese gidin: https://console.firebase.google.com/
2. "Add project" (Proje Ekle) butonuna tıklayın
3. Proje adını girin (örn: "kolektif-akil-platform")
4. Google Analytics'i isteğe bağlı olarak etkinleştirebilirsiniz
5. "Create project" (Proje Oluştur) butonuna tıklayın
6. Proje oluşturulduktan sonra "Continue" (Devam Et) butonuna tıklayın

✅ **Kontrol**: Firebase projeniz oluşturuldu.

---

## 📋 Adım 3: Android Uygulamasını Firebase'e Ekleme

1. Firebase Console'da projenize gidin
2. Sol menüden "Project settings" (⚙️) ikonuna tıklayın
3. Aşağı kaydırın ve "Your apps" bölümüne gelin
4. Android ikonuna (🤖) tıklayın
5. **Android package name** olarak şunu girin: `com.kolektifakil.kolektif_akil_platform`
   - Bu değeri kontrol etmek için: `android/app/build.gradle` dosyasındaki `applicationId` değerine bakın
6. App nickname (isteğe bağlı): "Kolektif Akıl Android"
7. "Register app" (Uygulamayı Kaydet) butonuna tıklayın
8. `google-services.json` dosyasını indirin
9. İndirilen dosyayı `android/app/` klasörüne kopyalayın

✅ **Kontrol**: `android/app/google-services.json` dosyası mevcut.

---

## 📋 Adım 4: iOS Uygulamasını Firebase'e Ekleme (Mac gereklidir)

**Not**: iOS geliştirme için Mac ve Xcode gereklidir. Şimdilik atlayabilirsiniz.

1. Firebase Console'da projenize gidin
2. Sol menüden "Project settings" (⚙️) ikonuna tıklayın
3. "Your apps" bölümünde iOS ikonuna (🍎) tıklayın
4. **iOS bundle ID** olarak şunu girin: `com.kolektifakil.kolektifAkilPlatform`
5. "Register app" butonuna tıklayın
6. `GoogleService-Info.plist` dosyasını indirin
7. İndirilen dosyayı Xcode'da `ios/Runner/` klasörüne ekleyin

✅ **Kontrol**: `ios/Runner/GoogleService-Info.plist` dosyası mevcut.

---

## 📋 Adım 5: Firebase Authentication'ı Etkinleştirme

1. Firebase Console'da sol menüden "Authentication" (Kimlik Doğrulama) seçin
2. "Get started" (Başlayın) butonuna tıklayın
3. "Sign-in method" (Giriş yöntemi) sekmesine gidin
4. "Email/Password" seçeneğini etkinleştirin
5. "Enable" (Etkinleştir) butonuna tıklayın
6. "Save" (Kaydet) butonuna tıklayın

✅ **Kontrol**: Email/Password authentication etkin.

---

## 📋 Adım 6: Firestore Database Oluşturma

1. Firebase Console'da sol menüden "Firestore Database" seçin
2. "Create database" (Veritabanı Oluştur) butonuna tıklayın
3. "Start in test mode" (Test modunda başlat) seçeneğini seçin
4. "Next" (İleri) butonuna tıklayın
5. Location (Konum) seçin (örn: europe-west1 veya us-central1)
6. "Enable" (Etkinleştir) butonuna tıklayın

✅ **Kontrol**: Firestore Database oluşturuldu.

---

## 📋 Adım 7: Realtime Database Oluşturma (Bitki için)

1. Firebase Console'da sol menüden "Realtime Database" seçin
2. "Create database" (Veritabanı Oluştur) butonuna tıklayın
3. "Start in test mode" (Test modunda başlat) seçeneğini seçin
4. Location (Konum) seçin
5. "Done" (Tamam) butonuna tıklayın

✅ **Kontrol**: Realtime Database oluşturuldu.

---

## 📋 Adım 8: Google Maps API Key Alma

1. Tarayıcınızda şu adrese gidin: https://console.cloud.google.com/
2. Firebase projenizi seçin (veya yeni bir proje oluşturun)
3. Sol menüden "APIs & Services" > "Library" seçin
4. "Maps SDK for Android" araması yapın ve seçin
5. "Enable" (Etkinleştir) butonuna tıklayın
6. "Maps SDK for iOS" için de aynı işlemi yapın (iOS geliştirme yapacaksanız)
7. Sol menüden "APIs & Services" > "Credentials" seçin
8. "Create Credentials" > "API Key" seçin
9. Oluşturulan API anahtarını kopyalayın
10. `lib/config/api_config.dart` dosyasını açın
11. `YOUR_GOOGLE_MAPS_API_KEY` yerine kopyaladığınız anahtarı yapıştırın

✅ **Kontrol**: Google Maps API anahtarınızı eklediniz.

---

## 📋 Adım 9: Android için Google Maps Yapılandırması

1. `android/app/src/main/AndroidManifest.xml` dosyasını açın
2. `<application>` tag'i içine şunu ekleyin:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="BURAYA_GOOGLE_MAPS_API_KEY"/>
```

3. `BURAYA_GOOGLE_MAPS_API_KEY` yerine `ApiConfig.googleMapsApiKey` değerini kullanabilirsiniz veya doğrudan anahtarı yazabilirsiniz

✅ **Kontrol**: AndroidManifest.xml dosyası güncellendi.

---

## 📋 Adım 10: Android build.gradle Yapılandırması

1. `android/build.gradle` dosyasını açın
2. `dependencies` bölümüne şunu ekleyin (yoksa):

```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

3. `android/app/build.gradle` dosyasının en altına şunu ekleyin:

```gradle
apply plugin: 'com.google.gms.google-services'
```

✅ **Kontrol**: build.gradle dosyaları güncellendi.

---

## 📋 Adım 11: Projeyi Test Etme

1. Terminal'de proje dizinine gidin:
```bash
cd C:\Users\Serce\kolektif_akil_platform
```

2. Bağımlılıkları kontrol edin:
```bash
flutter pub get
```

3. Uygulamayı çalıştırın:
```bash
flutter run
```

✅ **Kontrol**: Uygulama başarıyla çalışıyor.

---

## 🎉 Tamamlandı!

Tüm adımları tamamladıysanız, uygulamanız çalışmaya hazır!

### Sonraki Adımlar (Opsiyonel)

- Firebase Cloud Messaging (FCM) yapılandırması (bildirimler için)
- Firebase Storage yapılandırması (fotoğraf yükleme için)
- Production için güvenlik kuralları ekleme

### Sorun mu yaşıyorsunuz?

- Firebase Console'da tüm servislerin etkin olduğundan emin olun
- API anahtarlarının doğru yapılandırıldığını kontrol edin
- `flutter doctor` komutu ile Flutter kurulumunuzu kontrol edin

