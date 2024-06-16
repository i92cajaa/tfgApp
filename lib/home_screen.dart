import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tfg/api_connection/api_connection.dart';
import 'package:http/http.dart' as http;
import 'package:tfg/client_profile_screen.dart';
import 'package:tfg/lessons_screen.dart';
import 'package:tfg/login_screen.dart';
import 'package:tfg/utils/base64_to_image.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  var data = [];
  final storage = FlutterSecureStorage();

  Future<List<Map<String, dynamic>>> getCenters() async {
    final token = await storage.read(key: 'auth_token');

    final url = Uri.parse(API.getCentersUrl);
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Error ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text('Centros'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            color: Colors.black,
            onPressed: () async {
              Get.to(ClientProfileScreen());
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.black,
            onPressed: () async {
              // Clear the token and navigate to the login screen
              final storage = FlutterSecureStorage();
              await storage.delete(key: 'auth_token');
              await storage.delete(key: 'client_id');
              Get.offAll(LoginScreen());
            },
          ),
        ],
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getCenters(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(), // Indicador de carga
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Center(
              child: Image.asset('images/empty_image.png'), // Imagen cuando no hay datos
            );
          } else if (snapshot.hasData) {
            List<Map<String, dynamic>> centers = snapshot.data!;
            return LayoutBuilder(
              builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 10.0),
                        for (var i = 0; i < centers.length; i++)
                          Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  Get.to(LessonsScreen(), arguments: centers[i]['id']);
                                },
                                child: Container(
                                  color: Color(int.parse(centers[i]['color'].substring(1, 7), radix: 16) + 0xFF000000),
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8.0),
                                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    children: [
                                      Base64ImageWidget(
                                        base64String: centers[i]['img'],
                                        width: 80,
                                        height: 80,
                                      ),
                                      const SizedBox(width: 10.0),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            centers[i]['name'],
                                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 10.0),
                                          Text(
                                            'Horario: ${centers[i]['opening_time']} - ${centers[i]['closing_time']}',
                                            style: const TextStyle(color: Colors.white, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10.0),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text('No se encontraron datos'),
            );
          }
        },
      ),
    );
  }
}