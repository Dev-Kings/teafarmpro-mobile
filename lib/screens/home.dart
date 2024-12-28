import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:teafarm_pro/utils/auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg3.jpeg'),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome, xx',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        // Show circular progress loading indicator
                        showDialog(
                          context: context,
                          builder: (context) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        );
                        // Implement logout functionality, call it from the AuthService
                        final response = await AuthService().logout();

                        if (response.success) {
                          // Navigate to login screen
                          Navigator.pushReplacementNamed(context, '/login');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(response.message),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(response.message),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.all(10),
                        minimumSize: const Size(100, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        shadowColor: Colors.black,
                        elevation: 2,
                      ),
                      child: const Text('Logout'),
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
