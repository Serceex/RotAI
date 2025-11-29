# Firebase Sonraki Adımlar

`google-services.json` dosyası başarıyla eklendi! Şimdi Firebase servislerini etkinleştirelim.

## ✅ Tamamlanan Adımlar
- [x] Firebase projesi oluşturuldu
- [x] Android uygulaması Firebase'e eklendi
- [x] `google-services.json` dosyası eklendi

## 🔥 Şimdi Yapılacaklar

### Adım 1: Firebase Authentication'ı Etkinleştirme

1. Firebase Console'da projenize gidin: https://console.firebase.google.com/
2. Sol menüden **"Authentication"** (Kimlik Doğrulama) seçin
3. **"Get started"** (Başlayın) butonuna tıklayın (ilk kez açıyorsanız)
4. **"Sign-in method"** (Giriş yöntemi) sekmesine gidin
5. **"Email/Password"** seçeneğini tıklayın
6. **"Enable"** (Etkinleştir) toggle'ını açın
7. **"Save"** (Kaydet) butonuna tıklayın

✅ **Kontrol**: Email/Password authentication etkin mi?

---

### Adım 2: Firestore Database Oluşturma

1. Firebase Console'da sol menüden **"Firestore Database"** seçin
2. **"Create database"** (Veritabanı Oluştur) butonuna tıklayın
3. **"Start in test mode"** (Test modunda başlat) seçeneğini seçin
   - ⚠️ **Not**: Production'a geçmeden önce güvenlik kurallarını güncellemeniz gerekecek
4. **"Next"** (İleri) butonuna tıklayın
5. **Location** (Konum) seçin:
   - Önerilen: `europe-west1` (Belçika) veya `us-central1` (Iowa)
   - Size en yakın konumu seçin
6. **"Enable"** (Etkinleştir) butonuna tıklayın
7. Veritabanı oluşturulurken birkaç saniye bekleyin

✅ **Kontrol**: Firestore Database oluşturuldu mu?

---

### Adım 3: Realtime Database Oluşturma (Bitki için)

1. Firebase Console'da sol menüden **"Realtime Database"** seçin
2. **"Create database"** (Veritabanı Oluştur) butonuna tıklayın
3. **"Start in test mode"** (Test modunda başlat) seçeneğini seçin
4. **Location** (Konum) seçin (Firestore ile aynı veya farklı olabilir)
5. **"Done"** (Tamam) butonuna tıklayın

✅ **Kontrol**: Realtime Database oluşturuldu mu?

---

## 📝 Gradle Yapılandırması

Flutter'ın yeni sürümlerinde Gradle dosyaları otomatik olarak yönetilir. Ancak Firebase entegrasyonu için gerekli plugin'lerin eklenmesi gerekebilir.

### Kontrol Listesi

1. `google-services.json` dosyası `android/app/` klasöründe mi? ✅ (Tamamlandı)
2. Firebase Authentication etkin mi? ⏳ (Yapılacak)
3. Firestore Database oluşturuldu mu? ⏳ (Yapılacak)
4. Realtime Database oluşturuldu mu? ⏳ (Yapılacak)

---

## 🚀 Test Etme

Tüm adımları tamamladıktan sonra:

```bash
cd C:\Users\Serce\kolektif_akil_platform
flutter pub get
flutter run
```

Uygulama çalıştığında:
1. Kayıt ol ekranından yeni bir hesap oluşturun
2. Giriş yapın
3. Bir karar analizi yapmayı deneyin

---

## ❓ Sorun Giderme

### Firebase bağlantı hatası alıyorsanız:
- `google-services.json` dosyasının doğru konumda olduğundan emin olun
- Firebase Console'da tüm servislerin etkin olduğunu kontrol edin
- `flutter clean` ve `flutter pub get` komutlarını çalıştırın

### Authentication hatası alıyorsanız:
- Firebase Console'da Authentication'ın etkin olduğunu kontrol edin
- Email/Password yönteminin açık olduğunu kontrol edin

