class AppUser {
  String id;
  String username;
  String? email;
  String? phoneNumber;
  String? password;
  String? fcmToken;
  bool firstLogin;
  List<String> subscribedChannels;

  AppUser(
      {required this.id,
      required this.username,
      required this.email,
      required this.phoneNumber,
      required this.password,
      required this.fcmToken,
      required this.firstLogin,
      required this.subscribedChannels});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'phoneNumber': phoneNumber ?? '',
      'email': email ?? '',
      'password': password ?? '',
      'fcmToken': fcmToken ?? '',
      'firstLogin': firstLogin,
      'subscribedChannels': subscribedChannels,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      password: map['password'] ?? '',
      fcmToken: map['fcmToken'] ?? '',
      firstLogin: map['firstLogin'],
      subscribedChannels: List<String>.from(map['subscribedChannels'] ?? []),
    );
  }
}
