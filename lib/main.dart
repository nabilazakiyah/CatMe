
import 'package:flutter/material.dart';
import 'package:flutter_application_1/login/registrasi_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login/login_page.dart';
import 'view/cat_view.dart';
import 'view/lokasi.dart';
import 'view/profil.dart';
import 'view/cat_detail_page.dart';
import 'model/cat_model.dart';

final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await notifications.initialize(
    const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
  );
const channel = AndroidNotificationChannel(
  'adopsi_channel', 'Adopsi Kucing',
  description: 'Notifikasi adopsi berhasil',
  importance: Importance.high,
  sound: RawResourceAndroidNotificationSound('meow'),
  playSound: true,
  enableVibration: true,
);
await notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);


  final prefs = await SharedPreferences.getInstance();
  final firstTime = prefs.getBool('first_time') ?? true;
  if (firstTime) {
    await prefs.clear();
    await prefs.setBool('first_time', false);
  }
  final loggedIn = prefs.getBool('logged_in') ?? false;

  runApp(MyApp(initialRoute: loggedIn ? '/home' : '/login'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CatMe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.orange[50],
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/home': (_) => const MainNavigator(),
        '/detail': (context) {
          final cat = ModalRoute.of(context)!.settings.arguments as CatModel;
          return CatDetailPage(cat: cat);
        },
      },
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});
  @override State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int index = 0;
  final pages = [const CatView(), const LokasiPage(), const ProfilPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        selectedItemColor: Colors.orange,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Lokasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}