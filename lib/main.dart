import 'package:Xolve/SplashScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDnQhpuJFDyqJ-grgKoK5HZ6RflHm4V3sY",
        authDomain: "unitedvoice-56240.firebaseapp.com",
        projectId: "unitedvoice-56240",
        storageBucket: "unitedvoice-56240.appspot.com",
        messagingSenderId: "475736493042",
        appId: "1:475736493042:web:b3253444639ec6f979b96b",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Xolve', // ✅ Updated name
      theme: ThemeData.dark(),
      home: const SplashScreen(), // ✅ Your custom splash
    
    );
  }
}
