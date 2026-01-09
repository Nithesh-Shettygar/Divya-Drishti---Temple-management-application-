import 'package:divya_drishti/screens/presentation/screens/SOS/ui_home.dart';
import 'package:divya_drishti/screens/presentation/widgets/common_top_section.dart';
import 'package:divya_drishti/screens/presentation/screens/explore_page.dart';
import 'package:divya_drishti/screens/presentation/screens/home_page.dart';
import 'package:divya_drishti/screens/presentation/screens/more_page.dart';
import 'package:divya_drishti/screens/presentation/screens/parking_page.dart';
import 'package:flutter/material.dart';
import 'package:divya_drishti/core/constants/app_colors.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Different pages for navigation
  final List<Widget> _pages = [
    HomeContent(),
    ExplorePage(),
    HomeScreen(),
    ParkingPage(),
    MorePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.primaryGradient),
        child: Column(
          children: [
            CommonTopSection(),
            Expanded(child: _pages[_currentIndex]),
          ],
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
          
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.secondary, width: 3.0),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: Colors.grey.shade600,
              selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore_outlined),
                  activeIcon: Icon(Icons.explore),
                  label: 'Explore',
                ),
                BottomNavigationBarItem(
                  icon: _buildSOSIcon(),
                  activeIcon: _buildSOSIcon(),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.local_parking_outlined),
                  activeIcon: Icon(Icons.local_parking),
                  label: 'Parking',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_outlined),
                  activeIcon: Icon(Icons.menu),
                  label: 'More',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Custom SOS icon widget
  Widget _buildSOSIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.5),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'SOS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}




// import 'package:divya_drishti/screens/presentation/screens/SOS/ui_home.dart';
// import 'package:divya_drishti/screens/presentation/widgets/common_top_section.dart';
// import 'package:divya_drishti/screens/presentation/screens/explore_page.dart';
// import 'package:divya_drishti/screens/presentation/screens/home_page.dart';
// import 'package:divya_drishti/screens/presentation/screens/more_page.dart';
// import 'package:divya_drishti/screens/presentation/screens/parking_page.dart';
// import 'package:flutter/material.dart';
// import 'package:divya_drishti/core/constants/app_colors.dart';

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   int _currentIndex = 0;

//   // Different pages for navigation
//   final List<Widget> _pages = [
//     HomeContent(),
//     ExplorePage(),
//     HomeScreen(),
   
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Container(
//         decoration: BoxDecoration(gradient: AppColors.primaryGradient),
//         child: Column(
//           children: [
//             CommonTopSection(),
//             Expanded(child: _pages[_currentIndex]),
//           ],
//         ),
//       ),
//       // Bottom Navigation Bar
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.only(
          
//           ),
//           child: Container(
//             decoration: BoxDecoration(
//               border: Border(
//                 top: BorderSide(color: AppColors.secondary, width: 3.0),
//               ),
//             ),
//             child: BottomNavigationBar(
//               currentIndex: _currentIndex,
//               onTap: (index) {
//                 setState(() {
//                   _currentIndex = index;
//                 });
//               },
//               type: BottomNavigationBarType.fixed,
//               backgroundColor: Colors.white,
//               selectedItemColor: AppColors.primary,
//               unselectedItemColor: Colors.grey.shade600,
//               selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
//               items: [
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.home_outlined),
//                   activeIcon: Icon(Icons.home),
//                   label: 'Home',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.explore_outlined),
//                   activeIcon: Icon(Icons.explore),
//                   label: 'Explore',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: _buildSOSIcon(),
//                   activeIcon: _buildSOSIcon(),
//                   label: '',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.local_parking_outlined),
//                   activeIcon: Icon(Icons.local_parking),
//                   label: 'Parking',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.menu_outlined),
//                   activeIcon: Icon(Icons.menu),
//                   label: 'More',
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Custom SOS icon widget
//   Widget _buildSOSIcon() {
//     return Container(
//       width: 50,
//       height: 50,
//       decoration: BoxDecoration(
//         color: Colors.red,
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.red.withOpacity(0.5),
//             blurRadius: 8,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Center(
//         child: Text(
//           'SOS',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 12,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
// }

