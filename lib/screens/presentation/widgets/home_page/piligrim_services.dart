import 'package:divya_drishti/core/constants/app_colors.dart';
import 'package:divya_drishti/screens/presentation/screens/home/service_details_page.dart';
import 'package:flutter/material.dart';

// added import for Booking History page
import 'package:divya_drishti/screens/presentation/screens/booking_history_page.dart';

class PilgrimServicesWidget extends StatelessWidget {
  const PilgrimServicesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Heading
          Center(
            child: Text(
              "Pilgrim Services",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),

          SizedBox(height: 20),

          // Services Container - Single Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildServiceItem(
                context,
                Icons.celebration,
                "Sevas \n Poojas",
                ServiceType.sevasPoojas,
              ),
              _buildServiceItem(
                context,
                Icons.remove_red_eye,
                "Darshans \n ticket",
                ServiceType.darshansTicket,
              ),
              _buildServiceItem(
                context,
                Icons.accessible,
                "Pilgrim \n Facilities",
                ServiceType.pilgrimFacilities,
              ),
              _buildServiceItem(
                context,
                Icons.history_edu,
                "Booking \n History",
                ServiceType.bookingHistory,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(
      BuildContext context, IconData icon, String title, ServiceType serviceType) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // ✅ NEW: If user clicks Booking History, open booking history page
          if (serviceType == ServiceType.bookingHistory) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BookingHistoryPage(),
              ),
            );
            return;
          }

          // Default: Navigate to ServiceDetailsPage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ServiceDetailsPage(serviceType: serviceType),
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // White circular background for icon only
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
