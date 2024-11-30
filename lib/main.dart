import 'package:capstoneapp/screen/Log-in-out/firstscreen.dart';
import 'package:capstoneapp/screen/Log-in-out/registerpage.dart';
import 'package:capstoneapp/screen/collectorside/collectorHome.dart';
import 'package:capstoneapp/screen/userside/userHome.dart';
import 'package:capstoneapp/services/auth/authservice.dart';
import 'package:capstoneapp/services/auth/loginornot.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main()async {
    WidgetsFlutterBinding.ensureInitialized();
 await Supabase.initialize(
    url: 'https://uiciowpyxfawjvaddivu.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVpY2lvd3B5eGZhd2p2YWRkaXZ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjcxNDA0MjAsImV4cCI6MjA0MjcxNjQyMH0.NgoiBelYJ62ARlzvVkZUgHSipP7uPKC2lbcaJUcU14k',
  );
  runApp(
    ChangeNotifierProvider(
    create: (context) => AuthService(),
    child: const MyApp(),)
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690), 
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: navigatorKey, 
          title: 'Capstone',
          theme: ThemeData(
            
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
           
          // home: UserHomeScreen(),
          home: LoginNaba(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
