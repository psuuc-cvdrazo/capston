import 'package:capstoneapp/screen/Log-in-out/userLogin.dart';
import 'package:capstoneapp/screen/Log-in-out/registerpage.dart';
import 'package:flutter/material.dart';


class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
 bool showLoginScreen = true ;
 void togglescreen(){
setState(() {
  showLoginScreen = !showLoginScreen;
});
 }

  @override
  Widget build(BuildContext context) {
   if(showLoginScreen){
    return LoginScreen(onTap: togglescreen,);
   }
   else{
    return RegisterScreen(onTap:togglescreen);
   }
  }
}