import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sehatsathi/authentication/login_screans/login_page.dart';
import 'package:sehatsathi/features/diabetes_prediction_page.dart';
import 'package:sehatsathi/features/heart_disease_page.dart';
import 'package:sehatsathi/features/neurology_analysis_page.dart';
import 'package:sehatsathi/pages/profile_page.dart';
import 'package:sehatsathi/util/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String fullName = "";
  late PageController _pageController;
  int _currentIndex = 0;
  late Timer _timer;
  List<dynamic> doctors = [];

  final List<Map<String, dynamic>> items = [
    {
      "cardColor": maingreen2,
      "title": "Check Your Health Now!",
      "textColor": Colors.black,
      "description1": "Predict Your Diabetes Risk",
      "description2": "Get Instant Analysis!",
      "imageUrl": "https://cdn-icons-png.flaticon.com/128/16867/16867357.png",
      "onTap": DiabetesPredictionPage()
    },
    {
      "cardColor": maingreen,
      "title": "Check Your Neurology!",
      "textColor": Colors.white,
      "description1": "Analyze Your Neurology Risk",
      "description2": "Get Instant Analysis!",
      "imageUrl": "https://cdn-icons-png.flaticon.com/128/3974/3974920.png",
      "onTap": NeurologyAnalysisPage()
    },
    {
      "cardColor": maingreen2,
      "title": "Check Your Heart Health!",
      "textColor": Colors.black,
      "description1": "Predict Your Heart Risk",
      "description2": "Get Instant Analysis!",
      "imageUrl": "https://cdn-icons-png.flaticon.com/128/4773/4773193.png",
      "onTap": HeartDiseasePage()
    }
  ];

  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    String? userEmail = prefs.getString("email");

    if (token == null || userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unauthorized! Please log in again.")),
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
      return;
    }

    final String apiUrl =
        "https://auth-healthcare.onrender.com/user?email=$userEmail";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          fullName = data["full_name"];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.body}")),
        );
      }
    } catch (e) {
      print('Exception $e');
    }
  }

  Future<void> fetchDoctors() async {
    final String apiUrl = "https://doctors-list-1.onrender.com/doctors";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          doctors = data;
        });
      } else {
        print("Error fetching doctors: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _pageController =
        PageController(initialPage: _currentIndex, viewportFraction: 0.9);

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentIndex < items.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      if (mounted) {
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50, right: 20, left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟢 Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $fullName 👋',
                      style: GoogleFonts.josefinSans(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Text('Welcome to ', style: GoogleFonts.josefinSans()),
                        Text('Sehatसाथी',
                            style: GoogleFonts.baloo2(
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                  },
                  child: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(
                      'https://cdn-icons-png.flaticon.com/128/4139/4139981.png',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 🟢 PageView Section (Fixed height)
            SizedBox(
              height: 200, // Ensures proper rendering
              child: PageView.builder(
                controller: _pageController,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Container(
                    height: 160,
                    width: double.infinity,
                    margin:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
                    decoration: BoxDecoration(
                      color: items[index]['cardColor'],
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                items[index]['title'],
                                style: GoogleFonts.josefinSans(
                                  fontWeight: FontWeight.bold,
                                  color: items[index]['textColor'],
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                items[index]['description1'],
                                style: GoogleFonts.josefinSans(
                                    color: items[index]['textColor']),
                              ),
                              Text(
                                items[index]['description2'],
                                style: GoogleFonts.josefinSans(
                                    color: items[index]['textColor']),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              items[index]['onTap']));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(120, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Predict here',
                                  style: GoogleFonts.josefinSans(
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 60,
                          right: 15,
                          child: Image.network(
                            items[index]['imageUrl'],
                            height: 80,
                            width: 80,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // 🟢 Doctor List Section (Fixed ListView issue)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Popular Doctors',
                    style: GoogleFonts.josefinSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                      child: FutureBuilder(
                    future: fetchDoctors(),
                    builder: (context, snapshot) {
                      if (doctors.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return ListView.builder(
                        itemCount: doctors.length,
                        itemBuilder: (context, index) {
                          var doctor = doctors[index];

                          return Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: Colors.grey.shade300, width: 1.0),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 35,
                                  backgroundImage:
                                      NetworkImage(doctor["imageUrl"]),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doctor["name"],
                                        style: GoogleFonts.josefinSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        doctor["specialty"],
                                        style: GoogleFonts.josefinSans(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.star,
                                              color: Colors.amber),
                                          const SizedBox(width: 4),
                                          Text(
                                            doctor["rank"].toString(),
                                            style: GoogleFonts.josefinSans(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Fee: ",
                                            style: GoogleFonts.josefinSans(
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            "₹${doctor["fee"]}",
                                            style: GoogleFonts.josefinSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    "Booking For ${doctor["name"]}")));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: maingreen,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      child: const Text("Book Now"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
