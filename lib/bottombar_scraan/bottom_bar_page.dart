import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sehatsathi/features/food_planner_page.dart';
import 'package:sehatsathi/features/health_recommendation_page.dart';
import 'package:sehatsathi/features/prescription_scanner_page.dart';
import 'package:sehatsathi/pages/home_page.dart';
import 'package:sehatsathi/util/colors.dart';

class BottomBarPage extends StatefulWidget {
  const BottomBarPage({super.key});

  @override
  State<BottomBarPage> createState() => _BottomBarPageState();
}

class _BottomBarPageState extends State<BottomBarPage> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const HealthRecommendationScreen(),
      const FoodPlannerPage(),
      const PrescriptionScanner()
    ];
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        bool shouldExit = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Exit App",
                style: TextStyle(fontSize: screenWidth * 0.045)),
            content: Text("Are you sure you want to exit?",
                style: TextStyle(fontSize: screenWidth * 0.04)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("No",
                      style: TextStyle(fontSize: screenWidth * 0.04))),
              TextButton(
                  onPressed: () => exit(0),
                  child: Text("Yes",
                      style: TextStyle(fontSize: screenWidth * 0.04))),
            ],
          ),
        );
        return shouldExit;
      },
      child: Scaffold(
        backgroundColor: maingreen,
        body: _pages[_selectedIndex],
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            right: screenWidth * 0.02,
            left: screenWidth * 0.02,
            bottom: screenHeight * 0.02,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenWidth * 0.07),
              color: const Color(0xff354f52),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.02,
                vertical: screenHeight * 0.01,
              ),
              child: GNav(
                gap: screenWidth * 0.02,
                activeColor: const Color(0xff354f52),
                color: Colors.white,
                backgroundColor: const Color(0xff354f52),
                tabBackgroundColor: Colors.white,
                padding: EdgeInsets.all(screenWidth * 0.035),
                tabs: [
                  GButton(
                    icon: Icons.home_outlined,
                    text: 'Home',
                    textSize: screenWidth * 0.04,
                  ),
                  GButton(
                    icon: Icons.event_note_outlined,
                    text: 'Recommendation',
                    textSize: screenWidth * 0.04,
                  ),
                  GButton(
                    icon: Icons.food_bank_outlined,
                    text: 'Diet',
                    textSize: screenWidth * 0.04,
                  ),
                  GButton(
                    icon: Icons.image_search,
                    text: 'Scanner',
                    textSize: screenWidth * 0.04,
                  ),
                ],
                selectedIndex: _selectedIndex,
                onTabChange: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
