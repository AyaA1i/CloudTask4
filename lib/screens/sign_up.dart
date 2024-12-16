import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:task3/screens/otp_screen.dart';
import 'package:task3/services/auth_service.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController usernameController = TextEditingController();
  AuthService authService = AuthService();
  final formKey = GlobalKey<FormState>();
  var signUpMethod = 0;
  var email = '';
  var password = '';
  var phoneNumber = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    signupUI = _buildEmailPasswordUI();
  }

  Future<void> saveUser() async {
    if (signUpMethod == 0 && formKey.currentState!.validate()) {
      formKey.currentState!.save();
      try {
        final appUser = authService.createUser(
            email, usernameController.text, password, '');
        await authService.saveUser(appUser);
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Navigate to main screen or next step if required
        Navigator.pop(context);
      } catch (e) {
        // Show error to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error signing up: ${e.toString()}")),
        );
      }
    } else if (signUpMethod == 1 && formKey.currentState!.validate()) {
      formKey.currentState!.save();
      try {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (phoneAuthCredential) {
            // Auto-verification scenario, optional
            print("Auto-verification completed.");
          },
          verificationFailed: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Verification failed: ${error.message}")),
            );
          },
          codeSent: (verificationId, forceResendingToken) {
            // Navigate to OTP screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OTPScreen(
                  verificationId: verificationId,
                  username: usernameController.text,
                  phoneNumber: phoneNumber,
                  mode: "1",
                ),
              ),
            );
          },
          codeAutoRetrievalTimeout: (verificationId) {
            print("Auto-retrieval timeout: $verificationId");
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("Error sending verification code: ${e.toString()}")),
        );
      }
    } else if (signUpMethod == 2) {
      await authService.findUserByGoogle(1);
      Navigator.pop(context);
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    if (!EmailValidator.validate(value)) {
      return 'Please enter a valid email';
    }
    email = value;
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    final passwordRegExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    if (!passwordRegExp.hasMatch(value)) {
      return 'Password must include both letters and numbers';
    }
    password = value;
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    phoneNumber = value;
    return null;
  }

  late Widget signupUI;

  Widget _buildEmailPasswordUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Username',
            labelStyle: TextStyle(color: Color.fromARGB(255, 44, 44, 44)),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF5f4bce)),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
          controller: usernameController,
        ),
        const SizedBox(height: 13),
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(color: Color.fromARGB(255, 44, 44, 44)),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF5f4bce)),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
          validator: validateEmail,
        ),
        const SizedBox(height: 13),
        TextFormField(
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            labelStyle: TextStyle(color: Color.fromARGB(255, 44, 44, 44)),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF5f4bce)),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
          validator: validatePassword,
        ),
        const SizedBox(height: 13),
        TextFormField(
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Confirm Password',
            labelStyle: TextStyle(color: Color.fromARGB(255, 44, 44, 44)),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF5f4bce)),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
          validator: validateConfirmPassword,
        ),
        const SizedBox(height: 35),
        ElevatedButton(
          onPressed: saveUser,
          child: Text(
            "Sign Up",
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }

  void selectSignUpMethod(int method) {
    setState(() {
      if (method == 0) {
        signupUI = _buildEmailPasswordUI();
        signUpMethod = 0;
      } else if (method == 1) {
        signUpMethod = 1;
        signupUI = Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: Color.fromARGB(255, 44, 44, 44)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF5f4bce)),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              controller: usernameController,
            ),
            const SizedBox(height: 13),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                labelStyle: TextStyle(color: Color.fromARGB(255, 44, 44, 44)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF5f4bce)),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              validator: validatePhoneNumber,
            ),
            const SizedBox(height: 35),
            ElevatedButton(
              onPressed: saveUser,
              child: Text(
                "Sign Up",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Colors.white),
              ),
            ),
          ],
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text(
            "Channelo",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ),
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(right: 28, left: 28, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 70),
              Text(
                "Create an Account",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 10),
              Text(
                "Sign Up to Dive In",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 23),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      selectSignUpMethod(0);
                    },
                    child: const Text("Email/Password"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      selectSignUpMethod(1);
                    },
                    child: const Text("Phone Number"),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  signUpMethod = 2;
                  await saveUser();
                },
                child: const Text("Sign up with Google"),
              ),
              Form(
                key: formKey,
                child: signupUI,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
