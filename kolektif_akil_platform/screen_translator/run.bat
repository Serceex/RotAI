@echo off
echo Screen Translator uygulaması başlatılıyor...
echo.

REM Gerekli paketleri yükle
echo Gerekli paketler kontrol ediliyor...
pip install -r requirements.txt

echo.
echo Uygulama başlatılıyor...
python main.py

pause