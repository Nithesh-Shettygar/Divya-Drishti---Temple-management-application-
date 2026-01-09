// import 'package:flutter/material.dart';
// import 'shake_detector.dart';
// import 'sos_service.dart';

// class HomeScreen extends StatefulWidget {
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   String status = "Waiting...";

//   @override
//   void initState() {
//     super.initState();

//     ShakeManager.startShakeListener(onSOS: () {
//       setState(() => status = "SOS Triggered! Sending location...");
//       SosService.sendLocationToFirebase();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("SOS Safety App")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.sos, size: 120, color: Colors.red),
//             const SizedBox(height: 20),
//             Text("Shake your phone 5 times to send SOS",
//                 style: TextStyle(fontSize: 18)),
//             const SizedBox(height: 30),
//             Text("Status: $status"),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: () {
//                 SosService.sendLocationToFirebase();
//                 setState(() => status = "Manual SOS Sent");
//               },
//               child: const Text("SEND SOS NOW"),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }// home_screen.dart
import 'package:divya_drishti/core/constants/app_colors.dart';
import 'package:divya_drishti/screens/presentation/screens/SOS/shake_detector.dart';
import 'package:flutter/material.dart';
import 'sos_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String status = "Waiting for SOS...";
  String? userName;
  String? userPhone;

  @override
  void initState() {
    super.initState();
   
    _loadUserData();
    
    // Start shake detector
    ShakeManager.startShakeListener(
      onSOS: _triggerSOS,
    );
    
    // Add a test delay to check if shake detector is working
    Future.delayed(Duration(seconds: 2), () {
     
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name');
      userPhone = prefs.getString('user_phone');
    });
    
   
  }

  Future<void> _triggerSOS() async {
   
    
    setState(() {
      status = "SOS Detected! Sending location with profile data...";
    });
    
    try {
    
      await SosService.sendLocationToFirebase();
      
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_name') ?? 'Unknown';
      final phone = prefs.getString('user_phone') ?? 'Unknown';
      
      setState(() {
        status = "✅ SOS Sent Successfully!\n📍 Static Location: 23.224363, 72.507734\n👤 Name: $name\n📱 Phone: $phone\n📞 SMS sent to emergency contacts";
      });
      
     
      
      // Reset status after 10 seconds
      await Future.delayed(Duration(seconds: 10));
      if (mounted) {
        setState(() {
          status = "Waiting for SOS...";
        });
      }
    } catch (e) {
    
      setState(() {
        status = "Error sending SOS: $e";
      });
    }
  }

  // Add this method to test SOS manually
  void _testSOS() {
  
    ShakeManager.triggerSOSManually(_triggerSOS);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, AppColors.bg],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              // User Info Header
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  left: 20,
                  right: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (userName != null)
                      Text(
                        "Welcome, $userName",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    SizedBox(height: 5),
                    Text(
                      "SOS will send your profile data with location",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    // Add debug button
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _testSOS,
                      child: Text("Test SOS (Debug)"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),

              // Status Display
              Padding(
                padding: EdgeInsets.only(top: 30, bottom: 20, left: 20, right: 20),
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Status",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // SOS Button
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.15),
                        gradient: AppColors.darkGradient.withOpacity(0.2),
                      ),
                      child: ElevatedButton(
                        onPressed: _triggerSOS,
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          backgroundColor: Colors.transparent,
                          elevation: 10,
                          shadowColor: AppColors.gradientDark.withOpacity(0.4),
                        ),
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.darkGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gradientDark.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.sos, size: 60, color: Colors.white),
                              SizedBox(height: 10),
                              Text(
                                "SOS",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Tap or Shake",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Shake phone 5 times or tap button",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Emergency Contacts
              Container(
                margin: EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: 30,
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Emergency Contacts",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 25),

                    // Medical Team Button
                    Padding(
                      padding: EdgeInsets.only(bottom: 15),
                      child: _buildEmergencyButton(
                        Icons.local_hospital,
                        "Medical Team",
                        AppColors.secondary,
                      ),
                    ),

                    // Police Button
                    Padding(
                      padding: EdgeInsets.only(bottom: 15),
                      child: _buildEmergencyButton(
                        Icons.local_police,
                        "Police",
                        AppColors.primary,
                      ),
                    ),

                    // Ambulance Button
                    Padding(
                      padding: EdgeInsets.only(bottom: 15),
                      child: _buildEmergencyButton(
                        Icons.airport_shuttle,
                        "Ambulance",
                        AppColors.gradientMiddle,
                      ),
                    ),

                    // Fire Brigade Button
                    _buildEmergencyButton(
                      Icons.fire_extinguisher,
                      "Fire Brigade",
                      AppColors.gradientDark,
                    ),

                    SizedBox(height: 10),
                  ],
                ),
              ),

              // Bottom padding for safe area
              SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyButton(IconData icon, String label, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Add your emergency contact logic here
        
          _showEmergencyDialog(label);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: Colors.white),
            SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyDialog(String service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Call $service?"),
        content: Text("Do you want to call emergency $service?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _callEmergencyService(service);
            },
            child: Text("Call"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void _callEmergencyService(String service) {
    // This would normally dial a phone number
    // For now, just show a message
    
    String emergencyNumber = "";
    switch (service) {
      case "Medical Team":
        emergencyNumber = "108";
        break;
      case "Police":
        emergencyNumber = "100";
        break;
      case "Ambulance":
        emergencyNumber = "102";
        break;
      case "Fire Brigade":
        emergencyNumber = "101";
        break;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("📞 Calling $service: $emergencyNumber"),
        backgroundColor: Colors.green,
      ),
    );
    
    // In a real app, you would use url_launcher to dial:
    // launch("tel:$emergencyNumber");
    
   
  }
}