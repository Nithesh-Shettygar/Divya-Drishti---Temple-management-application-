import 'package:divya_drishti/core/constants/app_colors.dart';
import 'package:divya_drishti/screens/presentation/screens/home/darshan_booking.dart';
import 'package:flutter/material.dart';

// Enum to identify different service types
enum ServiceType {
  sevasPoojas,
  darshansTicket,
  pilgrimFacilities,
  bookingHistory,
}

// Single page that changes content based on the selected service
class ServiceDetailsPage extends StatelessWidget {
  final ServiceType serviceType;

  const ServiceDetailsPage({super.key, required this.serviceType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          // Transparent rectangular box replacing app bar
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 16,
              left: 16,
              right: 16,
            ),
            child: Row(
              children: [
                // Back button
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 8),
                // Title
                Expanded(
                  child: Text(
                    _getAppBarTitle(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main content area
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                color: Colors.white,
              ),
              child: _buildServiceContent(context),
            ),
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (serviceType) {
      case ServiceType.sevasPoojas:
        return "Sevas & Poojas";
      case ServiceType.darshansTicket:
        return "Darshans Ticket";
      case ServiceType.pilgrimFacilities:
        return "Pilgrim Facilities";
      case ServiceType.bookingHistory:
        return "Booking History";
    }
  }

  Widget _buildServiceContent(BuildContext context) {
    switch (serviceType) {
      case ServiceType.sevasPoojas:
        return _buildSevasPoojasContent();
      case ServiceType.darshansTicket:
        return _buildDarshansTicketContent(context);
      case ServiceType.pilgrimFacilities:
        return _buildPilgrimFacilitiesContent();
      case ServiceType.bookingHistory:
        return _buildBookingHistoryContent();
    }
  }

  Widget _buildSevasPoojasContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Available Sevas & Poojas",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCircularIconOption(
                  "Abhishekam",
                  Icons.celebration,
                  onTap: () {},
                ),
              ),
              Expanded(
                child: _buildCircularIconOption(
                  "Archana",
                  Icons.celebration,
                  onTap: () {},
                ),
              ),
              Expanded(
                child: _buildCircularIconOption(
                  "Aarti",
                  Icons.celebration,
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCircularIconOption(
                  "Special Pooja",
                  Icons.celebration,
                  onTap: () {},
                ),
              ),
               Expanded(child: Container()), // Empty space
               Expanded(child: Container()), // Empty space
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDarshansTicketContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Darshan Tickets",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCircularIconOption(
                  "Darshan Booking",
                  Icons.confirmation_number,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DarshanBookingPage(
                          title: "Darshan Booking",
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: _buildCircularIconOption(
                  "Disabled/Elders",
                  Icons.accessible,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DarshanBookingPage(
                          title: "Disabled/Elders Darshan",
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: _buildCircularIconOption(
                  "Special Entry",
                  Icons.fast_forward,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DarshanBookingPage(
                          title: "Special Entry Darshan",
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPilgrimFacilitiesContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pilgrim Facilities",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCircularIconOption(
                  "Accommodation",
                  Icons.hotel,
                  onTap: () {},
                ),
              ),
              Expanded(
                child: _buildCircularIconOption(
                  "Food Services",
                  Icons.restaurant,
                  onTap: () {},
                ),
              ),
              Expanded(
                child: _buildCircularIconOption(
                  "Transport",
                  Icons.directions_bus,
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCircularIconOption(
                  "Information",
                  Icons.info,
                  onTap: () {},
                ),
              ),
              Expanded(child: Container()), // Empty space
               Expanded(child: Container()), // Empty space
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingHistoryContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Booking History",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildHistoryCard("Abhishekam", "15 Nov 2023", "Confirmed", "₹500"),
          _buildHistoryCard("Special Darshan", "10 Nov 2023", "Completed", "₹200"),
          _buildHistoryCard("Accommodation", "05 Nov 2023", "Completed", "₹1000"),
          _buildHistoryCard("Archana", "01 Nov 2023", "Completed", "₹300"),
        ],
      ),
    );
  }

  Widget _buildCircularIconOption(String title, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(String service, String date, String status, String amount) {
    Color statusColor = status == "Confirmed" ? Colors.orange : Colors.green;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.history, color: AppColors.primary),
        title: Text(service, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: TextStyle(color: statusColor, fontSize: 12),
              ),
            ),
          ],
        ),
        trailing: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}