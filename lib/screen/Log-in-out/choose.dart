import 'package:capstoneapp/screen/Log-in-out/collectorlogin.dart';
import 'package:capstoneapp/screen/Log-in-out/userLogin.dart';
import 'package:capstoneapp/screen/Log-in-out/registerpage.dart';
import 'package:flutter/material.dart';

class ChooseScreen extends StatelessWidget {
  const ChooseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img/blank.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

      
          Center(
            child: Container(
              width: 300,
              height: 400, 
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF0A2A05).withOpacity(0.8),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.7),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 
                  Image.asset(
                    'assets/img/ROBOT.png',
                    height: 150,
                    width: 150,
                  ),
                  const SizedBox(height: 20),

                 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                     
                      ElevatedButton(
                      onPressed: () {
                       Navigator.push(context, MaterialPageRoute(builder: (_)=>LoginScreen(onTap: () {  },)));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8DA861), 
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10), 
                      ),
                      child: const Text('   User Login   ', style: TextStyle(color: Colors.white)),
                    ),
                     
                     ElevatedButton(
                      onPressed: () {
                                               Navigator.push(context, MaterialPageRoute(builder: (_)=>CollectorLogin(onTap: () {  },)));

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8DA861),
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10), 
                      ),
                      child: const Text('Collector Login', style: TextStyle(color: Colors.white)),
                    ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
