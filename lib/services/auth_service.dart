import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task3/services/notification_service.dart';
import 'package:task3/services/user_service.dart';
import 'package:uuid/uuid.dart';
import 'package:task3/models/app_user.dart';

Uuid uuid = const Uuid();

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AppUser createUser(
      String? email, String? username, String? password, String? phoneNumber) {
    String userId = const Uuid().v4();
    AppUser newUser = AppUser(
      id: userId,
      username: username ?? '',
      email: email ?? '',
      phoneNumber: phoneNumber ?? '',
      password: password ?? '',
      fcmToken: '',
      firstLogin: true,
      subscribedChannels: [],
    );
    return newUser;
  }

  Future<bool> userExists(String email) async {
    try {
      var result = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (result.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<String?> saveUser(AppUser appUser) async {
    try {
      await _firestore.collection('users').doc(appUser.id).set(appUser.toMap());
      return null;
    } catch (e) {
      return 'Error saving AppUser';
    }
  }

  Future<String?> findUserByEmailAndPassword(
      String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } catch (e) {
      return "error";
    }
  }

  Future<AppUser?> signInEP(String email, String password) async {
    try {
      var result = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      if (result.docs.isNotEmpty) {
        var userData = result.docs.first.data();
        var appUser = AppUser.fromMap(userData);
        if (userData['firstLogin'] == true) {
          await FirebaseAnalytics.instance.logEvent(
            name: 'first_time_login',
            parameters: {
              'user_id': appUser.id,
            },
          );
          await _firestore
              .collection('users')
              .doc(appUser.id)
              .update({'firstLogin': false});
          appUser.firstLogin = false;
          NotificationService.instance.showNotificationWithDetails(
              "Channelo", "Welcome to our application!");
        }
        saveSignedInUser(appUser);

        return appUser;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> findUserByGoogle(int mode) async {
    print(mode);
    try {
      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser!.authentication;
      final cred = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(cred);
      if (mode == 1) {
        final exist = await userExists(userCredential.user!.email!);
        if (!exist) {
          final user = createUser(userCredential.user!.email!,
              userCredential.user!.displayName ?? 'Anonymous', '', '');
          await saveUser(user);
        }
      }
      if (mode == 2) {
        print("in mode2");
        await signinGoogle(userCredential.user!.email!);
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<AppUser?> signinGoogle(String email) async {
    try {
      print("in");
      var result = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (result.docs.isNotEmpty) {
        var userData = result.docs.first.data();
        var appUser = AppUser.fromMap(userData);
        print(appUser.email!);
        if (userData['firstLogin'] == true) {
          await FirebaseAnalytics.instance.logEvent(
            name: 'first_time_login',
            parameters: {
              'user_id': appUser.id,
            },
          );
          await _firestore
              .collection('users')
              .doc(appUser.id)
              .update({'firstLogin': false});
          appUser.firstLogin = false;
          NotificationService.instance.showNotificationWithDetails(
              "Channelo", "Welcome to our application!");
        }
        saveSignedInUser(appUser);
        return appUser;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> signinPN(String phoneNumber) async {
    try {
      var result = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      if (result.docs.isNotEmpty) {
        var userData = result.docs.first.data();
        var appUser = AppUser.fromMap(userData);
        if (userData['firstLogin'] == true) {
          await FirebaseAnalytics.instance.logEvent(
            name: 'first_time_login',
            parameters: {
              'user_id': appUser.id,
            },
          );
          await _firestore
              .collection('users')
              .doc(appUser.id)
              .update({'firstLogin': false});
          appUser.firstLogin = false;
          NotificationService.instance.showNotificationWithDetails(
              "Channelo", "Welcome to our application!");
        }
        saveSignedInUser(appUser);
      } else {}
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> saveSignedInUser(AppUser appUser) async {
    String? token = await NotificationService.instance.getDeviceToken();
    AppUser? newUser;
    if (token != null) {
      newUser = await UserService().saveDeviceToken(appUser.id, token);
    }
    print(newUser);
    final prefs = await SharedPreferences.getInstance();
    String userJson = jsonEncode(newUser!.toMap());
    await prefs.setString('signedInUser', userJson);
  }
}
