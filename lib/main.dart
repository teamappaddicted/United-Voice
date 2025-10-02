import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unitedvoice/MainHome.dart';
import 'package:unitedvoice/UnitedVoiceApp.dart';
import 'package:unitedvoice/main_Login.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb) {
    await Firebase.initializeApp(options: const FirebaseOptions(
apiKey: "AIzaSyDnQhpuJFDyqJ-grgKoK5HZ6RflHm4V3sY",
    authDomain: "unitedvoice-56240.firebaseapp.com",
    projectId: "unitedvoice-56240",
    storageBucket: "unitedvoice-56240.firebasestorage.app",
    messagingSenderId: "475736493042",
    appId: "1:475736493042:web:b3253444639ec6f979b96b"));

  }else{
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
     home: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), 
      builder: (BuildContext context,AsyncSnapshot snapshot){
        if(snapshot.hasError){
          return Text(snapshot.error.toString());
        }
        if(snapshot.connectionState==ConnectionState.active){
          if(snapshot.data==null){
            return const main_Login();
          }else{
            return const UnitedVoiceApp();
          }
        }
        return Center(child: CircularProgressIndicator(),);
      })
      
    );
  }
}


