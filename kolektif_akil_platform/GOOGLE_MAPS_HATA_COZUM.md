# Google Maps API Hatası Çözümü

## Hata Mesajı
```
SecurityException: Unknown calling package name 'com.google.android.gms'
DEVELOPER_ERROR - ConnectionResult
```

## Çözüm Adımları

### 1. SHA-1 Fingerprint'i Alın

#### Windows (PowerShell):
```powershell
cd android
.\gradlew signingReport
```

Çıktıda `SHA1:` ile başlayan satırı bulun. Örnek:
```
SHA1: A1:B2:C3:D4:E5:F6:...
```

#### Alternatif Yöntem (Keytool):
```powershell
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

### 2. Google Cloud Console'da API Anahtarını Güncelleyin

1. [Google Cloud Console](https://console.cloud.google.com/)'a gidin
2. Projenizi seçin: `kolektif-akil-platform`
3. **APIs & Services** > **Credentials** bölümüne gidin
4. Google Maps API anahtarınızı bulun: `AIzaSyDWE1stgYOxWF54jBCkSo4W4U7bGZzivxg`
5. Anahtarı düzenleyin
6. **Application restrictions** bölümünde:
   - **Android apps** seçin
   - **+ Add an item** butonuna tıklayın
   - **Package name**: `com.example.kolektif_akil_platform` (veya projenizin package adı)
   - **SHA-1 certificate fingerprint**: Yukarıda aldığınız SHA-1 değerini yapıştırın
7. **Save** butonuna tıklayın

### 3. API Kısıtlamalarını Kontrol Edin

1. Aynı sayfada **API restrictions** bölümüne gidin
2. Şu API'lerin seçili olduğundan emin olun:
   - ✅ Maps SDK for Android
   - ✅ Places API (eğer kullanıyorsanız)
   - ✅ Geocoding API (eğer kullanıyorsanız)

### 4. Uygulamayı Yeniden Derleyin

```bash
flutter clean
flutter pub get
flutter run
```

### 5. Hata Devam Ederse

#### Geçici Çözüm (Sadece Geliştirme İçin):
Google Cloud Console'da API anahtarının kısıtlamalarını geçici olarak kaldırabilirsiniz:
- **Application restrictions**: **None** seçin
- ⚠️ **DİKKAT**: Bu sadece test için! Production'da mutlaka kısıtlamaları aktif edin.

#### Production Build İçin:
Release keystore'unuzun SHA-1'ini de eklemeniz gerekir:
```powershell
keytool -list -v -keystore "path/to/your/release.keystore" -alias your-alias
```

## Kontrol Listesi

- [ ] SHA-1 fingerprint alındı
- [ ] Google Cloud Console'da API anahtarı güncellendi
- [ ] Package name doğru girildi
- [ ] Gerekli API'ler etkinleştirildi
- [ ] Uygulama yeniden derlendi
- [ ] Hata çözüldü

## Ek Notlar

- SHA-1 fingerprint, debug ve release için farklı olabilir
- Her iki fingerprint'i de eklemeniz önerilir
- API anahtarı değişiklikleri birkaç dakika içinde aktif olur
- Bazen Google Play Services cache'ini temizlemek gerekebilir

## Yardım

Hata devam ederse:
1. Logcat'te tam hata mesajını kontrol edin
2. Google Cloud Console'da API kullanım istatistiklerini kontrol edin
3. API kotası aşılmamış olduğundan emin olun

