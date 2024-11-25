import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LogScreen extends StatefulWidget {
 

  LogScreen({Key? key}) : super(key: key);

  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> feedbackList = [];

  @override
  void initState() {
    super.initState();
    fetchFeedback().then((data) {
      setState(() {
        feedbackList = data;
      });
    }).catchError((e) {
      print('Failed to load feedback: $e');
    });
  }

  Future<List<dynamic>> fetchFeedback() async {
    try {
   final response = await supabase
    .from('user_feedback')
    .select('id, created_at, username, feedback, img_fb, status, email') 
    .order('created_at', ascending: false);


      if (response != null) {
        return response as List<dynamic>;
      } else {
        throw Exception('No feedback found.');
      }
    } catch (e) {
      print('Error fetching feedback: $e');
      return [];
    }
  }

  void _showStatusSelectionDialog(String currentStatus, Map<String, dynamic> feedback) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Select Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['FULL', 'EMPTIED', 'Unknown status'].map((status) {
            return ListTile(
              title: Text(status),
              onTap: () {
                
                _updateFeedbackStatus(feedback, status);
                Navigator.pop(context); 
              },
              selected: status == currentStatus,
            );
          }).toList(),
        ),
      );
    },
  );
}
Future<void> _updateFeedbackStatus(Map<String, dynamic> feedback, String newStatus) async {
  try {
  
    setState(() {
      feedback['status'] = newStatus; 
    });

  
    final response = await supabase
        .from('user_feedback')
        .update({'status': newStatus}) 
        .eq('id', feedback['id']); 

    if (response.error != null) {
      throw Exception('Failed to update status: ${response.error!.message}');
    }
  } catch (e) {
    print('Error updating feedback status: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(style: TextStyle(color: Colors.white),'Collection points of All Barangay'),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 47, 61, 2),
       
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color(0xFF1B3313),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        'assets/img/logspin.gif',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Collector Name:',
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'username',
                            style: TextStyle(
                              fontSize: 22.0,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Collector',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.green.shade100,
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            'Date and Time:',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '2024-05-29   14:23:15',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.0),
              Text(
                'Logs Notification',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFEDF0DC),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'DATE AND TIME',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'IMAGE',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'STATUS',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      children: feedbackList.map((feedback) {
                        return _buildLogRow(
                          feedback['created_at'] ?? 'Unknown date',
                          'View',
                          feedback['status'] ?? 'Unknown status',
                          feedback['is_full'] ?? false,
                          feedback,
                        );
                      }).toList(),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  String _formatDateTime(String dateTimeStr) {
    final DateTime dateTime = DateTime.parse(dateTimeStr);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  Widget _buildLogRow(String dateTime, String imageSource, String status, bool isFull, Map<String, dynamic> feedback) {
  IconData icon;
  Color iconColor;

  if (status == 'FULL') {
    icon = Icons.warning;
    iconColor = Colors.red;
  } else if (status == 'EMPTIED') {
    icon = Icons.check_circle;
    iconColor = Colors.green;
  } else {
    icon = Icons.error;
    iconColor = Colors.grey;
  }

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            _formatDateTime(dateTime),
            style: TextStyle(fontSize: 14.0, color: Colors.black),
          ),
        ),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => _buildFeedbackDialog(feedback),
              );
            },
            child: Text(
              imageSource,
              style: TextStyle(fontSize: 14.0, color: Colors.blue),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () {
              _showStatusSelectionDialog(status, feedback); 
            },
            child: Column(
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 15.0,
                ),
                SizedBox(width: 4.0),
                Text(
                  status,
                  style: TextStyle(fontSize: 9.0, color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}


  Widget _buildFeedbackDialog(Map<String, dynamic> feedback) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(16.0),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (feedback['img_fb'] != null)
                  Image.network(
                    feedback['img_fb'],
                    fit: BoxFit.cover,
                    height: 200,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: Image.asset(
                          'assets/img/logspin.gif',
                          height: 300,
                          width: 300,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/img/logspin.gif',
                        height: 200,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.0),
                Text(
                  feedback['feedback'] ?? 'No feedback provided',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Reported by: ${feedback['username'] ?? 'Unknown'}',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Email: ${feedback['email'] ?? 'No email provided'}',
                  style: TextStyle(fontSize: 14.0, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    );
  }
}
