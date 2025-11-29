# Gemini API Sorun Giderme

Eğer "Hiçbir model çalışmadı" hatası alıyorsanız, şu adımları izleyin:

## 🔑 Adım 1: API Anahtarını Kontrol Edin

1. **Google AI Studio'ya gidin**: https://makersuite.google.com/app/apikey
2. **Mevcut API anahtarınızı kontrol edin**
3. **Yeni bir API anahtarı oluşturun** (gerekirse):
   - "Create API Key" butonuna tıklayın
   - Yeni anahtarı kopyalayın
   - `lib/config/api_config.dart` dosyasındaki `geminiApiKey` değerini güncelleyin

## ✅ Adım 2: API Anahtarını Güncelleme

1. `lib/config/api_config.dart` dosyasını açın
2. `geminiApiKey` değerini yeni API anahtarı ile değiştirin:

```dart
static const String geminiApiKey = 'YENİ_API_ANAHTARINIZ';
```

3. Uygulamayı yeniden başlatın

## 🔒 Adım 3: API Kısıtlamalarını Kontrol Edin

1. Google Cloud Console'a gidin: https://console.cloud.google.com/
2. Projenizi seçin
3. "APIs & Services" > "Credentials" seçin
4. API anahtarınızı bulun ve tıklayın
5. "API restrictions" bölümünü kontrol edin:
   - "Don't restrict key" seçeneğini seçin VEYA
   - "Restrict key" seçeneğinde "Generative Language API" seçili olduğundan emin olun

## 🌐 Adım 4: Generative Language API'yi Etkinleştirin

1. Google Cloud Console'da "APIs & Services" > "Library" seçin
2. "Generative Language API" araması yapın
3. API'yi seçin ve "Enable" (Etkinleştir) butonuna tıklayın

## 📝 Adım 5: API Anahtarı Formatını Kontrol Edin

API anahtarınız şu formatta olmalıdır:
- `AIza...` ile başlamalı
- Yaklaşık 39 karakter uzunluğunda olmalı
- Boşluk veya özel karakter içermemeli

## 🔄 Alternatif Çözüm: Yeni API Anahtarı Oluşturma

Eğer yukarıdaki adımlar işe yaramazsa:

1. Google AI Studio'da mevcut API anahtarınızı silin
2. Yeni bir API anahtarı oluşturun
3. Yeni anahtarı `lib/config/api_config.dart` dosyasına ekleyin
4. Uygulamayı tamamen yeniden başlatın

## ❓ Hala Çalışmıyor mu?

Eğer hala sorun yaşıyorsanız:

1. **Tarayıcı konsolunu kontrol edin** (F12 > Console)
2. **Detaylı hata mesajını** not edin
3. **API anahtarınızın aktif olduğundan** emin olun
4. **Google Cloud Console'da kullanım limitlerini** kontrol edin

## 💡 Not

- API anahtarları ücretsiz kullanım için günlük limitlere sahiptir
- Eğer limit aşıldıysa, ertesi gün tekrar deneyin
- API anahtarınızı asla public repository'lere commit etmeyin

