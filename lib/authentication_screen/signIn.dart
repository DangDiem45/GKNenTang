// ignore_for_file: unused_field

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:giuaki/authentication_screen/signUp.dart';
import 'package:giuaki/views/homeScreen.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});
  

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  // ignore: prefer_final_fields
  bool _isObscured = true;

  userSignIn(String email, String password) async {
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Sign In Successfully',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                
              )
            ) 
            )
        );
        Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    }on FirebaseAuthException catch (e){
      if(e.code == 'user-not-found'){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orange,
            content: Text(
              'No user found with this email!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white
              ),
            ),
          )
          );
        } else if(e.code == 'wrong-password'){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Password you entered is wrong',
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
                    "Sign In",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                    controller: emailController,
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return 'Enter register email';
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
                    obscureText: _isObscured,
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return 'Enter your password';
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
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscured ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: (){
                            setState(() {
                              _isObscured = !_isObscured;
                            });
                          },
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
                            userSignIn(emailController.text, passwordController.text);
                          }
                        },
                        child: Text(
                          "Sign In",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.white
                          ),
                        ),
                      ),
                    ),
                    // SizedBox(height: 10,),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   children: [
                    //     TextButton(
                    //       onPressed: (){
                    //         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Signup()));
                    //       },
                    //       child: Text(
                    //         'Forgot Password',
                    //         style: TextStyle(
                    //           color: const Color.fromARGB(255, 23, 2, 68),
                    //           fontWeight: FontWeight.bold,
                    //           fontSize: 15
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                      child: Row(
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: const Color.fromARGB(255, 23, 2, 68)
                            ),
                          ),
                                  
                          TextButton(
                            onPressed: (){
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Signup()));
                            },
                            
                            child: Text(
                              "Go to Sign Up",
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