import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:giuaki/authentication_screen/signIn.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  try {
    await Supabase.initialize(
      url: 'https://dehmtcxobdafmpmwqgdj.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRlaG10Y3hvYmRhZm1wbXdxZ2RqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI0ODU5NDIsImV4cCI6MjA1ODA2MTk0Mn0.8tiOZGf9mPy-m6KUpiuUryOf6cC6mUB-tfq-JXVGe7g',
    );
    print('Supabase initialized successfully');
  } catch (e) {
    print('Error initializing Supabase: $e');
    return; // Dừng nếu Supabase lỗi
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
      title: 'Flutter Demo',
      home: const SignIn(),
    );
  }
}

 