@echo off
echo Advanced Screen Translator uygulaması başlatılıyor...
echo.

REM Gerekli paketleri yükle
echo Gerekli paketler kontrol ediliyor...
pip install -r requirements.txt

echo.
echo Advanced uygulama başlatılıyor...
python advanced_translator.py

pause