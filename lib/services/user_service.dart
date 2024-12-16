import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task3/models/app_user.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:task3/services/notification_service.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  Future<List<AppUser>> getUsers() async {
    final result = await _firestore.collection('users').get();
    return result.docs.map((doc) => AppUser.fromMap(doc.data())).toList();
  }

  Future<List<AppUser>> getUsersByChannel(String channelName) async {
    try {
      final result = await _firestore
          .collection('users')
          .where('subscribedChannels', arrayContains: channelName)
          .get();

      return result.docs.map((doc) => AppUser.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error fetching users by channel: $e');
      return [];
    }
  }

  Future<void> updateSignedInUser(AppUser signedInUser) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('signedInUser', jsonEncode(signedInUser.toMap()));
  }

  Future<AppUser?> getSignedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('signedInUser');
    if (userJson != null) {
      Map<String, dynamic> userMap = jsonDecode(userJson);
      AppUser localUser = AppUser.fromMap(userMap);
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(localUser.id)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> firestoreData = userDoc.data()!;
        AppUser firestoreUser = AppUser.fromMap(firestoreData);
        if (localUser.subscribedChannels != firestoreUser.subscribedChannels) {
          await prefs.setString('signedInUser', jsonEncode(firestoreData));
          return firestoreUser;
        }
        return localUser;
      }
    }
    return null;
  }

  Future<void> subscribeChannel(String channelName, AppUser appUser) async {
    appUser.subscribedChannels.add(channelName);
    await _firestore
        .collection('users')
        .doc(appUser.id)
        .update(appUser.toMap());
    FirebaseMessaging.instance.subscribeToTopic(channelName);
    AppUser? signedInUser = await getSignedInUser();
    if (appUser.id == signedInUser!.id) {
      updateSignedInUser(appUser);
    }
    await analytics.logEvent(
      name: 'user_subscription',
      parameters: {
        'userId': appUser.id,
        'channel_name': channelName,
        'action': 'subscribed',
        'status': 'test_debug',
      },
    );
    NotificationService.instance
        .showNotificationWithDetails("Channelo", "Welcome to $channelName!");
  }

  Future<void> unsubscribeChannel(String channelName, AppUser appUser) async {
    appUser.subscribedChannels.remove(channelName);
    await _firestore
        .collection('users')
        .doc(appUser.id)
        .update(appUser.toMap());
    FirebaseMessaging.instance.unsubscribeFromTopic(channelName);
    AppUser? signedInUser = await getSignedInUser();
    if (appUser.id == signedInUser!.id) {
      updateSignedInUser(appUser);
    }
    await analytics.logEvent(
      name: 'user_subscription',
      parameters: {
        'userId': appUser.id,
        'channel_name': channelName,
        'action': 'unsubscribed',
      },
    );
    NotificationService.instance.showNotificationWithDetails(
        "Channelo", "We are sad for your leaving from $channelName :(");
  }

  Future<AppUser?> saveDeviceToken(String userId, String deviceToken) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': deviceToken,
      });
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        AppUser updatedUser = AppUser.fromMap(userData);
        return updatedUser;
      }
    } catch (e) {
      print('Error saving device token: $e');
    }
    return null;
  }

  Future<void> logout() async {
    final user = await getSignedInUser();
    await FirebaseAuth.instance.signOut();
    await analytics.logEvent(
      name: 'user_logged_out',
      parameters: {
        'userId': user!.id,
      },
    );
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('signedInUser');
  }
}
