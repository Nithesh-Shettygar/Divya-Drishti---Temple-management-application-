import 'package:flutter/material.dart';
import 'package:divya_drishti/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this import
import 'package:url_launcher/url_launcher_string.dart'; // Add this import

class ParkingDetailsPage extends StatefulWidget {
  final String parkingType;

  const ParkingDetailsPage({Key? key, required this.parkingType}) : super(key: key);

  @override
  _ParkingDetailsPageState createState() => _ParkingDetailsPageState();
}

class _ParkingDetailsPageState extends State<ParkingDetailsPage> {
  // Mock data for different parking types
  final Map<String, ParkingDetails> _parkingData = {
    'Main Parking': ParkingDetails(
      name: 'Main Parking',
      totalSpots: 100,
      availableSpots: 45,
      price: '₹50 for 4 hours',
      operatingHours: '24/7',
      address: 'North Gate, Temple Complex',
      facilities: ['CCTV Surveillance', 'Well Lit', 'Security Guard', 'Payment Counter'],
      coordinates: '23.224363, 72.507734',
    ),
    'VIP Parking': ParkingDetails(
      name: 'VIP Parking',
      totalSpots: 20,
      availableSpots: 8,
      price: '₹100 for 4 hours',
      operatingHours: '6:00 AM - 10:00 PM',
      address: 'East Gate, Near Main Entrance',
      facilities: ['Covered Parking', 'Valet Service', 'CCTV', 'Premium Security'],
      coordinates: '28.6130, 77.2300',
    ),
    '2 Wheeler Parking': ParkingDetails(
      name: '2 Wheeler Parking',
      totalSpots: 200,
      availableSpots: 120,
      price: '₹20 for 4 hours',
      operatingHours: '24/7',
      address: 'South Gate, Left Side',
      facilities: ['Helmet Storage', 'CCTV', 'Security', 'Air Pump'],
      coordinates: '28.6128, 77.2290',
    ),
    'Bus Parking': ParkingDetails(
      name: 'Bus Parking',
      totalSpots: 25,
      availableSpots: 15,
      price: '₹200 for 4 hours',
      operatingHours: '5:00 AM - 11:00 PM',
      address: 'West Gate, Separate Entrance',
      facilities: ['Large Space', 'Driver Rest Area', 'CCTV', 'Security'],
      coordinates: '28.6132, 77.2285',
    ),
  };

  // Function to open Google Maps
  Future<void> _openGoogleMaps(ParkingDetails parkingDetails) async {
    // Extract latitude and longitude from coordinates string
    final coords = parkingDetails.coordinates.split(',');
    if (coords.length != 2) return;
    
    final latitude = coords[0].trim();
    final longitude = coords[1].trim();
    
    // Create Google Maps URL
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    
    // Alternative: For directions from user's current location
    // final url = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving';
    
    try {
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Navigation Error'),
        content: Text('Could not open Google Maps. Please make sure you have Google Maps installed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parkingDetails = _parkingData[widget.parkingType]!;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(widget.parkingType),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map Section
            _buildMapSection(parkingDetails),
            
            SizedBox(height: 25),
            
            // Parking Status
            _buildParkingStatusSection(parkingDetails),
            
            SizedBox(height: 25),
            
            // Parking Details
            _buildParkingDetailsSection(parkingDetails),
            
            SizedBox(height: 25),
            
            // Facilities
            _buildFacilitiesSection(parkingDetails),
            
            SizedBox(height: 30),
            
            // Navigation Button
            _buildNavigationButton(parkingDetails),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection(ParkingDetails parkingDetails) {
    return GestureDetector(
      onTap: () => _openGoogleMaps(parkingDetails),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Map Placeholder
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 50,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Open in Google Maps',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Tap to open location',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Coordinates: ${parkingDetails.coordinates}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            // Availability Badge
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: parkingDetails.availableSpots > 0 ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  parkingDetails.availableSpots > 0 ? 'Available' : 'Full',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParkingStatusSection(ParkingDetails parkingDetails) {
    double availabilityPercentage = (parkingDetails.availableSpots / parkingDetails.totalSpots) * 100;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parking Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 15),
            
            // Availability Progress
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Availability',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: 5),
                      LinearProgressIndicator(
                        value: availabilityPercentage / 100,
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          availabilityPercentage > 30 ? Colors.green : 
                          availabilityPercentage > 10 ? Colors.orange : Colors.red,
                        ),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${parkingDetails.availableSpots}/${parkingDetails.totalSpots}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'spots available',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            // Quick Info Grid
            Row(
              children: [
                _buildInfoItem('Price', parkingDetails.price, Icons.attach_money),
                SizedBox(width: 20),
                _buildInfoItem('Hours', parkingDetails.operatingHours, Icons.access_time),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: AppColors.primary,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParkingDetailsSection(ParkingDetails parkingDetails) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parking Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 15),
            
            GestureDetector(
              onTap: () => _openGoogleMaps(parkingDetails),
              child: _buildDetailRow('Address', parkingDetails.address, Icons.location_on),
            ),
            SizedBox(height: 12),
            GestureDetector(
              onTap: () => _openGoogleMaps(parkingDetails),
              child: _buildDetailRow('Coordinates', parkingDetails.coordinates, Icons.map),
            ),
            SizedBox(height: 12),
            _buildDetailRow('Parking Type', widget.parkingType, Icons.local_parking),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.primary.withOpacity(0.7),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFacilitiesSection(ParkingDetails parkingDetails) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Facilities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 15),
            
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: parkingDetails.facilities.map((facility) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        facility,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(ParkingDetails parkingDetails) {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _openGoogleMaps(parkingDetails),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.navigation, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Start Navigation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ParkingDetails {
  final String name;
  final int totalSpots;
  final int availableSpots;
  final String price;
  final String operatingHours;
  final String address;
  final List<String> facilities;
  final String coordinates;

  ParkingDetails({
    required this.name,
    required this.totalSpots,
    required this.availableSpots,
    required this.price,
    required this.operatingHours,
    required this.address,
    required this.facilities,
    required this.coordinates,
  });
}