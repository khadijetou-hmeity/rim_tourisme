import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final start = TextEditingController();
  final end = TextEditingController();
  bool isVisible = false;
  List<LatLng> routpoints = [LatLng(52.05884, -1.345583)];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Routing',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.grey[500],
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                myInput(controler: start, hint: 'Enter Starting PostCode'),
                SizedBox(height: 15,),
                myInput(controler: end, hint: 'Enter Ending PostCode'),
                SizedBox(height: 15,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[500]),
                  onPressed: () async {
                    try {
                      List<Location> startL = await locationFromAddress(start.text);
                      List<Location> endL = await locationFromAddress(end.text);

                      var v1 = startL[0].latitude;
                      var v2 = startL[0].longitude;
                      var v3 = endL[0].latitude;
                      var v4 = endL[0].longitude;

                      var url = Uri.parse('http://router.project-osrm.org/route/v1/driving/$v2,$v1;$v4,$v3?steps=true&annotations=true&geometries=geojson&overview=full');
                      var response = await http.get(url);
                      print(response.body);
                      setState(() {
                        routpoints = [];
                        var routes = jsonDecode(response.body)['routes'];
                        if (routes.isNotEmpty) {
                          var ruter = routes[0]['geometry']['coordinates'];
                          for (int i = 0; i < ruter.length; i++) {
                            var lat = ruter[i][1];
                            var long = ruter[i][0];
                            routpoints.add(LatLng(lat, long));
                          }
                          isVisible = true;
                          print(routpoints);
                        } else {
                          isVisible = false;
                          print('No route found.');
                        }
                      });
                    } catch (e) {
                      print('Error: $e');
                    }
                  },
                  child: Text('Press'),
                ),
                SizedBox(height: 10,),
                SizedBox(
                  height: 500,
                  width: 400,
                  child: Visibility(
                    visible: isVisible,
                    child: Stack(
                      children: [
                        FlutterMap(
                          options: MapOptions(
                            center: routpoints[0],
                            zoom: 10,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.app',
                            ),
                            PolylineLayer(
                              polylineCulling: false,
                              polylines: [
                                Polyline(points: routpoints, color: Colors.blue, strokeWidth: 9)
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Text(
                            '© OpenStreetMap contributors',
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class myInput extends StatefulWidget {
  final TextEditingController controler;
  final String hint;

  const myInput({
    super.key,
    required this.controler,
    required this.hint,
  });

  @override
  State<myInput> createState() => _myInputState();
}

class _myInputState extends State<myInput> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controler,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white)
        ),
        fillColor: Colors.white,
        filled: true,
        hintText: widget.hint,
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
    );
  }
}
