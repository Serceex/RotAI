# ✅ Kurulum Özeti

## Tamamlanan Adımlar

### ✅ API Yapılandırması
- [x] Gemini API anahtarı eklendi (`lib/config/api_config.dart`)
- [x] Google Maps API anahtarı eklendi
- [x] AndroidManifest.xml güncellendi (Google Maps API key)

### ✅ Firebase Yapılandırması
- [x] Firebase projesi oluşturuldu
- [x] Android uygulaması Firebase'e eklendi
- [x] `google-services.json` dosyası eklendi (`android/app/`)
- [x] Firebase Authentication etkinleştirildi (Email/Password)
- [x] Firestore Database oluşturuldu
- [x] Realtime Database oluşturuldu (Bitki için)

### ✅ Proje Yapılandırması
- [x] Flutter bağımlılıkları yüklendi
- [x] Proje temizlendi ve yeniden yapılandırıldı

---

## 🚀 Projeyi Çalıştırma

### 1. Projeyi Test Etme

Terminal'de şu komutları çalıştırın:

```bash
cd C:\Users\Serce\kolektif_akil_platform
flutter run
```

### 2. İlk Test Senaryosu

1. **Uygulama açıldığında:**
   - Splash screen görünecek
   - Giriş ekranına yönlendirileceksiniz

2. **Kayıt Ol:**
   - "Hesabınız yok mu? Kayıt olun" linkine tıklayın
   - Ad Soyad, E-posta ve Şifre girin
   - "Kayıt Ol" butonuna tıklayın

3. **Giriş Yap:**
   - E-posta ve şifrenizi girin
   - "Giriş Yap" butonuna tıklayın

4. **Ana Sayfa:**
   - Ana sayfada "Yeni Karar Analizi" butonuna tıklayın
   - Bir karar sorusu girin (örn: "Yeni bir iş teklifini kabul edip büyük şehre mi taşınmalıyım?")
   - "Analiz Et" butonuna tıklayın
   - AI analiz sonucunu bekleyin

5. **Topluluk Oylaması:**
   - Analiz sonrası "Topluluk Oylamasına Katıl" butonuna tıklayın
   - Seçeneklerden birini seçin (A veya B)
   - "Oy Ver" butonuna tıklayın
   - İstatistikleri görüntüleyin

6. **Ortak Bitki:**
   - Alt menüden "Bitki" sekmesine gidin
   - "Sula" butonuna tıklayın
   - Bitki durumunu görüntüleyin

---

## 🔧 Sorun Giderme

### Firebase Bağlantı Hatası

Eğer Firebase bağlantı hatası alırsanız:

1. `google-services.json` dosyasının doğru konumda olduğunu kontrol edin:
   ```
   android/app/google-services.json
   ```

2. Firebase Console'da servislerin etkin olduğunu kontrol edin:
   - Authentication
   - Firestore Database
   - Realtime Database

3. Projeyi temizleyip yeniden çalıştırın:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### Gemini API Hatası

Eğer Gemini API hatası alırsanız:

1. `lib/config/api_config.dart` dosyasındaki API anahtarını kontrol edin
2. API anahtarının geçerli olduğundan emin olun
3. API limitlerini kontrol edin

### Google Maps Hatası

Eğer Google Maps hatası alırsanız:

1. `lib/config/api_config.dart` dosyasındaki Google Maps API anahtarını kontrol edin
2. `android/app/src/main/AndroidManifest.xml` dosyasındaki API key'i kontrol edin
3. Google Cloud Console'da Maps SDK'nın etkin olduğundan emin olun

---

## 📱 Özellikler

### ✅ Çalışan Özellikler

1. **Kullanıcı Kimlik Doğrulama**
   - Kayıt ol
   - Giriş yap
   - Çıkış yap

2. **Karar Analizi**
   - AI ile karar analizi (Gemini)
   - Karar ağacı görselleştirme
   - Risk ve fayda analizi

3. **Topluluk Oylaması**
   - Karar seçeneklerini oylama
   - İstatistikler (şehir, yaş, cinsiyet bazlı)
   - Gerçek zamanlı oy takibi

4. **Ortak Bitki**
   - Bitki durumu görüntüleme
   - Bitki sulama
   - Sağlık seviyesi takibi

5. **Canlı Mekan Durumu**
   - Harita görüntüleme
   - Konum seçme
   - (FCM bildirimleri yakında eklenecek)

---

## 🎯 Sonraki Adımlar (Opsiyonel)

1. **Firebase Cloud Messaging (FCM)**
   - Push bildirimleri için yapılandırma
   - Canlı mekan durumu bildirimleri

2. **Firebase Storage**
   - Fotoğraf yükleme için yapılandırma
   - Mekan geri bildirimi fotoğrafları

3. **Güvenlik Kuralları**
   - Firestore güvenlik kuralları
   - Realtime Database güvenlik kuralları

4. **Production Hazırlığı**
   - API anahtarlarını environment variables'a taşıma
   - Güvenlik kurallarını production moduna geçirme
   - Error tracking (Sentry, Firebase Crashlytics)

---

## 📞 Destek

Sorun yaşıyorsanız:
1. `flutter doctor` komutu ile Flutter kurulumunuzu kontrol edin
2. Firebase Console'da servislerin etkin olduğunu kontrol edin
3. API anahtarlarının doğru olduğunu kontrol edin

