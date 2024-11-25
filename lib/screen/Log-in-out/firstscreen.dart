import 'package:capstoneapp/screen/Log-in-out/choose.dart';
import 'package:flutter/material.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img/home.png'), 
                fit: BoxFit.cover,
              ),
            ),
          ),
         
          Column(
            children: [
              const Spacer(),
              const Spacer(),
              Expanded(
                child: Center(
                  child:  Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
                  child: SizedBox(
                    width: 150, 
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_)=>const ChooseScreen()));
                      }, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A2A05), 
                        padding: const EdgeInsets.symmetric(vertical: 12.0), 
                      ),
                      child: const Text('Get Started', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ),
                ),
              ),
              const Spacer(), 
             
            ],
          ),
        ],
      ),
    );
  }
}
