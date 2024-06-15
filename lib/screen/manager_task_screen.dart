import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskflow/config/config.dart';
import 'package:http/http.dart' as http;

class ManagerTaskScreen extends StatefulWidget {
  const ManagerTaskScreen({super.key});

  @override
  State<ManagerTaskScreen> createState() => _ManagerTaskScreenState();
}

class _ManagerTaskScreenState extends State<ManagerTaskScreen> {
  Map<String, dynamic> args = {};

  List<Map<String, dynamic>> allTask = [];

  List<Map<String, dynamic>> developerList = [];

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  String selectedDeveloper = '';

  _getAllTask(int id) async {
    var url = Uri.http(Config.API_URL.toString().replaceAll("http://", ""), '/api/developer-task/$id', {
      'dev_username' : '-alltasks'
    });
    var response = await http.get(url);
    if(response.statusCode == 200) {
      setState(() {
        allTask = List<Map<String, dynamic>>.from(jsonDecode(response.body)['task']);
      });
    }
  }

  _getDeveloperList() async {
    var url = Uri.http(Config.API_URL.toString().replaceAll("http://", ""), '/api/all-developers');
    var response = await http.get(url);
    if(response.statusCode == 200) {
      setState(() {
        developerList = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      setState(() {});
      await _getAllTask(args['project_id']);
      await _getDeveloperList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(
          bottom: 20,
          left: 20,
          right: 20,
        ),
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          border: Border(
            top: BorderSide(color: Colors.grey, width: 1),
            bottom: BorderSide(color: Colors.grey, width: 1),
            left: BorderSide(color: Colors.grey, width: 1),
            right: BorderSide(color: Colors.grey, width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              args['project']['title'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
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
                  '${double.parse(args['project']['progress']).toInt()}%',
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
                widthFactor: double.parse(args['project']['progress']) / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(1000)
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20,),
            SizedBox(
              width: double.infinity,
              child: RefreshIndicator(
                onRefresh: () async {
                  await _getAllTask(args['project_id']);
                },
                child: ListView.builder(
                  itemCount: allTask.length + 1,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    if (index == allTask.length) {
                      return Container(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () async {
                            // popup input dialog
                            // show input dialog consist of title, description, dropdown of list developer, and datepicker for deadline
                            // send data to backend

                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Add Task'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: titleController,
                                        decoration: const InputDecoration(
                                          hintText: 'Title'
                                        ),
                                      ),
                                      const SizedBox(height: 10,),
                                      TextField(
                                        controller: descriptionController,
                                        decoration: const InputDecoration(
                                          hintText: 'Description'
                                        ),
                                      ),
                                      const SizedBox(height: 10,),
                                      DropdownButtonFormField(
                                        items: developerList.map((developer) {
                                          return DropdownMenuItem(
                                            child: Text(developer['username']), // Assuming developer is a String
                                            value: developer,
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedDeveloper = value!['username'];
                                          });
                                        },
                                        decoration: const InputDecoration(
                                          hintText: 'Developer'
                                        ),
                                      ),
                                      const SizedBox(height: 10,),
                                      TextField(
                                        controller: dateController,
                                        readOnly: true, // Prevent keyboard from appearing
                                        decoration: const InputDecoration(
                                          hintText: 'Select Deadline',
                                        ),
                                        onTap: () async {
                                          final DateTime? picked = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );
                                          if (picked != null) {
                                            dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async{
                                        var url = '${Config.ADD_TASK}/${args['project_id']}';
                                        print (url);
                                        var response = await http.post(
                                          Uri.parse(url),
                                          body: {
                                          'title': titleController.text,
                                          'description': descriptionController.text,
                                          'developer': selectedDeveloper,
                                          'deadline': dateController.text,
                                        });

                                        print(response.body);

                                        if(response.statusCode == 200) {
                                          

                                          Navigator.pop(context, true);
                                          _getAllTask(args['project_id']);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('New task added successfully'),
                                              duration: Duration(seconds: 2),
                                            )
                                          );
                                        }
                                        else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(jsonDecode(response.body)['message']),
                                              duration: Duration(seconds: 2),
                                            )
                                          );
                                        }
                                      },
                                      child: const Text('Adds'),
                                    ),
                                  ],
                                );
                              }
                            );
                                                        
                          },
                          child: const Text(
                            'Add Task',
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
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/manager-detail', arguments: {
                          'task': allTask[index],
                          'project': args['project']
                        });

                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFE8E8E8),
                          )
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              allTask[index]['title'],
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
                                color: allTask[index]['status'] == 1 ? Colors.green : allTask[index]['status'] == 2 ? Colors.yellow : Colors.red,
                                borderRadius: BorderRadius.circular(1000)
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            )
          ],
        )
      )
    );
  }
}