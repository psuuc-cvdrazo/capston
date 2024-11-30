
import 'package:capstoneapp/services/auth/loginornot.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class CollectorProfileScreen extends StatefulWidget {
  const CollectorProfileScreen({super.key});

  @override
  State<CollectorProfileScreen> createState() => _CollectorProfileScreenState();
}

class _CollectorProfileScreenState extends State<CollectorProfileScreen> {
  String firstName = "";
  String name = "";
  String email = "";
  String contactNumber = "";
  String password = "";

  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

void fetchUserProfile() async {
  try {
    final collector = Supabase.instance.client.auth.currentUser;

    if (collector != null) {
      final response = await supabase
          .from('collector')
          .select()
          .eq('uid', collector.id)
          .single(); 

      if (response != null) {
        final userData = response as Map<String, dynamic>;

        setState(() {
        
          name = userData['name'] ?? '';
          email = userData['email'] ?? '';
          contactNumber = userData['phone'] ?? '';
          password = userData['password'] ?? '';
        });
      } else {
        print('Error fetching collector profile');
      }
    }
  } catch (e) {
    print('Error fetching collector profile: $e');
  }
}




void signout() async {
  try {
    await supabase.auth.signOut();

    if (!mounted) return; 

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginNaba()),
      (Route<dynamic> route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Signed out successfully")),
    );
  } catch (e) {
    if (!mounted) return; 

    print('Error signing out: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error signing out: $e")),
    );
  }
}


  String maskPassword(String password) {
    return '*' * password.length;
  }

 
 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[200], // Subtle background
    body: Column(
      children: [
        SizedBox(height: 30,),
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture
               CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[400],
          child: ClipOval(
        child: Image.asset(
          'assets/img/logoprofile.jpg',
          width: 120, // Match the diameter (2 * radius)
          height: 120,
          fit: BoxFit.cover, // Ensures the image fits within the circle
        ),
          ),
        ),
        
                const SizedBox(height: 16),
                Text(
                  name, 
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email, // Dynamic email
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 30),
        
                // Profile Details Section
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildProfileDetail(Icons.person, ' Name', name),
                      const Divider(),
                    
                      _buildProfileDetail(Icons.phone, 'Phone Number', contactNumber),
                      const Divider(),
                      _buildProfileDetail(Icons.email, 'Email', email),
                      const Divider(),
                      _buildProfileDetail(Icons.lock, 'Password', maskPassword(password)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
        
                // Sign Out Button
                ElevatedButton.icon(
                  onPressed: () async {
                    bool? confirmSignOut = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Sign Out'),
                        content: const Text('Are you sure you want to sign out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    );
        
                    if (confirmSignOut == true) {
                      signout();
                    }
                  },
                  icon: const Icon(Icons.logout_outlined,color: Colors.white,),
                  label: const Text('Sign Out',style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

// Widget for each profile detail with an icon
Widget _buildProfileDetail(IconData icon, String title, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Icon(icon, color: const Color.fromARGB(255, 8, 117, 6), size: 24),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
}
