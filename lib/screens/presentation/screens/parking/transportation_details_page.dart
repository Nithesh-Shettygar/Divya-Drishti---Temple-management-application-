import 'package:flutter/material.dart';
import 'package:divya_drishti/core/constants/app_colors.dart';

class TransportationDetailsPage extends StatelessWidget {
  final String transportType;

  const TransportationDetailsPage({Key? key, required this.transportType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample data for different transport types
    Map<String, List<TransportStation>> stationsData = {
      'Bus Stops': [
        TransportStation(
          name: 'Central Bus Terminal',
          distance: '1.2 km',
          travelTime: '5 mins',
          price: '₹25',
          address: '123 Main Road, City Center',
          routes: ['Route 101', 'Route 202', 'Route 305']
        ),
        TransportStation(
          name: 'North Bus Stand',
          distance: '2.5 km',
          travelTime: '8 mins',
          price: '₹35',
          address: '456 North Avenue',
          routes: ['Route 102', 'Route 204']
        ),
        TransportStation(
          name: 'South Bus Depot',
          distance: '3.8 km',
          travelTime: '12 mins',
          price: '₹45',
          address: '789 South Street',
          routes: ['Route 103', 'Route 206', 'Route 309']
        ),
        TransportStation(
          name: 'East Bus Stop',
          distance: '4.2 km',
          travelTime: '15 mins',
          price: '₹50',
          address: '321 East Boulevard',
          routes: ['Route 104']
        ),
      ],
      'Train Stations': [
        TransportStation(
          name: 'Central Railway Station',
          distance: '3.5 km',
          travelTime: '10 mins',
          price: '₹150',
          address: 'Central Plaza, Railway Road',
          routes: ['Express', 'Local', 'Metro']
        ),
        TransportStation(
          name: 'City Junction',
          distance: '5.2 km',
          travelTime: '15 mins',
          price: '₹180',
          address: 'Junction Road, Downtown',
          routes: ['Superfast', 'Express']
        ),
        TransportStation(
          name: 'Metro Central',
          distance: '2.8 km',
          travelTime: '8 mins',
          price: '₹80',
          address: 'Metro Tower, City Center',
          routes: ['Red Line', 'Blue Line', 'Green Line']
        ),
      ],
      'Airports': [
        TransportStation(
          name: 'International Airport',
          distance: '25 km',
          travelTime: '45 mins',
          price: '₹1200',
          address: 'Airport Road, International Zone',
          routes: ['Domestic', 'International']
        ),
        TransportStation(
          name: 'Domestic Airport',
          distance: '18 km',
          travelTime: '35 mins',
          price: '₹800',
          address: 'Aviation Road, Domestic Terminal',
          routes: ['Domestic Flights']
        ),
        TransportStation(
          name: 'City Airport',
          distance: '12 km',
          travelTime: '25 mins',
          price: '₹600',
          address: 'City Air Terminal',
          routes: ['Charter', 'Private']
        ),
      ],
    };

    List<TransportStation> stations = stationsData[transportType] ?? [];

    return Scaffold(
      backgroundColor: AppColors.primary, // Primary background color
      body: Column(
        children: [
          // Transparent rectangular box at top (replacement for app bar)
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 16,
              left: 16,
              right: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.transparent, // Transparent box
            ),
            child: Row(
              children: [
                // Back button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                SizedBox(width: 16),
                // Title
                Expanded(
                  child: Text(
                    transportType,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body content with rounded top corners
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.bg, // Your background color
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: stations.length,
                itemBuilder: (context, index) {
                  return _buildStationCard(context, stations[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationCard(BuildContext context, TransportStation station) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    station.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.navigation,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    onPressed: () {
                      _openNavigation(context, station.name);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              station.address,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(Icons.access_time, station.travelTime),
                SizedBox(width: 8),
                _buildInfoChip(Icons.attach_money, station.price),
                SizedBox(width: 8),
                _buildInfoChip(Icons.directions_walk, station.distance),
              ],
            ),
            SizedBox(height: 12),
            if (station.routes.isNotEmpty) ...[
              Text(
                'Available Routes:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: station.routes.map((route) {
                  return Chip(
                    label: Text(
                      route,
                      style: TextStyle(fontSize: 12),
                    ),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    labelPadding: EdgeInsets.symmetric(horizontal: 8),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(
        text,
        style: TextStyle(fontSize: 12, color: AppColors.primary),
      ),
      backgroundColor: AppColors.primary.withOpacity(0.05),
      labelPadding: EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  void _openNavigation(BuildContext context, String destination) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening navigation to $destination'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class TransportStation {
  final String name;
  final String distance;
  final String travelTime;
  final String price;
  final String address;
  final List<String> routes;

  TransportStation({
    required this.name,
    required this.distance,
    required this.travelTime,
    required this.price,
    required this.address,
    required this.routes,
  });
}