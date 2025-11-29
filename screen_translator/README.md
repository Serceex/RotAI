# Screen Translator

Bu uygulama, ekranın belirli bir bölgesini yakalayarak oradaki metni okur ve çeviri yapar. Çevrilen metni şeffaf bir overlay pencere içinde gösterir.

## Özellikler

1. **Ekran Yakalama**: Belirlediğiniz ekran bölgesini yakalar
2. **OCR (Optik Karakter Tanıma)**: Görüntüden metin okur
3. **Çeviri**: Okunan metni farklı dillere çevirir
4. **Overlay Pencere**: Çevrilen metni şeffaf bir pencere içinde gösterir

## Gereksinimler

- Python 3.7 veya üzeri
- Tesseract OCR

## Kurulum

### 1. Python Gereksinimlerinin Yüklenmesi

```bash
pip install -r requirements.txt
```

### 2. Tesseract OCR Kurulumu

#### Windows:
1. https://github.com/UB-Mannheim/tesseract/wiki adresinden Tesseract OCR indirin ve kurun
2. Kurulum tamamlandıktan sonra aşağıdaki satırı `main.py` ve `advanced_translator.py` dosyalarında uncomment edin:
   ```python
   pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'
   ```

#### macOS:
```bash
brew install tesseract
```

#### Linux:
```bash
sudo apt install tesseract-ocr
```

## Kullanım

### Basit Versiyon
```bash
python main.py
```

### Gelişmiş Versiyon
```bash
python advanced_translator.py
```

Veya doğrudan batch dosyalarını çalıştırabilirsiniz:
- `run.bat` - Basit versiyonu çalıştırır
- `run_advanced.bat` - Gelişmiş versiyonu çalıştırır

## Özellikler

### Basit Versiyon
- Ekranın ortasındaki bölgeyi otomatik olarak yakalar
- İngilizce metni Türkçeye çevirir
- Sonuçları uygulama penceresinde gösterir

### Gelişmiş Versiyon
- İstediğiniz ekran bölgesini seçebilirsiniz
- Farklı dil kombinasyonları destekler
- Çevrilen metni şeffaf overlay pencere içinde gösterir
- Overlay pencereyi taşıyabilir ve kapatabilirsiniz

## Desteklenen Diller

OCR için desteklenen diller:
- eng (İngilizce)
- tur (Türkçe)
- fra (Fransızca)
- spa (İspanyolca)
- deu (Almanca)

Çeviri için desteklenen diller:
- tr (Türkçe)
- en (İngilizce)
- fr (Fransızca)
- es (İspanyolca)
- de (Almanca)

## Nasıl Çalışır?

1. **Bölge Seçme**: "Bölge Seç" butonuna tıklayarak çevirmek istediğiniz ekran bölgesini seçin
2. **Çeviri Yapma**: "Çevir" butonuna tıklayarak seçilen bölgedeki metni çevirin
3. **Overlay Gösterme**: "Overlay Göster" butonuna tıklayarak çevrilen metni şeffaf pencere içinde görüntüleyin

## Sorun Giderme

### "Tesseract not found" hatası
Tesseract OCR'in doğru şekilde kurulduğundan ve yolunun ayarlandığından emin olun.

### Çeviri yapılmıyor
İnternet bağlantınızı kontrol edin. Google Translate API'si için internet bağlantısı gereklidir.

## Lisans

Bu proje MIT lisansı ile lisanslanmıştır.