import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:tfg/api_connection/api_connection.dart';
import 'package:tfg/schedules_screen.dart';
import 'package:tfg/utils/base64_to_image.dart';

class LessonsScreen extends StatefulWidget {
  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  var data = [];
  final storage = FlutterSecureStorage();
  late final String centerId = Get.arguments;

  @override
  void initState() {
    super.initState();
    // No es necesario llamar _getLessons() aquí porque FutureBuilder lo manejará
  }

  Future<List<Map<String, dynamic>>> getLessons() async {
    final token = await storage.read(key: 'auth_token');

    final url = Uri.parse(API.getLessonsUrl(centerId));
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
        title: const Text('Clases'),
        backgroundColor: Colors.purple,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getLessons(),
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
            List<Map<String, dynamic>> lessons = snapshot.data!;
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
                        for (var i = 0; i < lessons.length; i++)
                          Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  Get.to(SchedulesScreen(), arguments: lessons[i]['id']);
                                },
                                child: Container(
                                  color: Color(int.parse(lessons[i]['color'].substring(1, 7), radix: 16) + 0xFF000000),
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8.0),
                                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    children: [
                                      Base64ImageWidget(
                                        base64String: lessons[i]['img'],
                                        width: 80,
                                        height: 80,
                                      ),
                                      const SizedBox(width: 10.0),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            lessons[i]['name'],
                                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 10.0),
                                          Text(
                                            'Duración: ${lessons[i]['duration']} h',
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