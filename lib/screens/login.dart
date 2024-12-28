import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teafarm_pro/utils/auth.dart';
import '../utils/text.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obsureText = true;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Ensure the email and password fields are not empty
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Empty fields'),
          content: const TextUtil(
            text: 'Please fill in all fields',
            color: Colors.redAccent,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final response = await AuthService().login(email, password);

    setState(() {
      _isLoading = false;
    });

    if (response.success) {
      // Navigate to the home screen
      Navigator.pushNamed(context, '/home');
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Login failed'),
            content: TextUtil(
              text: response.message,
              size: 20,
              color: Colors.redAccent,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const TextUtil(
                  color: Colors.blueAccent,
                  text: 'OK',
                  size: 20,
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  void _toggleObsureText() {
    setState(() {
      _obsureText = !_obsureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg1.jpeg'),
            fit: BoxFit.fill,
          ),
        ),
        alignment: Alignment.center,
        child: Container(
          height: 400,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(15),
            color: Colors.blueAccent.withAlpha(100),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaY: 5, sigmaX: 5),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Center(
                        child: TextUtil(
                      text: "Login",
                      weight: true,
                      size: 30,
                    )),
                    const Spacer(),
                    TextUtil(
                      text: "Email",
                    ),
                    Container(
                      height: 35,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.white),
                        ),
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(''),
                        ],
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          suffixIcon: Icon(
                            Icons.mail,
                            color: Colors.white,
                          ),
                          fillColor: Colors.white,
                          border: InputBorder.none,
                        ),
                        autovalidateMode: AutovalidateMode.onUnfocus,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          // Email regex validation
                          final emailRegex =
                              RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ),
                    const Spacer(),
                    TextUtil(
                      text: "Password",
                    ),
                    Container(
                      height: 35,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.white),
                        ),
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obsureText,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: _toggleObsureText,
                            icon: _obsureText
                                ? Icon(Icons.visibility)
                                : Icon(Icons.visibility_off),
                            color: Colors.white,
                          ),
                          fillColor: Colors.white,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : GestureDetector(
                            onTap: _handleLogin,
                            child: Container(
                              height: 40,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30)),
                              alignment: Alignment.center,
                              child: TextUtil(
                                text: "Log In",
                                color: Colors.black,
                              ),
                            ),
                          ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextUtil(
                          text: "Don't have an account?",
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: TextUtil(
                            text: " Register",
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
