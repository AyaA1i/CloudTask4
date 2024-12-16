import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:task3/models/app_user.dart';
import 'package:task3/screens/main_screen.dart';
import 'package:task3/screens/sign_in.dart';
import 'package:task3/services/auth_service.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen(
      {super.key,
      required this.verificationId,
      required this.username,
      required this.phoneNumber,
      required this.mode});
  final String verificationId;
  final String username;
  final String phoneNumber;
  final String mode;

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final otpController = TextEditingController();
  final authService = AuthService();
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "We have sent an OTP to your phone. Plz verify",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 40),
          TextField(
            controller: otpController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
                fillColor: Colors.grey.withOpacity(0.25),
                filled: true,
                hintText: "Enter OTP",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none)),
          ),
          const SizedBox(height: 20),
          isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });

                    try {
                      final cred = PhoneAuthProvider.credential(
                          verificationId: widget.verificationId,
                          smsCode: otpController.text);

                      await FirebaseAuth.instance.signInWithCredential(cred);
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        if (widget.mode == "1") {
                          AppUser? user = authService.createUser(
                              '', widget.username, '', widget.phoneNumber);
                          await authService.saveUser(user);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignIn(),
                              ));
                        } else {
                          authService.signinPN(widget.phoneNumber);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MainScreen(),
                              ));
                        }
                      }
                    } catch (e) {
                      log(e.toString());
                    }
                    setState(() {
                      isLoading = false;
                    });
                  },
                  child: const Text(
                    "Verify",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ))
        ],
      ),
    ));
  }
}
