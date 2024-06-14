import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:tfg/api_connection/api_connection.dart';
import 'package:tfg/home_screen.dart';

class SchedulesScreen extends StatefulWidget {
  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  var data = [];
  final storage = FlutterSecureStorage();
  late final String lessonId = Get.arguments;
  List<dynamic> bookedScheduleIds = [];

  @override
  void initState() {
    super.initState();
    _loadBookedScheduleIds();
  }

  Future<void> _loadBookedScheduleIds() async {
    final token = await storage.read(key: 'auth_token');
    final clientId = await storage.read(key: 'client_id');

    final url = Uri.parse(API.getBookingsUrl(clientId!));
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        bookedScheduleIds = jsonDecode(response.body);
      });
      print(bookedScheduleIds);
    } else {
      throw Exception('Error ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> getSchedules() async {
    final token = await storage.read(key: 'auth_token');

    final url = Uri.parse(API.getSchedulesUrl(lessonId));
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

  Future<void> book(String scheduleId) async {
    final token = await storage.read(key: 'auth_token');
    final clientId = await storage.read(key: 'client_id');

    final url = Uri.parse(API.bookUrl(clientId!, scheduleId));
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      Get.offAll(HomeScreen());
    } else {
      throw Exception('Error ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Horarios disponibles'),
        backgroundColor: Colors.purple,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getSchedules(),
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
            List<Map<String, dynamic>> schedules = snapshot.data!;
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
                        for (var i = 0; i < schedules.length; i++)
                          Column(
                            children: [
                              Container(
                                color: Colors.purpleAccent,
                                width: double.infinity,
                                padding: const EdgeInsets.all(8.0),
                                margin: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Día ${schedules[i]['day']}, de ${schedules[i]['date_from']} a ${schedules[i]['date_to']}',
                                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 10.0),
                                        Text(
                                          'Planta ${schedules[i]['room_floor']}, Habitación ${schedules[i]['room_number']}',
                                          style: const TextStyle(color: Colors.white, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    if (bookedScheduleIds.contains(schedules[i]['id']))
                                      const Icon(Icons.check, color: Colors.white, weight: 2.0,) // Show checkmark if booked
                                    else
                                      IconButton(
                                        icon: const Icon(Icons.bookmark_add),
                                        color: Colors.white,
                                        onPressed: () {
                                          book(schedules[i]['id']);
                                        },
                                      ),
                                  ],
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