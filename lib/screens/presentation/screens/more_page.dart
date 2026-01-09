// more_page.dart
import 'package:divya_drishti/screens/presentation/screens/more/lost_found_page.dart' hide AppColors;
import 'package:flutter/material.dart';
import 'package:divya_drishti/core/constants/app_colors.dart';

class MorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
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
                    // Do's and Don'ts Section (moved to top)
                    _buildSectionHeader('Temple Guidelines'),
                    SizedBox(height: 15),
                    _buildDosDontsBox(),

                    SizedBox(height: 25),

                    // Lost & Found Section
                    _buildSectionHeader('Lost & Found'),
                    SizedBox(height: 15),
                    _buildLostFoundBox(context), // Pass context here
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

  Widget _buildDosDontsBox() {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGuidelineItem(
              'Do\'s',
              Icons.check_circle,
              Colors.green,
              [
                'Maintain silence in prayer areas',
                'Remove footwear before entering',
                'Dress modestly and appropriately',
                'Follow temple timings',
                'Respect temple rituals and customs',
              ],
            ),
            SizedBox(height: 16),
            _buildGuidelineItem(
              'Don\'ts',
              Icons.cancel,
              Colors.red,
              [
                'No photography in restricted areas',
                'Avoid loud conversations',
                'Don\'t touch idols without permission',
                'No smoking or alcohol consumption',
                'Avoid inappropriate clothing',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelineItem(String title, IconData icon, Color color, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ...points.map((point) => Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Text(
                  point,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  // Updated method to accept BuildContext parameter
  Widget _buildLostFoundBox(BuildContext context) {
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
            _buildLostFoundOption(
              context, // Pass context here
              'Report Lost Item',
              Icons.report_problem,
              'Report your lost belongings',
              Colors.orange,
              LostFoundAction.reportLost,
            ),
            SizedBox(height: 12),
            _buildLostFoundOption(
              context, // Pass context here
              'Upload Found Item',
              Icons.add_box,
              'Upload details of found items',
              Colors.green,
              LostFoundAction.uploadFound,
            ),
            SizedBox(height: 12),
            _buildLostFoundOption(
              context, // Pass context here
              'View Lost Items',
              Icons.search,
              'Browse reported lost items',
              Colors.blue,
              LostFoundAction.viewLost,
            ),
          ],
        ),
      ),
    );
  }

  // Updated method to accept BuildContext as first parameter
  Widget _buildLostFoundOption(BuildContext context, String title, IconData icon, String subtitle, Color color, LostFoundAction action) {
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
          _handleLostFoundAction(context, action);
        },
      ),
    );
  }

  void _handleLostFoundAction(BuildContext context, LostFoundAction action) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LostFoundPage(initialAction: action),
      ),
    );
  }
}