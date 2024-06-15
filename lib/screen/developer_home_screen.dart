import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:taskflow/config/config.dart';
import 'package:taskflow/global.dart';
import 'package:http/http.dart' as http;

class DeveloperHomeScreen extends StatefulWidget {
  const DeveloperHomeScreen({super.key});

  @override
  State<DeveloperHomeScreen> createState() => _DeveloperHomeScreenState();
}

class _DeveloperHomeScreenState extends State<DeveloperHomeScreen> {

  String username = '';

  List<Map<String, dynamic>> developerTask = [];

  _getDeveloperTask() async {
    var url = Uri.http(Config.API_URL.toString().replaceAll("http://", ""), '/api/developer-task', {
      'developer_name': Global.loginResponse!['user']['username']
    });
    var response = await http.get(url);

    if(response.statusCode == 200) {
      setState(() {
        developerTask = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      });
    }
  }

  @override
  void initState() {
    
    username = Global.loginResponse!['user']['username'];

    _getDeveloperTask();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20,),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Text(
                      'Hello, $username',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins'
                      ),
                      
                    ),

                    GestureDetector(
                      onTap: () {
                        // Show Dialog Box
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Logout'),
                              content: const Text('Are you sure you want to logout?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('No'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(context, '/login');
                                  },
                                  child: const Text('Yes'),
                                )
                              ],
                            );
                          }
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(1000)
                        ),
                        child: const Image(
                          image: AssetImage('assets/Developer.png'),
                          width: 20,
                          height: 20,
                        )
                      )
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20,),
              const Text(
                'My Task',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins'
                ),
              ),
              const SizedBox(height: 20,),
              // ElevatedButton(onPressed: () {_getDeveloperTask();}, child: Text('p')),
              // create a list view that can be refreshed by pulling down
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _getDeveloperTask();
                  },
                  child: ListView.builder(
                    itemCount: developerTask.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/dev-task', arguments: {
                            'project_id': developerTask[index]['id'],
                            'dev_username' : Global.loginResponse!['user']['username']
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Color(0xFFE8E8E8),
                            )
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                developerTask[index]['title'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins'
                                ),
                              ),
                        
                              const SizedBox(width: 10,),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: developerTask[index]['progress'].toString() == '100.00' ? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(1000)
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          )
        ),
      )
    );
  }
}