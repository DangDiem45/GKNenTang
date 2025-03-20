// ignore_for_file: file_names, unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:giuaki/authentication_screen/signIn.dart';
import 'package:giuaki/views/HomeScreen.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  registration(String name, String email, String? password) async{
    if(password != null){
      try{
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Registered Successfully',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white
              )
            ) 
            )
        );
        Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      }on FirebaseException catch(e){
        if(e.code == 'weak-password'){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.grey,
              content: Text(
                "Enter strong password!",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white
                ),
                ),
            )
          );
        }else if(e.code == 'email-already-in-use'){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.orange,
              content: Text(
                "User already exits!",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white
                ),
              ),
            )
          );
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            'assets/image/signbg1.png',
            fit: BoxFit.fill),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: formKey,
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                    controller: nameController,
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return 'Please enter name!';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.6),
                    hintText: "Enter Your Name",
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0), 
                        borderSide: BorderSide.none
                        )
                      ),
                    ),
                    SizedBox(height: 20,),
                  TextFormField(
                    controller: emailController,
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return 'Please enter email-id!';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.6),
                    hintText: "Enter Your Email",
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0), 
                        borderSide: BorderSide.none
                        )
                      ),
                    ),
                    SizedBox(height: 20.0,),
                    TextFormField(
                    controller: passwordController,
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return 'Please enter password!';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.6),
                    hintText: "Enter Password",
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0), 
                        borderSide: BorderSide.none
                        )
                      ),
                    ),
                    SizedBox(height: 40,),
                    SizedBox(
                      width: double.infinity,
                      height: 50.0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)
                          ),
                          backgroundColor: Colors.blue[700]
                        ),
                        onPressed: (){
                          if(formKey.currentState!.validate()){
                            registration(nameController.text, emailController.text, passwordController.text);
                          }
                        },
                        child: Text(
                          "Create New Account",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.white
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                      child: Row(
                        children: [
                          Text(
                            'Already have an account?',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 23, 2, 68)
                            ),
                          ),
                                  
                          TextButton(
                            onPressed: (){
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> SignIn()));
                            },
                            
                            child: Text(
                              "Go to Login",
                              style: TextStyle(
                                color: const Color.fromARGB(255, 23, 2, 68),
                                fontWeight: FontWeight.bold,
                                fontSize: 15
                              ),
                              )
                            )
                        ],
                      ),
                    ),
                    
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}