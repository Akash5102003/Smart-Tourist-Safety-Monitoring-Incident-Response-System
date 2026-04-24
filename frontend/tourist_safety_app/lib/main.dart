import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
  home: LoginScreen(),
    );
  }
}

String emergencyNumber = "91XXXXXXXXXX"; // replace with real number

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;

  String geoFenceStatus = "";
  String aiBehaviorStatus = "";

  LatLng currentPosition = const LatLng(12.9716, 77.5946);

  Future<Position> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception("Location services are disabled");
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  return await Geolocator.getCurrentPosition();
}



void openMapLive() async {
  Position position = await getCurrentLocation();

  final Uri url = Uri.parse(
    "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}",
  );

  await launchUrl(url);
}


  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 🔹 LOCATION
 
  // 🔹 LIVE TRACKING
  void startTracking() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {

      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
      });

      sendLocationLive(position);
    });
  }

  // 🔹 BACKEND
  void sendLocationLive(Position position) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/location'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "latitude": position.latitude,
        "longitude": position.longitude
      }),
    );

    final data = jsonDecode(response.body);

    setState(() {
      geoFenceStatus = data["geo_fence_status"];
      aiBehaviorStatus = data["behavior"];
    });
  }



void makeEmergencyCall() async {
  final Uri url = Uri.parse("tel:$emergencyNumber");

  await launchUrl(url);
}

  // 🔹 PANIC
  void sendPanic() async {
    await http.post(
      Uri.parse('http://127.0.0.1:5000/panic'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"location": "Emergency"}),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Emergency Alert Sent")),
    );
  }

  // 🔹 WHATSAPP
void sendLocationWhatsApp() async {
  Position position = await getCurrentLocation();

  String message =
      "Emergency! My live location: https://maps.google.com/?q=${position.latitude},${position.longitude}";

  final Uri url = Uri.parse(
    "https://wa.me/$emergencyNumber?text=${Uri.encodeComponent(message)}",
  );

  await launchUrl(url);
}
  // 🔹 BLOCKCHAIN
  void registerTourist() async {
    await http.post(
      Uri.parse('http://127.0.0.1:5000/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "address": "0x123",
        "name": "Akash",
        "idHash": "abc123hash"
      }),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Tourist Registered")),
    );
  }

  void fetchTourist() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:5000/tourist/0x123'),
    );

    final data = jsonDecode(response.body);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Name: ${data["name"]}")),
    );
  }

  // 🔥 HORIZONTAL ACTION CARD
  Widget buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 5),
            Text(title, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tourist Safety System")),
      body: SingleChildScrollView(
        child: Center(
          child: FadeTransition(
            opacity: _animation,
            child: Column(
              children: [

                const SizedBox(height: 20),

                const Icon(Icons.shield, size: 60, color: Colors.blue),

                const Text(
                  "Smart Tourist Safety",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const Text(
                  "Real-Time Monitoring Dashboard",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 10),

                const Text("Welcome, Akash 👋"),

                const SizedBox(height: 20),

                // 🗺 MAP
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 250,
                      width: 300,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: currentPosition,
                          initialZoom: 13,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: currentPosition,
                                width: 40,
                                height: 40,
                                child: const Icon(Icons.location_on,
                                    color: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔥 HORIZONTAL ACTIONS
                const Text(
                  "Quick Actions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [

                      buildActionCard("Track", Icons.location_on,
                          Colors.blue, startTracking),

                      buildActionCard("Panic", Icons.warning,
                          Colors.red, sendPanic),

                      buildActionCard("WhatsApp", Icons.message,
                          Colors.green, sendLocationWhatsApp),

                      buildActionCard("Register", Icons.app_registration,
                          Colors.purple, registerTourist),

                      buildActionCard("View ID", Icons.person,
                          Colors.orange, fetchTourist),

                          buildActionCard(
  "Open Map",
  Icons.map,
  Colors.teal,
  openMapLive,
),

buildActionCard(
  "Call Family",
  Icons.call,
  Colors.redAccent,
  makeEmergencyCall,
),
   

buildActionCard(
  "Send to Family",
  Icons.message,
  Colors.green,
  sendLocationWhatsApp,
),

                 ],
                  ),
                ),

                const SizedBox(height: 20),


                const SizedBox(height: 20),

Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: TextField(
    decoration: InputDecoration(
      labelText: "Emergency Contact Number",
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      prefixIcon: Icon(Icons.phone),
    ),
    keyboardType: TextInputType.phone,
    onChanged: (value) {
      emergencyNumber = value;
    },
  ),
),

const SizedBox(height: 20),

                // STATUS
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: geoFenceStatus.contains("SAFE")
                        ? Colors.green[100]
                        : Colors.red[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text("Geo-Fence: $geoFenceStatus"),
                  ),
                ),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: aiBehaviorStatus.contains("NORMAL")
                        ? Colors.green[100]
                        : Colors.red[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text("AI Behavior: $aiBehaviorStatus"),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Logout"),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}