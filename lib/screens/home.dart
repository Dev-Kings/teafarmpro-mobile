import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:teafarm_pro/main.dart';
import 'package:teafarm_pro/utils/api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? username;

  @override
  void initState() {
    fetchName().then((value) {
      setState(() {
        username = value;
      });
    });
    super.initState();
  }

  fetchName() async {
    final response = await secureStorage.read(key: 'username') ?? '';
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade300,
        automaticallyImplyLeading: false,
        title: const Text('Home'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              bool confirmLogout = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Logout'),
                        content: Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: Text('No'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: Text('Yes'),
                          ),
                        ],
                      );
                    },
                  ) ??
                  false;

              if (!confirmLogout) return;

              final response = await APIService().logout();

              if (response.success) {
                Navigator.pushReplacementNamed(context, '/login');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(response.message),
                  ),
                );
              } else {
                if (response.message == 'Invalid token') {
                  Navigator.pushReplacementNamed(context, '/login');
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(response.message),
                  ),
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg3.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Container(
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
                      Text(
                        'Welcome, $username',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Labour Types Card
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/labours');
                        },
                        child: Card(
                          color: Colors.white.withOpacity(0.7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            title: Text('Labour Types'),
                            subtitle: Text('Number of labour types: 5'),
                            trailing: Icon(Icons.group),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Users Card
                      Card(
                        color: Colors.white.withOpacity(0.7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text('Users'),
                          subtitle: Text('Total Users: 120'),
                          trailing: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Monthly Production Card
                      Card(
                        color: Colors.white.withOpacity(0.7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text('Monthly Production'),
                          subtitle: Text('Production: 5000 kg'),
                          trailing: Icon(Icons.access_time),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Weekly Production Card
                      Card(
                        color: Colors.white.withOpacity(0.7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text('Weekly Production'),
                          subtitle: Text('Production: 1200 kg'),
                          trailing: Icon(Icons.access_alarm),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
