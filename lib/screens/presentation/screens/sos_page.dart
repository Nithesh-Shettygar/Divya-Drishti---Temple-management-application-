import 'package:divya_drishti/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class SOSPage extends StatelessWidget {
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
                    // Emergency Call Heading
                    _buildSectionHeader('Emergency Call', Colors.red),
                    SizedBox(height: 15),

                    // Big SOS Button (without box)
                    GestureDetector(
                      onTap: () {
                        _showSOSConfirmationDialog(context);
                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.emergency,
                              size: 40,
                              color: Colors.white,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'SOS',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Tap in case of emergency',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary.withOpacity(0.7),
                      ),
                    ),

                    SizedBox(height: 25),

                    // Emergency Helpline Heading
                    _buildSectionHeader('Emergency Helpline', AppColors.primary),
                    SizedBox(height: 15),

                    // Emergency Helpline Box
                    Container(
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
                            // Police Helpline
                            _buildHelplineOption(
                              icon: Icons.local_police,
                              title: 'Police',
                              number: '100',
                              onTap: () {
                                _callHelpline(context, 'Police', '100');
                              },
                            ),
                            SizedBox(height: 12),
                            // Fire Helpline
                            _buildHelplineOption(
                              icon: Icons.fire_extinguisher,
                              title: 'Fire Department',
                              number: '101',
                              onTap: () {
                                _callHelpline(context, 'Fire Department', '101');
                              },
                            ),
                            SizedBox(height: 12),
                            // Women Helpline
                            _buildHelplineOption(
                              icon: Icons.woman,
                              title: 'Women Helpline',
                              number: '1091',
                              onTap: () {
                                _callHelpline(context, 'Women Helpline', '1091');
                              },
                            ),
                            SizedBox(height: 12),
                            // Disaster Management
                            _buildHelplineOption(
                              icon: Icons.security,
                              title: 'Disaster Management',
                              number: '108',
                              onTap: () {
                                _callHelpline(context, 'Disaster Management', '108');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 25),

                    // Medical Assistance Heading
                    _buildSectionHeader('Medical Assistance', Colors.green),
                    SizedBox(height: 15),

                    // Medical Assistance Box
                    Container(
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
                            // Ambulance Service
                            _buildMedicalOption(
                              icon: Icons.medical_services,
                              title: 'Ambulance Service',
                              subtitle: 'Emergency ambulance',
                              number: '102',
                              onTap: () {
                                _callAmbulance(context);
                              },
                            ),
                            SizedBox(height: 16),
                            // Call for Medical Option
                            _buildMedicalOption(
                              icon: Icons.phone,
                              title: 'Medical Helpline',
                              subtitle: 'Emergency medical services',
                              number: '108',
                              onTap: () {
                                _callMedicalHelp(context);
                              },
                            ),
                            SizedBox(height: 16),
                            // Navigate to Medical Camp Option
                            _buildMedicalOption(
                              icon: Icons.navigation,
                              title: 'Nearest Medical Camp',
                              subtitle: 'Navigate to medical facility',
                              onTap: () {
                                _navigateToMedicalCamp(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 25),

                    // Fire Emergency Heading
                    _buildSectionHeader('Fire Emergency', Colors.orange),
                    SizedBox(height: 15),

                    // Fire Emergency Box
                    Container(
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
                            // Fire Emergency Call
                            _buildFireOption(
                              icon: Icons.local_fire_department,
                              title: 'Fire Emergency',
                              subtitle: 'Call fire department',
                              number: '101',
                              onTap: () {
                                _callFireEmergency(context);
                              },
                            ),
                            SizedBox(height: 16),
                            // Fire Station Navigation
                            _buildFireOption(
                              icon: Icons.navigation,
                              title: 'Nearest Fire Station',
                              subtitle: 'Navigate to fire station',
                              onTap: () {
                                _navigateToFireStation(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Container(
      width: double.infinity,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMedicalOption({
    required IconData icon,
    required String title,
    required String subtitle,
    String? number,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.1),
          radius: 20,
          child: Icon(
            icon,
            size: 18,
            color: Colors.green,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            if (number != null)
              Text(
                'Helpline: $number',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.green,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildHelplineOption({
    required IconData icon,
    required String title,
    required String number,
    required VoidCallback onTap,
  }) {
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
          'Helpline: $number',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.primary.withOpacity(0.7),
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Icon(
          Icons.phone,
          color: AppColors.primary,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFireOption({
    required IconData icon,
    required String title,
    required String subtitle,
    String? number,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withOpacity(0.1),
          radius: 20,
          child: Icon(
            icon,
            size: 18,
            color: Colors.orange,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.orange,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            if (number != null)
              Text(
                'Helpline: $number',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.orange,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showSOSConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.red,
              ),
              SizedBox(width: 10),
              Text('Emergency SOS'),
            ],
          ),
          content: Text(
            'Are you sure you want to trigger emergency SOS? This will alert emergency services.',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _triggerSOS();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(
                'Call SOS',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _triggerSOS() {
    // Implement SOS functionality
    print('SOS triggered!');
    // Add actual emergency call implementation here
  }

  void _callMedicalHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Call Medical Help'),
          content: Text('Connecting to emergency medical services (108)...'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Implement actual call functionality
                print('Calling medical help: 108');
                // Add actual phone call implementation
              },
              child: Text('Call'),
            ),
          ],
        );
      },
    );
  }

  void _callAmbulance(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Call Ambulance'),
          content: Text('Connecting to ambulance service (102)...'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Implement actual call functionality
                print('Calling ambulance: 102');
                // Add actual phone call implementation
              },
              child: Text('Call Ambulance'),
            ),
          ],
        );
      },
    );
  }

  void _callHelpline(BuildContext context, String service, String number) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Call $service'),
          content: Text('Connecting to $service ($number)...'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Implement actual call functionality
                print('Calling $service: $number');
                // Add actual phone call implementation
              },
              child: Text('Call $number'),
            ),
          ],
        );
      },
    );
  }

  void _callFireEmergency(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Fire Emergency'),
          content: Text('Connecting to fire department (101)...'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Implement actual call functionality
                print('Calling fire department: 101');
                // Add actual phone call implementation
              },
              child: Text('Call Fire Department'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToMedicalCamp(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Navigate to Medical Camp'),
          content: Text('Opening navigation to the nearest medical facility...'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Implement navigation functionality
                print('Navigating to medical camp...');
                // Add actual navigation implementation
              },
              child: Text('Navigate'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToFireStation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Navigate to Fire Station'),
          content: Text('Opening navigation to the nearest fire station...'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Implement navigation functionality
                print('Navigating to fire station...');
                // Add actual navigation implementation
              },
              child: Text('Navigate'),
            ),
          ],
        );
      },
    );
  }
}
