import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:tfg/api_connection/api_connection.dart';
import 'package:tfg/home_screen.dart';
import 'package:http/http.dart' as http;

// ignore: use_key_in_widget_constructors
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  
  var formKey = GlobalKey<FormState>();
  var dniController = TextEditingController();
  var passwordController = TextEditingController();
  var isObscure = true.obs;
  final storage = FlutterSecureStorage();

  Future<void> login() async {
    if (formKey.currentState?.validate() ?? false) {
      try {
        await loginRequest(dniController.text, passwordController.text);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> loginRequest(String dni, String password) async {
    final url = Uri.parse(API.loginUrl);
    String encodedBody = 'dni=$dni&password=$password';
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: encodedBody,
    );

    if (response.statusCode == 200) {
      //Save jwtToken
      final jsonResponse = jsonDecode(response.body);
      await storage.write(key: 'auth_token', value:  jsonResponse['token']);
      await storage.write(key: 'client_id', value: jsonResponse['client_id']);
      // Get to the next screen
      Get.offAll(HomeScreen());
    } else {
      // If the request was not successful, throw an exception or handle the error accordingly
      throw Exception('Error: ${response.body}');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black ,
      
      appBar: AppBar(
        title: const Text('Reserva Cultura'),
        backgroundColor: Colors.purple,
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [

                  //Login screen header
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 285,
                    child: Image.asset(
                      'images/login.jpg',
                    ),
                  ),

                  //Login sign in form
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.all(
                          Radius.circular(60),
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, -3)
                          )
                        ]
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 8.0),
                        child: Column(
                          children: [
                            
                            //dni-password-login button
                            Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  
                                  //dni
                                  TextFormField(
                                    controller: dniController,
                                    validator: (val) => val == "" ? "Escriba un dni" : null,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(
                                        Icons.card_membership,
                                        color: Colors.black,
                                      ),
                                      hintText: "dni...",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                        borderSide: const BorderSide(
                                          color: Colors.white60,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                        borderSide: const BorderSide(
                                          color: Colors.white60,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                        borderSide: const BorderSide(
                                          color: Colors.white60,
                                        ),
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                        borderSide: const BorderSide(
                                          color: Colors.white60,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 6,
                                      ),
                                      fillColor: Colors.white,
                                      filled: true,
                                    ),
                                  ),

                                  SizedBox(height: 18,),

                                  //password
                                  Obx(
                                    () => TextFormField(
                                      controller: passwordController,
                                      obscureText: isObscure.value,
                                      validator: (val) => val == "" ? "Escriba una contraseña" : null,
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(
                                          Icons.vpn_key_sharp,
                                          color: Colors.black,
                                        ),
                                        suffixIcon: Obx(
                                          () => GestureDetector(
                                            onTap: (){
                                              isObscure.value = !isObscure.value;
                                            },
                                            child: Icon(
                                              isObscure.value ? Icons.visibility_off : Icons.visibility,
                                              color: Colors.black,
                                            ),
                                          )
                                        ),
                                        hintText: "contraseña...",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30.0),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30.0),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30.0),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30.0),
                                          borderSide: const BorderSide(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 6,
                                        ),
                                        fillColor: Colors.white,
                                        filled: true,
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 18,),

                                  //login button
                                  Material(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(30),
                                    child: InkWell(
                                      onTap: () => login(),
                                      borderRadius: BorderRadius.circular(30),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 28,
                                        ),
                                        child: Text(
                                          "Iniciar Sesión",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )   
                                
                                ],
                              ),
                            ),

                          ],
                        ),
                      )
                      
                    ),
                  ),

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}