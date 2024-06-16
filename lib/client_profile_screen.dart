import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tfg/api_connection/api_connection.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tfg/home_screen.dart';

class ClientProfileScreen extends StatefulWidget {
  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {

  var data = [];
  final storage = FlutterSecureStorage();

  Future<List<List<Map<String, dynamic>>>> getBookings() async {
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
      var data = jsonDecode(response.body);
      return List<List<Map<String, dynamic>>>.from(
        data.map((outer) => List<Map<String, dynamic>>.from(
          outer.map((inner) => Map<String, dynamic>.from(inner)),
        )),
      );
    } else {
      throw Exception('Error ${response.statusCode}');
    }
  }

  Future<void> cancelBooking(String scheduleId) async {
    final token = await storage.read(key: 'auth_token');
    final clientId = await storage.read(key: 'client_id');

    final url = Uri.parse(API.cancelBookingUrl(clientId!, scheduleId));
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
        title: const Text('Mi perfil'),
        backgroundColor: Colors.purple,
      ),

      body: FutureBuilder<List<List<Map<String, dynamic>>>>(
        future: getBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(), // Indicador de carga
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            List<List<Map<String, dynamic>>> bookings = snapshot.data!;
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
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Text(
                                '${bookings[0][0]['name']}',
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 10.0,),
                              Text(
                                'DNI: ${bookings[0][0]['dni']}',
                                style: const TextStyle(color: Colors.white, fontSize: 18),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 10.0,),
                        const Text(
                          'Mis Reservas',
                          style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5.0,),
                        for (var i = 0; i < bookings[1].length; i++)
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
                                          'Clase ${bookings[1][i]['class']}',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                          textAlign: TextAlign.start,
                                        ),
                                        Text(
                                          'Día ${bookings[1][i]['day']}, de ${bookings[1][i]['date_from']} a ${bookings[1][i]['date_to']}',
                                          style: const TextStyle(color: Colors.white, fontSize: 14),
                                          textAlign: TextAlign.start,
                                        ),
                                        Text(
                                          'Planta ${bookings[1][i]['room_floor']}, Habitación ${bookings[1][i]['room_number']}',
                                          style: const TextStyle(color: Colors.white, fontSize: 14),
                                          textAlign: TextAlign.start,
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    if (bookings[1][i]['done'] == 1)
                                      IconButton(
                                        onPressed: () => cancelBooking(bookings[1][i]['schedule_id']),
                                        icon: const Icon(Icons.cancel),
                                        color: Colors.white,
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