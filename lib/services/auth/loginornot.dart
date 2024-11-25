import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:capstoneapp/screen/collectorside/collectorHome.dart';
import 'package:capstoneapp/screen/userside/userHome.dart';
import 'package:capstoneapp/screen/Log-in-out/firstscreen.dart';

class LoginNaba extends StatelessWidget {
  const LoginNaba({super.key});

  Future<String?> getUserRole() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      final userProfileResponse = await supabase
          .from('useraccount')
          .select()
          .eq('uid', user.id) 
          .single();

      if (userProfileResponse.isNotEmpty) {
        return 'useraccount';
      }

      final collectorProfileResponse = await supabase
          .from('collector')
          .select()
          .eq('uid', user.id)
          .single();

      if (collectorProfileResponse.isNotEmpty) {
        return 'collector';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data?.session != null) {
            return FutureBuilder<String?>(
              future: getUserRole(),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (roleSnapshot.hasData) {
                  String? role = roleSnapshot.data;
                  if (role == 'collector') {
                    return const HomeScreen();
                  } else if (role == 'useraccount') {
                    return const UserHomeScreen(); 
                  } else {
                    return const Center(child: Text('Role not recognized'));
                  }
                } else {
                  return const Center(child: Text('Error fetching role'));
                }
              },
            );
          } else {
            return const FirstScreen();
          }
        },
      ),
    );
  }
}
