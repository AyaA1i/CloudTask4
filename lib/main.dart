import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task3/screens/main_screen.dart';
import 'package:task3/screens/sign_in.dart';
import 'package:task3/services/notification_service.dart';
import 'package:task3/services/user_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  FirebaseAnalytics.instance.setSessionTimeoutDuration(const Duration(minutes: 30));
  await NotificationService.instance.initialize();
  final Widget homeScreen = await getInitialScreen();
  runApp(MyApp(
    homeScreen: homeScreen,
  ));
}

Future<Widget> getInitialScreen() async {
  final UserService userService = UserService();
  final AppUser = await userService.getSignedInUser();

  if (AppUser == null) {
    return const SignIn();
  } else {
    return const MainScreen();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.homeScreen});
  final Widget homeScreen;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
          cardColor: Colors.white,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context)
              .textTheme
              .copyWith(
                  headlineLarge: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 24),
                  bodyLarge: const TextStyle(fontSize: 16),
                  bodyMedium: const TextStyle(fontSize: 14),
                  bodySmall: const TextStyle(fontSize: 12))),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5f4bce),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          iconTheme: const IconThemeData(
            color: Color(0xFF5f4bce),
          ),
          snackBarTheme: SnackBarThemeData(
              backgroundColor: Colors.black45,
              contentTextStyle: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Colors.white))),
      home: homeScreen,
    );
  }
}
