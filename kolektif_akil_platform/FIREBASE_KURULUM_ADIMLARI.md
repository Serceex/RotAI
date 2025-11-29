# Firebase Kurulum Adımları - Adım Adım Rehber

Bu dosya, Firebase projesini oluştururken takip edeceğiniz adımları içerir.

## 🔥 Adım 1: Firebase Console'a Giriş

1. Tarayıcınızda şu adrese gidin: **https://console.firebase.google.com/**
2. Google hesabınızla giriş yapın
3. Eğer daha önce Firebase kullanmadıysanız, "Get Started" butonuna tıklayın

---

## 🔥 Adım 2: Yeni Proje Oluşturma

1. Firebase Console'da **"Add project"** (Proje Ekle) butonuna tıklayın
2. **Proje adı** girin: `kolektif-akil-platform` (veya istediğiniz bir isim)
3. **"Continue"** (Devam Et) butonuna tıklayın
4. Google Analytics için:
   - İsterseniz Analytics'i etkinleştirebilirsiniz (önerilir)
   - Veya "Not now" (Şimdi değil) seçeneğini seçebilirsiniz
5. **"Create project"** (Proje Oluştur) butonuna tıklayın
6. Proje oluşturulurken birkaç saniye bekleyin
7. **"Continue"** (Devam Et) butonuna tıklayın

✅ **Kontrol**: Firebase projeniz oluşturuldu!

---

## 🔥 Adım 3: Android Uygulamasını Firebase'e Ekleme

1. Firebase Console'da projenize gidin
2. Ana sayfada **Android ikonuna** (🤖) tıklayın
3. **Android package name** alanına şunu girin:
   ```
   com.kolektifakil.kolektif_akil_platform
   ```
   (Bu değer projenizdeki `android/app/build.gradle` dosyasındaki `applicationId` ile aynı olmalı)
4. **App nickname** (isteğe bağlı): `Kolektif Akıl Android`
5. **Debug signing certificate SHA-1** (şimdilik boş bırakabilirsiniz)
6. **"Register app"** (Uygulamayı Kaydet) butonuna tıklayın
7. **`google-services.json` dosyasını indirin**
8. İndirilen dosyayı şu konuma kopyalayın:
   ```
   C:\Users\Serce\kolektif_akil_platform\android\app\google-services.json
   ```

✅ **Kontrol**: `android/app/google-services.json` dosyası mevcut mu?

---

## 🔥 Adım 4: Firebase Authentication'ı Etkinleştirme

1. Firebase Console'da sol menüden **"Authentication"** (Kimlik Doğrulama) seçin
2. **"Get started"** (Başlayın) butonuna tıklayın
3. **"Sign-in method"** (Giriş yöntemi) sekmesine gidin
4. **"Email/Password"** seçeneğini tıklayın
5. **"Enable"** (Etkinleştir) toggle'ını açın
6. **"Save"** (Kaydet) butonuna tıklayın

✅ **Kontrol**: Email/Password authentication etkin mi?

---

## 🔥 Adım 5: Firestore Database Oluşturma

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

## 🔥 Adım 6: Realtime Database Oluşturma (Bitki için)

1. Firebase Console'da sol menüden **"Realtime Database"** seçin
2. **"Create database"** (Veritabanı Oluştur) butonuna tıklayın
3. **"Start in test mode"** (Test modunda başlat) seçeneğini seçin
4. **Location** (Konum) seçin (Firestore ile aynı veya farklı olabilir)
5. **"Done"** (Tamam) butonuna tıklayın

✅ **Kontrol**: Realtime Database oluşturuldu mu?

---

## 🔥 Adım 7: Android build.gradle Yapılandırması

Firebase'i Android projesine entegre etmek için Gradle dosyalarını güncellememiz gerekiyor.

### 7.1. Proje seviyesi build.gradle

1. `android/build.gradle` dosyasını açın
2. `dependencies` bölümüne şunu ekleyin (yoksa):

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

### 7.2. Uygulama seviyesi build.gradle

1. `android/app/build.gradle` dosyasını açın
2. Dosyanın **en altına** şunu ekleyin:

```gradle
apply plugin: 'com.google.gms.google-services'
```

---

## ✅ Tamamlandı!

Tüm adımları tamamladıysanız, Firebase yapılandırması hazır!

### Sonraki Adımlar

1. Projeyi test edin: `flutter run`
2. Uygulamada kayıt olun ve giriş yapın
3. Bir karar analizi yapın

### Sorun mu yaşıyorsunuz?

- `google-services.json` dosyasının doğru konumda olduğundan emin olun
- Gradle dosyalarının doğru güncellendiğini kontrol edin
- Firebase Console'da tüm servislerin etkin olduğunu kontrol edin

