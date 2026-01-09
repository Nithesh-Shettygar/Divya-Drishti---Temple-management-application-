import 'package:divya_drishti/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ExplorePage extends StatelessWidget {
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
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: [
                      // Temple Map Section
                      _buildSectionHeader('Temple Map'),
                      SizedBox(height: 15),
                      _buildTempleMapBox(context),

                      SizedBox(height: 25),

                      // Nearest Places Section
                      _buildSectionHeader('Nearest Places'),
                      SizedBox(height: 15),
                      _buildNearestPlacesBox(),

                      SizedBox(height: 25),

                      // Facilities Section
                      _buildSectionHeader('Facilities'),
                      SizedBox(height: 15),
                      _buildFacilitiesBox(),

                      SizedBox(height: 25),

                      // Temple Routes Section
                      _buildSectionHeader('Temple Routes'),
                      SizedBox(height: 15),
                      _buildTempleRoutesBox(),
                    ],
                  ),
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

  Widget _buildTempleMapBox(BuildContext context) {
    final String mapUrl = 'https://tracexlabs.com/navigation.html';

    Future<void> _launchMapUrl() async {
      final Uri url = Uri.parse(mapUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Show error message if URL cannot be launched
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open map URL'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    return GestureDetector(
  onTap: _launchMapUrl,
  child: Container(
    width: double.infinity,
    height: 200,
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
    child: Column(
      children: [
        // Map placeholder replaced with network image
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              color: AppColors.primary.withOpacity(0.1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                'https://www.gujarattourism.com/content/dam/gujrattourism/images/religious-sites/somnath-temple/Somnath-Temple-Thumbnail.jpg', // Replace with your image URL
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 50,
                          color: AppColors.primary,
                        ),
                        SizedBox(height: 10),
                        CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ],
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 50,
                          color: Colors.red,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Failed to load map',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Interactive Temple Guide',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Tap to open',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.zoom_in_map,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  ),
);
  }
  // ... rest of your existing methods remain the same
  Widget _buildNearestPlacesBox() {
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
            _buildPlaceItem(
              'Restaurants',
              '5 places within 1km',
              Icons.restaurant,
            ),
            SizedBox(height: 12),
            _buildPlaceItem(
              'Parking',
              '3 parking areas nearby',
              Icons.local_parking,
            ),
            SizedBox(height: 12),
            _buildPlaceItem(
              'Hotels',
              '2 hotels within 2km',
              Icons.hotel,
            ),
            SizedBox(height: 12),
            _buildPlaceItem(
              'Shopping',
              'Market area 500m away',
              Icons.shopping_cart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceItem(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          radius: 20,
          child: Icon(
            icon,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.chevron_right,
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildFacilitiesBox() {
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
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildFacilityChip('Wheelchair Access', Icons.accessible),
            _buildFacilityChip('Restrooms', Icons.wc),
            _buildFacilityChip('Drinking Water', Icons.water_drop),
            _buildFacilityChip('Shoe Storage', Icons.checkroom),
            _buildFacilityChip('Meditation Hall', Icons.self_improvement),
            _buildFacilityChip('Prayer Hall', Icons.temple_hindu),
            _buildFacilityChip('Parking', Icons.local_parking),
            _buildFacilityChip('Food Court', Icons.fastfood),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityChip(String text, IconData icon) {
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
            icon,
            size: 16,
            color: AppColors.primary,
          ),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTempleRoutesBox() {
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
            _buildRouteItem(
              'Main Entrance Route',
              'Direct path to main deity',
              Icons.directions_walk,
            ),
            SizedBox(height: 12),
            _buildRouteItem(
              'Pradakshina Path',
              'Circumambulation route',
              Icons.explore,
            ),
            SizedBox(height: 12),
            _buildRouteItem(
              'Special Darshan',
              'Fast track route',
              Icons.fast_forward,
            ),
            SizedBox(height: 12),
            _buildRouteItem(
              'Wheelchair Route',
              'Accessible path',
              Icons.accessible_forward,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteItem(String title, String subtitle, IconData icon) {
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
          Icons.navigation,
          color: AppColors.primary,
        ),
        onTap: () {
          // Handle route selection
        },
      ),
    );
  }
}