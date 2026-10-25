import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_sabel/l10n/app_localizations.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart'; // Импорт пакета ATT

import 'features/onbording/presentetion/main_tab_screen.dart';
import 'features/onbording/presentetion/onbording_screen.dart';
import 'package:flutter_sabel/core/di/injection_container.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isOnboardingCompleted = prefs.getBool('isOnboardingCompleted') ?? false;

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initDependencies();

  runApp(MyApp(isOnboardingCompleted: isOnboardingCompleted));
}

class MyApp extends StatefulWidget {
  final bool isOnboardingCompleted;

  const MyApp({super.key, required this.isOnboardingCompleted});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Запрашиваем разрешение ATT после построения первого кадра (только для iOS)
    WidgetsBinding.instance.addPostFrameCallback((_) => initPlugin());
  }

  Future<void> initPlugin() async {
    // Проверяем статус ATT (актуально только для iOS 14.5+)
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;

    // Если статус еще не определен (notDetermined), показываем системный диалог
    if (status == TrackingStatus.notDetermined) {
      // Можно опционально показать кастомный экран-объяснение (custom rationale dialog) перед этим
      await Future.delayed(const Duration(milliseconds: 200));
      final authorizationStatus =
          await AppTrackingTransparency.requestTrackingAuthorization();
      print("Статус ATT после запроса: $authorizationStatus");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: widget.isOnboardingCompleted
          ? const MainTabScreen()
          : const OnboardingScreen(),
    );
  }
}

// test111 заливаем на бек товары!
///////// ======== /////////

// Future<void> uploadMocksToFirebase(ServerProductApiClient apiClient) async {
//   final mocks = [
//     {
//       "articul": "116",
//       "count": 85,
//       "desc":
//           "Худи оверсайз из плотного футера с начесом, мягкий капюшон и карман-кенгуру.",
//       "imageUrl":
//           "https://raw.githubusercontent.com/Nikita318-creator/sabell_server/refs/heads/main/hoodie_heavy.jpg",
//       "isShowOnHomeScreen": true,
//       "price": 120.0,
//       "size": "S",
//       "tags": "худи,толстовка,оверсайз,streetwear,одежда",
//       "title": "Худи оверсайз Heavy Fleece",
//     },
//     {
//       "articul": "117",
//       "count": 45,
//       "desc":
//           "Классические джинсы прямого кроя из плотного денима без стрейча.",
//       "imageUrl":
//           "https://raw.githubusercontent.com/Nikita318-creator/sabell_server/refs/heads/main/jeans_straight.jpg",
//       "isShowOnHomeScreen": true,
//       "price": 95.0,
//       "size": "L",
//       "tags": "джинсы,мужское,деним,штаны,база",
//       "title": "Джинсы мужские Straight Denim",
//     },
//     {
//       "articul": "118",
//       "count": 60,
//       "desc":
//           "Утепленная куртка-бомбер на молнии с подкладкой, защита от ветра.",
//       "imageUrl":
//           "https://raw.githubusercontent.com/Nikita318-creator/sabell_server/refs/heads/main/bomber_jacket.jpg",
//       "isShowOnHomeScreen": true,
//       "price": 180.0,
//       "size": "XL",
//       "tags": "куртка,бомбер,верхняя одежда,мужское,streetwear",
//       "title": "Куртка-бомбер Classic Black",
//     },
//     {
//       "articul": "119",
//       "count": 110,
//       "desc": "Минималистичный свитшот прямого кроя из мягкого хлопка.",
//       "imageUrl":
//           "https://raw.githubusercontent.com/Nikita318-creator/sabell_server/refs/heads/main/sweatshirt_grey.jpg",
//       "isShowOnHomeScreen": false,
//       "price": 75.0,
//       "size": "M",
//       "tags": "свитшот,кофта,мужское,база,хлопок",
//       "title": "Свитшот серый Essential",
//     },
//     {
//       "articul": "120",
//       "count": 70,
//       "desc":
//           "Свободные брюки карго с объемными накладными карманами и утяжками снизу.",
//       "imageUrl":
//           "https://raw.githubusercontent.com/Nikita318-creator/sabell_server/refs/heads/main/cargo_pants.jpg",
//       "isShowOnHomeScreen": true,
//       "price": 88.0,
//       "size": "M",
//       "tags": "карго,брюки,штаны,streetwear,одежда",
//       "title": "Брюки карго Tactical Olive",
//     },
//     {
//       "articul": "121",
//       "count": 95,
//       "desc":
//           "Вельветовая рубашка оверсайз свободного кроя, подходит как верхний слой.",
//       "imageUrl":
//           "https://raw.githubusercontent.com/Nikita318-creator/sabell_server/refs/heads/main/corduroy_shirt.jpg",
//       "isShowOnHomeScreen": false,
//       "price": 80.0,
//       "size": "XL",
//       "tags": "рубашка,вельвет,оверсайз,мужское,кэжуал",
//       "title": "Рубашка вельветовая Corduroy Vintage",
//     },
//     {
//       "articul": "122",
//       "count": 150,
//       "desc":
//           "Плотная хлопковая бейсболка с регулируемым ремешком и вышитым логотипом.",
//       "imageUrl":
//           "https://raw.githubusercontent.com/Nikita318-creator/sabell_server/refs/heads/main/cap_black.jpg",
//       "isShowOnHomeScreen": true,
//       "price": 35.0,
//       "size": "S",
//       "tags": "кепка,бейсболка,аксессуары,streetwear,база",
//       "title": "Бейсболка монохромная Cap Logo",
//     },
//     {
//       "articul": "123",
//       "count": 40,
//       "desc": "Плотный шерстяной свитер крупной вязки с высоким горлом.",
//       "imageUrl":
//           "https://raw.githubusercontent.com/Nikita318-creator/sabell_server/refs/heads/main/knit_sweater.jpg",
//       "isShowOnHomeScreen": false,
//       "price": 110.0,
//       "size": "XS",
//       "tags": "свитер,вязка,шерсть,зима,мужское",
//       "title": "Свитер вязаный Wool Knit",
//     },
//     {
//       "articul": "124",
//       "count": 120,
//       "desc":
//           "Спортивные штаны из плотного хлопка на резинке с глубокими карманами.",
//       "imageUrl":
//           "https://raw.githubusercontent.com/Nikita318-creator/sabell_server/refs/heads/main/sweatpants.jpg",
//       "isShowOnHomeScreen": false,
//       "price": 65.0,
//       "size": "L",
//       "tags": "джоггеры,штаны,спорт,база,хлопок",
//       "title": "Джоггеры спортивные Chill Sweatpants",
//     },
//     {
//       "articul": "125",
//       "count": 55,
//       "desc": "Удлиненная джинсовая куртка с эффектом винтажной потертости.",
//       "imageUrl":
//           "https://raw.githubusercontent.com/Nikita318-creator/sabell_server/refs/heads/main/denim_jacket.jpg",
//       "isShowOnHomeScreen": true,
//       "price": 135.0,
//       "size": "M",
//       "tags": "джинсовка,куртка,деним,оверсайз,streetwear",
//       "title": "Джинсовая куртка Raw Denim",
//     },
//   ];

//   await apiClient.seedMockProducts(mocks);
//   print('✅ Успешно зашито 10 моков в коллекцию products!');
// }

  ///////// ======== /////////