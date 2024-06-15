import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:taskflow/config/config.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:taskflow/global.dart';
import 'package:intl/intl.dart';

class DeveloperTaskScreen extends StatefulWidget {
  const DeveloperTaskScreen({super.key});

  @override
  State<DeveloperTaskScreen> createState() => _DeveloperTaskScreenState();
}

class _DeveloperTaskScreenState extends State<DeveloperTaskScreen> {
  Map<String, dynamic> args = {};
  TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int _current = 0;

  List<Map<String, dynamic>> developerTask = [];
  List<Map<String, dynamic>> comment = [];

  String? pickedFileName;
  FilePickerResult? selectedFile;

  bool onUpload = false;

  Future<void> _pickPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      setState(() {
        pickedFileName = file.name;
        selectedFile = result;
      });
    } else {
      // User canceled the picker

    }
  }

  Future<void> _getDeveloperTask(int projectId, String developerName) async {
    var url = Uri.http(Config.API_URL.toString().replaceAll("http://", ""), '/api/developer-task/$projectId', {
      'dev_username': developerName,
    });
    var response = await http.get(url);

    if(response.statusCode == 200) {
      setState(() {
        developerTask = List<Map<String, dynamic>>.from(jsonDecode(response.body)['task']);
        comment = List<Map<String, dynamic>>.from(jsonDecode(response.body)['comment']);
      });
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    }

  }
  
  String _formatDate(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    DateTime now = DateTime.now();

    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      // If the date is today, return the hour
      return DateFormat.Hm().format(date);
    } else {
      // If the date is not today, return the month and day
      return DateFormat.MMMd().add_Hm().format(date);
    }
  }

  

  @override
  void initState() {

    
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      setState(() {});
      await _getDeveloperTask(args['project_id'], args['dev_username']);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      
      appBar: AppBar(
        // show back button only
        automaticallyImplyLeading: true,
        
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: [
                CarouselSlider(
                  items: developerTask.map((task) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${task['title']}',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  Spacer(),
                                  task['status'] == 2 ?
                                  Text('Need Revision',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontFamily: 'Poppins',
                                      color: Color(0xffFBBC05),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ):
                                  SizedBox(),
                                ],
                              ),
                              const SizedBox(height: 10.0),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Text(
                                    '${task['description']}',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                )
                              ),
                              const SizedBox(height: 10.0),
                              task['status'] == 1 ?
                              SizedBox(
                                width: double.infinity,
                                child: Text(
                                  'This Task has been Marked as Done',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontFamily: 'Poppins',
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                              :
                              Column(
                                children: [
            
                                  Container(
                                width: MediaQuery.of(context).size.width,
                                height: 50,
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
            
                                    Expanded(
                                          child: Text(
                                            pickedFileName ?? 'No file selected',
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              fontFamily: 'Poppins',
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        
                                        pickedFileName == null ?
                                        ElevatedButton(
                                          onPressed: _pickPdfFile,
                                          child: Text('Select File'),
                                        )
                                        :
                                        GestureDetector(
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onTap: () {
                                            setState(() {
                                              pickedFileName = null;
                                              selectedFile = null;
                                            });
                                          },
                                        )
                                      ],
                                    )
                                  ),
                                  const SizedBox(height: 10.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 190,
                                        height: 35,
                                        child: ElevatedButton(
                                          onPressed: () async {
            
                                            if (selectedFile == null) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Please select a file'),
                                                ),
                                              );
                                              return;
                                            }
            
                                            var url = Config.DEVELOPER_TASK_URL + '/${task['id']}';
                                            var request = http.MultipartRequest('POST', Uri.parse(url));
                                            request.files.add(
                                              await http.MultipartFile.fromPath(
                                                'file',
                                                selectedFile!.files.single.path!,
                                                contentType: MediaType('application', 'pdf'),
                                              ),
                                            );
                                            setState(() {
                                              onUpload = true;
                                            });
                                            var response = await request.send();
                                            if(response.statusCode == 200) {
                                              _getDeveloperTask(args['project_id'], args['dev_username']);
                                              setState(() {
                                                onUpload = false;
                                                pickedFileName = null;
                                                selectedFile = null;
                                              });
                                            }
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                'Mark as Done',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'Poppins',
                                                  color: Colors.white
                                                ),
                                              ),
                                              const SizedBox(width: 10,),
                                              onUpload ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              ) : const SizedBox(),
                                            ],
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF42A77E),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10)
                                            )
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              )
                            ],
                          )
                        );
                      },
                    );
                  }).toList(),
                  options: CarouselOptions(
                    height: 320.0,
                    enlargeCenterPage: true,
                    autoPlay: false,
                    pageSnapping: true,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                        selectedFile = null;
                        pickedFileName = null;
                      });
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: developerTask.map((task) {
                    int index = developerTask.indexOf(task);
                    return Container(
                      width: 8.0,
                      height: 8.0,
                      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _current == index ? Color.fromRGBO(0, 0, 0, 0.9) : Color.fromRGBO(0, 0, 0, 0.4),
                      ),
                    );
                  }).toList(),
                ),
            
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.44,
                  margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                  padding: EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: Colors.grey
                    )
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Chat with Developers',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Expanded( // Wrap ListView.builder in Expanded
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: comment.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${comment[index]['user']['username']}',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      const SizedBox(width: 10.0),
                                      Text(
                                        _formatDate(comment[index]['created_at']),
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    '${comment[index]['comment']}',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 10.0),
                      TextField(
                        controller: _chatController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                          hintText: 'Type your message here',
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins'
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 1
                            )
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () async {
                              if(_chatController.text.isEmpty) {
                                return;
                              }
                              var url = Config.COMMENT + '/${args['project_id']}';
                              var response = await http.post(
                                Uri.parse(url),
                                body: {
                                  'comment': _chatController.text,
                                  'user_id': Global.loginResponse!['user']['id'].toString(),
                                }
                              );
                              if(response.statusCode == 200) {
                                _getDeveloperTask(args['project_id'], args['dev_username']);
                                _chatController.clear();
                              }
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      )
    );
  }
}