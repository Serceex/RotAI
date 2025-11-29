import tkinter as tk
from tkinter import ttk
import pyautogui
import pytesseract
from googletrans import Translator
from PIL import Image, ImageGrab
import time

# Tesseract yolunu ayarlayın (Windows için)
pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'

class ScreenTranslator:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Screen Translator")
        self.root.geometry("400x300")
        
        # Tesseract yolunu ayarlayın (Windows için)
        # pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'
        
        # Çeviri için Google Translate kullan
        self.translator = Translator()
        
        self.setup_ui()
        
    def setup_ui(self):
        # Başlık
        title_label = tk.Label(self.root, text="Screen Translator", font=("Arial", 16, "bold"))
        title_label.pack(pady=10)
        
        # Bölge seçimi için butonlar
        frame = tk.Frame(self.root)
        frame.pack(pady=10)
        
        self.select_area_btn = tk.Button(frame, text="Bölge Seç", command=self.select_area)
        self.select_area_btn.pack(side=tk.LEFT, padx=5)
        
        self.capture_btn = tk.Button(frame, text="Çevir", command=self.capture_and_translate)
        self.capture_btn.pack(side=tk.LEFT, padx=5)
        
        # Sonuç alanı
        result_frame = tk.LabelFrame(self.root, text="Çeviri Sonucu", padx=5, pady=5)
        result_frame.pack(pady=10, padx=10, fill="both", expand=True)
        
        self.result_text = tk.Text(result_frame, wrap=tk.WORD, height=10)
        self.result_text.pack(fill="both", expand=True)
        
        # Scrollbar
        scrollbar = tk.Scrollbar(self.result_text)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        self.result_text.config(yscrollcommand=scrollbar.set)
        scrollbar.config(command=self.result_text.yview)
        
    def select_area(self):
        """Kullanıcının ekranın bir bölgesini seçmesini sağlar"""
        self.result_text.delete(1.0, tk.END)
        self.result_text.insert(tk.END, "Lütfen ekranın çevirmek istediğiniz bölgesini seçin...")
        
        # Ekran görüntüsü al
        screenshot = pyautogui.screenshot()
        screenshot.save("screenshot.png")
        
        # Kullanıcıdan bölge seçmesini iste (basitleştirilmiş)
        # Gerçek uygulamada burada bir bölge seçici yapılmalı
        self.result_text.delete(1.0, tk.END)
        self.result_text.insert(tk.END, "Bölge seçildi. Şimdi 'Çevir' butonuna basın.")
        
    def capture_and_translate(self):
        """Seçilen bölgeyi yakalar, OCR ile metni okur ve çevirir"""
        try:
            # Örnek olarak ekranın ortasından küçük bir bölge alalım
            screen_width, screen_height = pyautogui.size()
            region = (
                screen_width // 4,     # x
                screen_height // 4,    # y
                screen_width // 2,     # width
                screen_height // 2     # height
            )
            
            # Bölgeyi yakala
            screenshot = ImageGrab.grab(bbox=region)
            screenshot.save("captured_region.png")
            
            # OCR ile metni oku
            text = pytesseract.image_to_string(screenshot, lang='eng')
            
            if text.strip():
                # Metni çevir
                translated = self.translator.translate(text, src='en', dest='tr')
                
                # Sonuçları göster
                self.result_text.delete(1.0, tk.END)
                self.result_text.insert(tk.END, f"Orijinal Metin:\n{text}\n\n")
                self.result_text.insert(tk.END, f"Çevrilen Metin:\n{translated.text}")
            else:
                self.result_text.delete(1.0, tk.END)
                self.result_text.insert(tk.END, "Seçilen bölgede metin bulunamadı.")
                
        except Exception as e:
            self.result_text.delete(1.0, tk.END)
            self.result_text.insert(tk.END, f"Hata oluştu: {str(e)}")
    
    def run(self):
        self.root.mainloop()

if __name__ == "__main__":
    app = ScreenTranslator()
    app.run()