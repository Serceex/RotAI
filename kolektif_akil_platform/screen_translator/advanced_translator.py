import tkinter as tk
from tkinter import ttk
import pyautogui
import pytesseract
from googletrans import Translator
from PIL import Image, ImageGrab, ImageTk
import threading
import time

# Tesseract yolunu ayarlayın (Windows için)
pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'

class ScreenTranslator:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Advanced Screen Translator")
        self.root.geometry("500x400")
        
        # Tesseract yolunu ayarlayın (Windows için)
        # pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'
        
        # Çeviri için Google Translate kullan
        self.translator = Translator()
        
        # Bölge seçimi değişkenleri
        self.start_x = None
        self.start_y = None
        self.end_x = None
        self.end_y = None
        self.selecting = False
        self.selection_rect = None
        
        # Overlay pencere
        self.overlay_window = None
        
        self.setup_ui()
        
    def setup_ui(self):
        # Başlık
        title_label = tk.Label(self.root, text="Advanced Screen Translator", font=("Arial", 16, "bold"))
        title_label.pack(pady=10)
        
        # Kontroller
        control_frame = tk.Frame(self.root)
        control_frame.pack(pady=10)
        
        self.select_area_btn = tk.Button(control_frame, text="Bölge Seç", command=self.start_area_selection)
        self.select_area_btn.pack(side=tk.LEFT, padx=5)
        
        self.capture_btn = tk.Button(control_frame, text="Çevir", command=self.capture_and_translate)
        self.capture_btn.pack(side=tk.LEFT, padx=5)
        
        self.overlay_btn = tk.Button(control_frame, text="Overlay Göster", command=self.show_overlay)
        self.overlay_btn.pack(side=tk.LEFT, padx=5)
        
        # Dil seçimi
        lang_frame = tk.Frame(self.root)
        lang_frame.pack(pady=5)
        
        tk.Label(lang_frame, text="Kaynak Dil:").pack(side=tk.LEFT)
        self.source_lang = ttk.Combobox(lang_frame, values=["eng", "tur", "fra", "spa", "deu"], width=10)
        self.source_lang.set("eng")
        self.source_lang.pack(side=tk.LEFT, padx=5)
        
        tk.Label(lang_frame, text="Hedef Dil:").pack(side=tk.LEFT)
        self.target_lang = ttk.Combobox(lang_frame, values=["tr", "en", "fr", "es", "de"], width=10)
        self.target_lang.set("tr")
        self.target_lang.pack(side=tk.LEFT, padx=5)
        
        # Sonuç alanı
        result_frame = tk.LabelFrame(self.root, text="Çeviri Sonucu", padx=5, pady=5)
        result_frame.pack(pady=10, padx=10, fill="both", expand=True)
        
        self.result_text = tk.Text(result_frame, wrap=tk.WORD, height=15)
        self.result_text.pack(fill="both", expand=True)
        
        # Scrollbar
        scrollbar = tk.Scrollbar(self.result_text)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        self.result_text.config(yscrollcommand=scrollbar.set)
        scrollbar.config(command=self.result_text.yview)
        
        # Durum çubuğu
        self.status_var = tk.StringVar()
        self.status_var.set("Hazır")
        status_bar = tk.Label(self.root, textvariable=self.status_var, bd=1, relief=tk.SUNKEN, anchor=tk.W)
        status_bar.pack(side=tk.BOTTOM, fill=tk.X)
        
    def start_area_selection(self):
        """Bölge seçimi başlat"""
        self.status_var.set("Ekranın bir bölgesini seçin...")
        self.result_text.delete(1.0, tk.END)
        self.result_text.insert(tk.END, "Ekranın bir bölgesini seçmek için fareyi sürükleyin...")
        
        # Yeni bir pencere oluşturarak bölge seçimi yap
        self.selection_window = tk.Toplevel(self.root)
        self.selection_window.attributes('-fullscreen', True)
        self.selection_window.attributes('-alpha', 0.3)
        self.selection_window.configure(bg='blue')
        
        # Canvas oluştur
        self.canvas = tk.Canvas(self.selection_window, cursor="cross")
        self.canvas.pack(fill="both", expand=True)
        
        # Fare olaylarını bağla
        self.canvas.bind("<Button-1>", self.on_mouse_down)
        self.canvas.bind("<B1-Motion>", self.on_mouse_drag)
        self.canvas.bind("<ButtonRelease-1>", self.on_mouse_up)
        
        # ESC tuşu ile iptal
        self.selection_window.bind("<Escape>", lambda e: self.cancel_selection())
        
    def on_mouse_down(self, event):
        """Fare basma olayı"""
        self.start_x = event.x
        self.start_y = event.y
        self.selecting = True
        
    def on_mouse_drag(self, event):
        """Fare sürükleme olayı"""
        if self.selecting:
            # Önceki dikdörtgeni sil
            if self.selection_rect:
                self.canvas.delete(self.selection_rect)
            
            # Yeni dikdörtgen çiz
            self.selection_rect = self.canvas.create_rectangle(
                self.start_x, self.start_y, event.x, event.y,
                outline="red", width=2, fill="white", stipple="gray50"
            )
        
    def on_mouse_up(self, event):
        """Fare bırakma olayı"""
        if self.selecting:
            self.end_x = event.x
            self.end_y = event.y
            self.selecting = False
            
            # Seçim penceresini kapat
            self.selection_window.destroy()
            
            # Koordinatları düzelt
            self.x1 = min(self.start_x, self.end_x)
            self.y1 = min(self.start_y, self.end_y)
            self.x2 = max(self.start_x, self.end_x)
            self.y2 = max(self.start_y, self.end_y)
            
            self.status_var.set(f"Bölge seçildi: ({self.x1}, {self.y1}) - ({self.x2}, {self.y2})")
            self.result_text.delete(1.0, tk.END)
            self.result_text.insert(tk.END, f"Bölge seçildi. Şimdi 'Çevir' butonuna basın.\n")
            self.result_text.insert(tk.END, f"Koordinatlar: ({self.x1}, {self.y1}) - ({self.x2}, {self.y2})")
            
    def cancel_selection(self):
        """Bölge seçimini iptal et"""
        self.selection_window.destroy()
        self.status_var.set("Bölge seçimi iptal edildi")
        self.result_text.delete(1.0, tk.END)
        self.result_text.insert(tk.END, "Bölge seçimi iptal edildi.")
        
    def capture_and_translate(self):
        """Seçilen bölgeyi yakalar, OCR ile metni okur ve çevirir"""
        if not hasattr(self, 'x1'):
            self.result_text.delete(1.0, tk.END)
            self.result_text.insert(tk.END, "Lütfen önce bir bölge seçin!")
            return
            
        try:
            self.status_var.set("Çeviri yapılıyor...")
            self.result_text.delete(1.0, tk.END)
            self.result_text.insert(tk.END, "Çeviri yapılıyor...\n\n")
            self.root.update()
            
            # Bölgeyi yakala
            bbox = (self.x1, self.y1, self.x2, self.y2)
            screenshot = ImageGrab.grab(bbox=bbox)
            screenshot.save("captured_region.png")
            
            # OCR ile metni oku
            source_language = self.source_lang.get()
            text = pytesseract.image_to_string(screenshot, lang=source_language)
            
            if text.strip():
                # Metni çevir
                target_language = self.target_lang.get()
                translated = self.translator.translate(text, src=source_language, dest=target_language)
                
                # Sonuçları göster
                self.result_text.delete(1.0, tk.END)
                self.result_text.insert(tk.END, f"Orijinal Metin ({source_language}):\n{text}\n\n")
                self.result_text.insert(tk.END, f"Çevrilen Metin ({target_language}):\n{translated.text}")
                self.status_var.set("Çeviri tamamlandı")
                
                # Çevrilen metni sınıf değişkenine kaydet
                self.translated_text = translated.text
            else:
                self.result_text.delete(1.0, tk.END)
                self.result_text.insert(tk.END, "Seçilen bölgede metin bulunamadı.")
                self.status_var.set("Metin bulunamadı")
                
        except Exception as e:
            self.result_text.delete(1.0, tk.END)
            self.result_text.insert(tk.END, f"Hata oluştu: {str(e)}")
            self.status_var.set("Hata oluştu")
    
    def show_overlay(self):
        """Çevrilen metni overlay pencere içinde göster"""
        if not hasattr(self, 'translated_text'):
            self.result_text.delete(1.0, tk.END)
            self.result_text.insert(tk.END, "Lütfen önce bir çeviri yapın!")
            return
            
        try:
            # Overlay pencereyi oluştur
            if self.overlay_window is None or not self.overlay_window.winfo_exists():
                self.overlay_window = tk.Toplevel(self.root)
                self.overlay_window.title("Çeviri")
                self.overlay_window.geometry("400x200")
                self.overlay_window.attributes('-topmost', True)  # Her zaman üstte
                self.overlay_window.attributes('-alpha', 0.8)  # Şeffaflık
                self.overlay_window.configure(bg='black')
                
                # Pencereyi taşıyabilme özelliği
                self.overlay_window.bind("<Button-1>", self.start_move_overlay)
                self.overlay_window.bind("<B1-Motion>", self.do_move_overlay)
                
                # Kapatma butonu
                close_btn = tk.Button(self.overlay_window, text="×", command=self.close_overlay,
                                    bg='red', fg='white', font=("Arial", 12, "bold"))
                close_btn.place(relx=1.0, rely=0.0, anchor="ne")
                
                # Metin etiketi
                self.overlay_label = tk.Label(
                    self.overlay_window,
                    text=self.translated_text,
                    bg='black',
                    fg='white',
                    font=("Arial", 12),
                    wraplength=380,
                    justify="left"
                )
                self.overlay_label.pack(padx=10, pady=10, fill="both", expand=True)
                
                self.status_var.set("Overlay pencere gösteriliyor")
            else:
                # Metni güncelle
                self.overlay_label.config(text=self.translated_text)
                self.status_var.set("Overlay metni güncellendi")
                
        except Exception as e:
            self.result_text.delete(1.0, tk.END)
            self.result_text.insert(tk.END, f"Overlay gösterim hatası: {str(e)}")
            self.status_var.set("Overlay hatası")
    
    def start_move_overlay(self, event):
        """Overlay pencereyi taşımaya başla"""
        self.overlay_x = event.x
        self.overlay_y = event.y
        
    def do_move_overlay(self, event):
        """Overlay pencereyi taşı"""
        deltax = event.x - self.overlay_x
        deltay = event.y - self.overlay_y
        x = self.overlay_window.winfo_x() + deltax
        y = self.overlay_window.winfo_y() + deltay
        self.overlay_window.geometry(f"+{x}+{y}")
        
    def close_overlay(self):
        """Overlay pencereyi kapat"""
        if self.overlay_window:
            self.overlay_window.destroy()
            self.overlay_window = None
        self.status_var.set("Overlay pencere kapatıldı")
    
    def run(self):
        self.root.mainloop()

if __name__ == "__main__":
    app = ScreenTranslator()
    app.run()