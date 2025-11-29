import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'config/api_config.dart';
import 'providers/auth_provider.dart';
import 'providers/decision_provider.dart';
import 'providers/plant_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/achievement_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase'i başlat
  try {
    if (kIsWeb) {
      // Web için Firebase yapılandırması
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyDETqYjyAkAvjFYcxP_MF-arU0_HRMb-MU',
          appId: '1:880057845074:web:783387bc9dfe26e587668b',
          messagingSenderId: '880057845074',
          projectId: 'kolektif-akil-platform',
          authDomain: 'kolektif-akil-platform.firebaseapp.com',
          storageBucket: 'kolektif-akil-platform.firebasestorage.app',
          databaseURL: 'https://kolektif-akil-platform-default-rtdb.europe-west1.firebasedatabase.app',
        ),
      );
    } else {
      // Android için Firebase yapılandırması
      // google-services.json dosyasından otomatik yüklenir
      // Eğer hata alırsanız, FirebaseOptions'ı manuel olarak sağlayın
      try {
        await Firebase.initializeApp();
      } catch (e) {
        // Otomatik yükleme başarısız olursa, manuel yapılandırma dene
        debugPrint('Otomatik Firebase yükleme başarısız, manuel yapılandırma deneniyor...');
        // Android için FirebaseOptions (google-services.json'dan alınan değerler)
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyDDgnKOscMq3WFK_vqgVLAR6FPEGZqGG1c', // Android için API key
            appId: '1:880057845074:android:24026d3661a7332687668b',
            messagingSenderId: '880057845074',
            projectId: 'kolektif-akil-platform',
            storageBucket: 'kolektif-akil-platform.firebasestorage.app',
            databaseURL: 'https://kolektif-akil-platform-default-rtdb.europe-west1.firebasedatabase.app',
          ),
        );
      }
    }
  } catch (e) {
    debugPrint('Firebase başlatma hatası: $e');
    // Development için Firebase olmadan da çalışabilir
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Gemini API key'i config/api_config.dart dosyasından alınır
        ChangeNotifierProxyProvider<AuthProvider, DecisionProvider>(
          create: (_) => DecisionProvider(
            geminiApiKey: ApiConfig.geminiApiKey,
          ),
          update: (_, authProvider, previous) =>
              previous ?? DecisionProvider(geminiApiKey: ApiConfig.geminiApiKey),
        ),
        ChangeNotifierProvider(create: (_) => PlantProvider()),
        ChangeNotifierProvider(create: (_) => AchievementProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'RotAI',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
              ),
            ),
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
            },
          );
        },
      ),
    );
  }
}
