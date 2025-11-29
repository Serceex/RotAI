from setuptools import setup, find_packages

setup(
    name="screen-translator",
    version="1.0.0",
    author="Your Name",
    author_email="your.email@example.com",
    description="Ekran bölgesi seçerek metin okuma ve çeviri yapan uygulama",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    url="https://github.com/yourusername/screen-translator",
    packages=find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires='>=3.7',
    install_requires=[
        "pyautogui>=0.9.54",
        "pytesseract>=0.3.10",
        "googletrans==4.0.0rc1",
        "Pillow>=10.0.1",
    ],
    entry_points={
        'console_scripts': [
            'screen-translator=screen_translator.main:main',
        ],
    },
)