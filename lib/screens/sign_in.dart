import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:task3/screens/main_screen.dart';
import 'package:task3/screens/otp_screen.dart';
import 'package:task3/screens/sign_up.dart';
import 'package:task3/services/auth_service.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController usernameController = TextEditingController();
  AuthService authService = AuthService();
  final formKey = GlobalKey<FormState>();
  var email = '';
  var password = '';
  var signInMethod = 0;
  var phoneNumber = '';
  bool isLoading = false;
  String? error;
  Widget? signinUI;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    signinUI = _buildEmailPasswordUI();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    email = value;
    return null;
  }

  String? validatePass(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    password = value;
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    phoneNumber = value;
    return null;
  }

  Future<void> handleSignIn() async {
    error = null;
    if (signInMethod == 0 && formKey.currentState!.validate()) {
      var ret = await authService.findUserByEmailAndPassword(email, password);
      if (ret == null) {
        await authService.signInEP(email, password);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (ctx) => const MainScreen()));
      } else {
        setState(() {
          error = "Invalid email or password";
        });
      }
    } else if (signInMethod == 1 && formKey.currentState!.validate()) {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (phoneAuthCredential) {},
        verificationFailed: (error) {
          print("error");
        },
        codeSent: (verificationId, forceResendingToken) {
          setState(() {
            isLoading = false;
          });
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => OTPScreen(
                        verificationId: verificationId,
                        phoneNumber: phoneNumber,
                        username: '',
                        mode: "2",
                      )));
        },
        codeAutoRetrievalTimeout: (verificationId) {
          print("Auto Retireval timeout");
        },
      );
    } else if (signInMethod == 2) {
      await authService.findUserByGoogle(2);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => const MainScreen()));
    }
  }

  Widget _buildEmailPasswordUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
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
        error != null
            ? Text(
                error!,
                style: const TextStyle(color: Colors.red),
              )
            : const SizedBox(
                height: 0,
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
          validator: validatePass,
        ),
        const SizedBox(height: 35),
        ElevatedButton(
          onPressed: handleSignIn,
          child: Text(
            "Sign In",
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }

  void selectSignInMethod(int method) {
    setState(() {
      if (method == 0) {
        signinUI = _buildEmailPasswordUI();
        signInMethod = 0;
      } else if (method == 1) {
        signInMethod = 1;
        signinUI = Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
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
              onPressed: handleSignIn,
              child: Text(
                "Sign In",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Colors.white),
              ),
            ),
          ],
        );
      } else {
        signInMethod = 2;
        handleSignIn();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    void openSignUpModal() {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (ctx) => const SignUp()));
    }

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
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(right: 28, left: 28, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 150),
              Text(
                "Welcome to Channelo!",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Sign In to Continue",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 23),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Text(
                    "New to Channelo?",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  TextButton(
                    onPressed: openSignUpModal,
                    child: const Text(
                      'Create New Account',
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Color(0xFF5f4bce),
                          decoration: TextDecoration.underline),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      selectSignInMethod(0);
                    },
                    child: const Text("Email/Password"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      selectSignInMethod(1);
                    },
                    child: const Text("Phone Number"),
                  ),
                ],
              ),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        selectSignInMethod(2);
                      },
                      child: const Text("Google"),
                    ),
              Form(
                key: formKey,
                child: signinUI!,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
