

import 'package:flutter/material.dart';

class CollectionPointScreen extends StatelessWidget {
  const CollectionPointScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[900], 
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text('Collection points of Anonas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      'https://via.placeholder.com/150', 
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Garbage Status:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        const Text(
                          'Full',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Needs to be emptied',
                          style: TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Date and Time',
                          style: TextStyle(color: Colors.white),
                        ),
                        const Text(
                          '2024-05-29 14:23:15',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

          
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Logs Notification',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                 
                  _buildLogsTable(),
                ],
              ),
            ),
            const SizedBox(height: 20),

          
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'User Report',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildUserReport('Raymart', 'Villasis, Pangasinan',
                      'Ang daming itoy amin, di nagalagay ng basura kasi hindi kinuha yung pag dumi.'),
                  _buildUserReport('Judge', 'Villasis, Pangasinan',
                      'Yung basura mabaho na. Hindi pa nakukuha.'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                      
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: const Text(
                        'GIVE FEEDBACK',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: const Text(
                        'REQUEST EMPTY',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLogsTable() {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(150),
        1: FixedColumnWidth(100),
        2: FlexColumnWidth(),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(
            color: Color(0xFFEFEFEF),
          ),
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Date and Time'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Image Source'),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Status'),
            ),
          ],
        ),
        _buildLogEntry('2024-05-29 8:35:15', 'View', 'Full / Needs to be Emptied'),
        _buildLogEntry('2024-05-29 8:35:15', 'View', 'Emptied'),
      ],
    );
  }

  TableRow _buildLogEntry(String date, String source, String status) {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(date),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            source,
            style: const TextStyle(color: Colors.blue),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(status),
        ),
      ],
    );
  }

  Widget _buildUserReport(String name, String location, String comment) {
    return Card(
      color: Colors.green[100],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$name - $location',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 4),
            Text(comment, style: const TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
