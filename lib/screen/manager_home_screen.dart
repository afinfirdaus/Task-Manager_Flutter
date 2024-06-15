import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:taskflow/config/config.dart';
import 'package:taskflow/global.dart';
import 'package:http/http.dart' as http;

class ManagerHomeScreen extends StatefulWidget {
  const ManagerHomeScreen({super.key});

  @override
  State<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends State<ManagerHomeScreen> {
  String username = '';

  List<Map<String, dynamic>> allProject = [];

  _getAllProject() async {
    var url = Uri.http(Config.API_URL.toString().replaceAll("http://", ""), '/api/developer-task', {
      'developer_name': '-allprojects'
    });
    var response = await http.get(url);

    if(response.statusCode == 200) {
      setState(() {
        allProject = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      });
    }
  }

  @override
  void initState() {
    username = Global.loginResponse!['user']['username'];
    _getAllProject();
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
                          image: AssetImage('assets/Manager.png'),
                          width: 20,
                          height: 20,
                        )
                      )
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20,),
              DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(
                          text: 'To Do',
                        ),
                        Tab(
                          text: 'Done',
                        )
                      ],
                    ),
                    const SizedBox(height: 20,),
                    Container(
                      height: MediaQuery.of(context).size.height - 200,
                      child: TabBarView(
                        children: [
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                _getAllProject();
                              },
                              child: ListView.builder(
                                itemCount: allProject.where((project) => project['progress'].toString() != '100.00').length + 1,
                                itemBuilder: (context, index) {
                                  
                                  if (index == allProject.where((project) => project['progress'].toString() != '100.00').length) {
                                    return Container(
                                      width: double.infinity,
                                      height: 45,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          // popup input dialog
                                          var title = '';
                                          await showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text('Add Project'),
                                                content: TextField(
                                                  onChanged: (value) {
                                                    title = value;
                                                  },
                                                  decoration: const InputDecoration(
                                                    hintText: 'Project Title'
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      var url = Config.STORE_PROJECT;

                                                      var response = await http.post(
                                                        Uri.parse(url),                                                       
                                                        body: {
                                                        'title': title
                                                      });

                                                      if(response.statusCode == 200) {
                                                        _getAllProject();
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                    child: const Text('Add'),
                                                  )
                                                ],
                                              );
                                            }
                                          );                                         
                                          
                                        },
                                        child: const Text(
                                          'Add Project',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Poppins',
                                            color: Colors.white
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF42A77E),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10)
                                          )
                                        ),
                                      ),
                                    );
                                  }
                                  else {
                                    var project = allProject.where((project) => project['progress'].toString() != '100.00').toList()[index];
                                    return GestureDetector(
                                      onTap:() {
                                        Navigator.pushNamed(context, '/manager-task', arguments: {
                                          'project_id': project['id'],
                                          'project': project
                                        });
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 20),
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: index % 2 == 0 ? Color(0xffe3f1ff) : Color(0xffe6fff3),
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.1),
                                              spreadRadius: 1,
                                              blurRadius: 10,
                                              offset: const Offset(0, 3)
                                            )
                                          ]
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              project['title'],
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Poppins'
                                              ),
                                            ),
                                            const SizedBox(height: 10,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Progress',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: 'Poppins'
                                                  ),
                                                ),
                                                const SizedBox(width: 10,),
                                                Text(
                                                  '${double.parse(project['progress']).toInt()}%',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: 'Poppins'
                                                  ),
                                                )
                                              ],
                                            ),
                                            const SizedBox(height: 10,),
                                            // Progress Bar
                                            Container(
                                              width: double.infinity,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(1000)
                                              ),
                                              child: FractionallySizedBox(
                                                alignment: Alignment.centerLeft,
                                                widthFactor: double.parse(project['progress']) / 100,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius: BorderRadius.circular(1000)
                                                  ),
                                                ),
                                              ),
                                            ),
                                      
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  
                                }
                              ),
                            ),
                          ),
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                _getAllProject();
                              },
                              child: ListView.builder(
                                itemCount: allProject.where((project) => project['progress'].toString() == '100.00').length,
                                itemBuilder: (context, index) {
                                  
                                  if (index == allProject.where((project) => project['progress'].toString() == '100.00').length) {
                                    return Container(
                                      width: double.infinity,
                                      height: 45,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          // popup input dialog
                                          var title = '';
                                          await showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text('Add Project'),
                                                content: TextField(
                                                  onChanged: (value) {
                                                    title = value;
                                                  },
                                                  decoration: const InputDecoration(
                                                    hintText: 'Project Title'
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      var url = Config.STORE_PROJECT;

                                                      var response = await http.post(
                                                        Uri.parse(url),                                                       
                                                        body: {
                                                        'title': title
                                                      });

                                                      if(response.statusCode == 200) {
                                                        _getAllProject();
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                    child: const Text('Add'),
                                                  )
                                                ],
                                              );
                                            }
                                          );                                         
                                          
                                        },
                                        child: const Text(
                                          'Add Project',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Poppins',
                                            color: Colors.white
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF42A77E),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10)
                                          )
                                        ),
                                      ),
                                    );
                                  }
                                  else {
                                    var project = allProject.where((project) => project['progress'].toString() == '100.00').toList()[index];
                                    return GestureDetector(
                                      onTap:() {
                                        Navigator.pushNamed(context, '/manager-task', arguments: {
                                          'project_id': project['id'],
                                          'project': project
                                        });
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 20),
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: index % 2 == 0 ? Color(0xffe3f1ff) : Color(0xffe6fff3),
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.1),
                                              spreadRadius: 1,
                                              blurRadius: 10,
                                              offset: const Offset(0, 3)
                                            )
                                          ]
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              project['title'],
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Poppins'
                                              ),
                                            ),
                                            const SizedBox(height: 10,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Progress',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: 'Poppins'
                                                  ),
                                                ),
                                                const SizedBox(width: 10,),
                                                Text(
                                                  '${double.parse(project['progress']).toInt()}%',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: 'Poppins'
                                                  ),
                                                )
                                              ],
                                            ),
                                            const SizedBox(height: 10,),
                                            // Progress Bar
                                            Container(
                                              width: double.infinity,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(1000)
                                              ),
                                              child: FractionallySizedBox(
                                                alignment: Alignment.centerLeft,
                                                widthFactor: double.parse(project['progress']) / 100,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius: BorderRadius.circular(1000)
                                                  ),
                                                ),
                                              ),
                                            ),
                                      
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  
                                }
                              ),
                            ),
                          ),
                          
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        )
      )
    );
  }
}