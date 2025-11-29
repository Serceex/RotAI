# Android Emülatörü Oluşturma

Windows'ta Visual Studio sorunu nedeniyle, Android emülatörü kullanarak projeyi test edebilirsiniz.

## 📱 Adım 1: Android Studio Kurulumu (Eğer yoksa)

1. Android Studio'yu indirin: https://developer.android.com/studio
2. Kurulum sırasında "Android Virtual Device (AVD)" seçeneğini işaretleyin
3. Kurulumu tamamlayın

## 📱 Adım 2: Android Emülatörü Oluşturma

### Yöntem 1: Android Studio ile

1. Android Studio'yu açın
2. "More Actions" > "Virtual Device Manager" seçin
3. "Create Device" butonuna tıklayın
4. Bir cihaz seçin (örn: Pixel 5)
5. Sistem görüntüsü seçin (örn: API 33 veya 34)
6. "Finish" butonuna tıklayın
7. Oluşturulan emülatörü başlatın

### Yöntem 2: Komut Satırı ile

```bash
# Emülatör oluştur
flutter emulators --create

# Veya manuel olarak
flutter emulators --create --name pixel_5
```

## 📱 Adım 3: Emülatörü Başlatma

```bash
# Mevcut emülatörleri listele
flutter emulators

# Emülatörü başlat
flutter emulators --launch <emulator_id>

# Veya doğrudan çalıştır
flutter run
```

## ✅ Alternatif: Chrome'da Çalıştırma

Eğer emülatör oluşturmak istemiyorsanız, Chrome'da çalıştırabilirsiniz:

```bash
flutter run -d chrome
```

**Not**: Chrome'da çalıştırmak için Firebase Web yapılandırması gereklidir. 
`FIREBASE_WEB_YAPILANDIRMA.md` dosyasına bakın.

