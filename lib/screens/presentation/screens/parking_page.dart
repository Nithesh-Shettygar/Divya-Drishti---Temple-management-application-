import 'package:divya_drishti/screens/presentation/screens/parking/slot_cheking_page.dart';
import 'package:divya_drishti/screens/presentation/screens/parking/transportation_details_page.dart';
import 'package:flutter/material.dart';
import 'package:divya_drishti/core/constants/app_colors.dart';

class ParkingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Empty space at the top (colored background)
          
          // White box containing ALL content
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(30),
                child: Column(
                  children: [
                    // Live Parking Status Section
                    _buildSectionHeader('Live Parking Status'),
                    SizedBox(height: 15),
                    _buildParkingStatusBox(context),

                    SizedBox(height: 25),

                    // Transportation Services Section
                    _buildSectionHeader('Transportation Services'),
                    SizedBox(height: 15),
                    _buildTransportationBox(context),

                    SizedBox(height: 25),

                    // Fuel Stations Section
                    _buildSectionHeader('Nearest Fuel Stations'),
                    SizedBox(height: 15),
                    _buildFuelStationsBox(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ); 
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildParkingStatusBox(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Main Parking
            _buildParkingItem(
              context,
              'Main Parking',
              '45/100 spots available',
              Icons.local_parking,
              Colors.green,
            ),
            SizedBox(height: 12),
            // VIP Parking
            _buildParkingItem(
              context,
              'VIP Parking',
              '8/20 spots available',
              Icons.flag,
              Colors.orange,
            ),
            SizedBox(height: 12),
            // 2 Wheeler Parking
            _buildParkingItem(
              context,
              '2 Wheeler Parking',
              '120/200 spots available',
              Icons.two_wheeler,
              Colors.blue,
            ),
            SizedBox(height: 12),
            // Bus Parking
            _buildParkingItem(
              context,
              'Bus Parking',
              '15/25 spots available',
              Icons.directions_bus,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParkingItem(BuildContext context, String title, String status, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          radius: 20,
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        subtitle: Text(
          status,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.primary.withOpacity(0.7),
          ),
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            icon: Icon(
              Icons.navigation,
              size: 18,
              color: AppColors.primary,
            ),
            onPressed: () {
              _navigateToParkingDetails(context, title);
            },
          ),
        ),
        onTap: () {
          _navigateToParkingDetails(context, title);
        },
      ),
    );
  }

  Widget _buildTransportationBox(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTransportationItem(
              context,
              'Bus Stops',
              'Find nearby bus stops and routes',
              Icons.directions_bus,
            ),
            SizedBox(height: 12),
            _buildTransportationItem(
              context,
              'Train Stations',
              'Locate train stations and schedules',
              Icons.train,
            ),
            SizedBox(height: 12),
            _buildTransportationItem(
              context,
              'Airports',
              'Find airports and flight information',
              Icons.flight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportationItem(BuildContext context, String title, String subtitle, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          radius: 20,
          child: Icon(
            icon,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.primary.withOpacity(0.7),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.primary,
        ),
        onTap: () {
          _navigateToTransportationDetails(context, title);
        },
      ),
    );
  }

  Widget _buildFuelStationsBox(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildFuelStationItem(
              context,
              'Petrol Stations',
              '3 stations within 3km',
              Icons.local_gas_station,
              Colors.orange,
            ),
            SizedBox(height: 12),
            _buildFuelStationItem(
              context,
              'Diesel Stations',
              '2 stations within 4km',
              Icons.local_gas_station,
              Colors.blue,
            ),
            SizedBox(height: 12),
            _buildFuelStationItem(
              context,
              'EV Charging Stations',
              '5 charging points within 5km',
              Icons.ev_station,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelStationItem(BuildContext context, String title, String info, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          radius: 20,
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        subtitle: Text(
          info,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.primary.withOpacity(0.7),
          ),
        ),
        trailing: Icon(
          Icons.info_outline,
          color: AppColors.primary,
        ),
        onTap: () {
          _showFuelStationInfo(context, title);
        },
      ),
    );
  }

  void _navigateToParkingDetails(BuildContext context, String parkingType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParkingDetailsPage(parkingType: parkingType),
      ),
    );
  }

  void _navigateToTransportationDetails(BuildContext context, String transportType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransportationDetailsPage(transportType: transportType),
      ),
    );
  }

  void _showFuelStationInfo(BuildContext context, String fuelType) {
    Map<String, String> fuelInfo = {
      'Petrol Stations': 'Price: ₹96.72/L\n24/7 available\nAccepts digital payments\nContact: 1800-123-4567',
      'Diesel Stations': 'Price: ₹89.62/L\n24/7 available\nAccepts digital payments\nContact: 1800-123-4568',
      'EV Charging Stations': 'Fast charging available\n₹15/kWh\n24/7 service\nMultiple connectors\nContact: 1800-123-4569'
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(fuelType),
        content: Text(fuelInfo[fuelType] ?? 'Information not available'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}