import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:taskflow/config/config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class ManagerDetailScreen extends StatefulWidget {
  const ManagerDetailScreen({super.key});

  @override
  State<ManagerDetailScreen> createState() => _ManagerDetailScreenState();
}

class _ManagerDetailScreenState extends State<ManagerDetailScreen> {
  Map<String, dynamic> args = {};

  List<Map<String,dynamic>> developerList = [];
  String selectedDeveloper = '';

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateController = TextEditingController();

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey,
            width: 1,
          ),
        
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${args['task']['title']}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 10,),
            Text(
              '${args['task']['description']}',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 10,),
            Text(
              'Developer : ${args['task']['developer']}',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () async {
                // open pdf file on browser

                final url = '${Config.API_URL}/PDF/${args['task']['pdf']}';
                
                // open url on browser
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Could not open pdf file'),
                    ),
                  );
                }
              },
              child: Container(
                width: double.infinity,
                height: 50,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.file_copy,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 10,),
                    Text(
                      '${args['task']['pdf']}',
                    )
                  ],
              
                )
              ),
            ),
            const SizedBox(height: 10,),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // update task status

                      developerList.clear();
                      await _getDeveloperList();

                      titleController.text = args['task']['title'];
                      descriptionController.text = args['task']['description'];
                      dateController.text = args['task']['deadline'];
                      selectedDeveloper = args['task']['developer'];

                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Edit Task'),
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
                                  var url = '${Config.EDIT_TASK}/${args['task']['id']}';
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Task edited successfully'),
                                        duration: Duration(seconds: 2),
                                      )
                                    );
                                    args['task']['title'] = titleController.text;
                                    args['task']['description'] = descriptionController.text;
                                    args['task']['developer'] = selectedDeveloper;
                                    args['task']['deadline'] = dateController.text;
                                    setState(() {});
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
                                child: const Text('Edit'),
                              ),
                            ],
                          );
                        }
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF42a77e), // provide the color you want here
                    ),
                    child: Text('Edit', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10,),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // update task status
                      var uri = Uri.http(Config.API_URL.toString().replaceAll("http://", ""), '/api/revision/${args['task']['id']}');
                      http.get(uri).then((response) {
                        if(response.statusCode == 200) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Revision notification has been sent'),
                              duration: Duration(seconds: 2),
                            )
                          );
                          args['task']['status'] = 'revised';
                          setState(() {});
                        }
                        else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(jsonDecode(response.body)['message']),
                              duration: Duration(seconds: 2),
                            )
                          );
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFfbbc05), // provide the color you want here
                    ),
                    child: Text('Revise', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: ElevatedButton(
                    onPressed: () async{
                      var url = '${Config.API_URL}/api/delete/${args['task']['id']}';
                      var response = await http.get(Uri.parse(url));

                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Task deleted successfully'),
                          ),
                        );
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Could not delete task'),
                          ),
                        );
                      }
                      
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFdd2222), // provide the color you want here
                    ),
                    child: Text('Delete', style: TextStyle(color: Colors.white)),
                  )
                )
              ],
            )
           
          ],
        ),
      ),
    );
  }
}